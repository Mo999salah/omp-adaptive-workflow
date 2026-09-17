import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

type TaskItem = { agent?: string };

/**
 * This extension deliberately enforces mechanics, not meaning.
 * It has no domain vocabulary, keyword/risk classifier, project logic, or
 * routing policy. The AI coordinator alone makes semantic decisions.
 */
export default function mainOrchestratorGuard(pi: ExtensionAPI): void {
  const blockedMainTools = new Set(["edit", "write", "ast_edit", "bash", "eval"]);
  const implementationAgents = new Set(["worker", "hard-worker", "ui-designer"]);

  let plannerRan = false;
  let implementationRan = false;
  let reviewRan = false;
  let reviewerUnavailable = false;

  function taskItems(input: Record<string, unknown>): TaskItem[] {
    if (Array.isArray(input.tasks)) {
      return input.tasks.filter((item): item is TaskItem => !!item && typeof item === "object");
    }
    return [{ agent: typeof input.agent === "string" ? input.agent : undefined }];
  }

  pi.on("before_agent_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    plannerRan = false;
    implementationRan = false;
    reviewRan = false;
    reviewerUnavailable = false;
  });

  pi.on("tool_call", async (event, ctx) => {
    if (!ctx.hasUI || !blockedMainTools.has(event.toolName)) return;
    // Headless task agents retain only the tools their own definitions allow.
    return {
      block: true,
      reason: "Main coordinator is read-only. Delegate implementation and routine verification to an appropriate task agent.",
    };
  });

  pi.on("tool_result", async (event, ctx) => {
    if (!ctx.hasUI || event.toolName !== "task") return;
    const items = taskItems(event.input);

    // A task/provider/infrastructure failure is availability information, not a
    // signal to retry. The coordinator reports the incomplete required review.
    if (event.isError) {
      if (items.some((item) => item.agent === "architect-reviewer")) reviewerUnavailable = true;
      return;
    }

    for (const { agent = "" } of items) {
      if (agent === "planner") plannerRan = true;
      if (implementationAgents.has(agent)) {
        implementationRan = true;
        // A later implementation always makes an earlier review stale.
        if (plannerRan) {
          reviewRan = false;
          reviewerUnavailable = false;
        }
      }
      if (agent === "architect-reviewer") {
        reviewRan = true;
        reviewerUnavailable = false;
      }
    }
  });

  pi.on("session_stop", async () => {
    if (plannerRan && implementationRan && !reviewRan && !reviewerUnavailable) {
      return {
        continue: true,
        additionalContext:
          "Planner-driven implementation requires a fresh `architect-reviewer` pass before completion. Provide the requirement, planner contract, latest diff, and verification evidence. Confirm the review contains explicit PASS or evidence-based findings; a successful task call alone is not proof of review completion.",
      };
    }
  });
}
