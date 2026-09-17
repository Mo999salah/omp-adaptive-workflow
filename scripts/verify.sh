#!/usr/bin/env bash
set -u

agent_dir="${OMP_AGENT_DIR:-$HOME/.omp/agent}"
pass=0 warn=0 fail=0
ok() { printf 'PASS  %s\n' "$1"; pass=$((pass + 1)); }
warning() { printf 'WARN  %s\n' "$1"; warn=$((warn + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; fail=$((fail + 1)); }
need_file() { [[ -f "$agent_dir/$1" ]] && ok "$1" || bad "missing $1"; }
need_text() { grep -Fq "$2" "$agent_dir/$1" 2>/dev/null && ok "$3" || bad "$3"; }

need_file "AGENTS.md"
need_file "RULES.md"
for name in planner worker hard-worker ui-designer architect-reviewer; do need_file "agents/$name.md"; done
need_file "extensions/main-orchestrator-guard/index.ts"

need_text "AGENTS.md" "Cross-turn planning continuity" "cross-turn planning rule"
need_text "AGENTS.md" "Reviewer availability" "reviewer availability rule"
need_text "AGENTS.md" "The accompanying guard is deliberately domain-agnostic" "mechanical guard explanation"
for name in worker hard-worker ui-designer; do need_text "agents/$name.md" "Verification ownership" "$name owns verification"; done

guard="$agent_dir/extensions/main-orchestrator-guard/index.ts"
if [[ -f "$guard" ]] && ! grep -Eqi 'auth|finance|permission|migration|frappe|payment|security' "$guard"; then
  ok "guard has no semantic/domain routing classifier terms"
else
  bad "guard contains a prohibited semantic/domain routing term"
fi

profile="$agent_dir/omp-adaptive-workflow/model-profile.example.yml"
if [[ -f "$profile" ]]; then
  if grep -Fq 'google-antigravity/gemini-3.8-flash:high' "$profile" && grep -Fq 'task: []' "$profile" && grep -Fq 'review: []' "$profile"; then
    ok "recommended isolated fallback profile visible"
  else
    warning "model profile exists but fallback isolation could not be confirmed"
  fi
else
  warning "model profile not installed; config.yml was intentionally not inspected"
fi

printf '\nSummary: PASS=%d WARN=%d FAIL=%d\n' "$pass" "$warn" "$fail"
[[ "$fail" -eq 0 ]]
