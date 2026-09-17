# Global Engineering Rules

- Prefer the smallest correct change. Preserve existing architecture and patterns unless changing them is necessary for correctness.
- No unrelated refactors, cleanup, abstractions, dependencies, file moves, or speculative extensibility. YAGNI.
- Verification must be proportional to actual risk. Do not add tests merely because code changed, and do not run full test/build/lint suites after trivial or local changes without a concrete reason.
- Never invent verification commands; discover relevant commands from the repository.
- Do not repeatedly guess after failures; use concrete evidence and escalate repeated semantic failures to deeper diagnosis.
- Ask the user only when a genuinely critical ambiguity remains after inspecting available project context.
- Never commit, push, merge, rebase, tag, or alter remote Git state unless explicitly requested in the current request.
- Ask before destructive or irreversible operations affecting databases, user data, credentials, deployments, remote resources, or Git history unless explicitly authorized.
