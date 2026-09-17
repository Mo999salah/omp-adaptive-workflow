#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
agent_dir="${OMP_AGENT_DIR:-$HOME/.omp/agent}"
timestamp="$(date +%Y%m%d-%H%M%S-%N)"
backup_dir="$agent_dir/backups/omp-adaptive-workflow-$timestamp"

copy_managed() {
  local source_relative="$1"
  local destination_relative="$2"
  local source="$source_dir/$source_relative"
  local destination="$agent_dir/$destination_relative"
  if [[ -e "$destination" ]]; then
    mkdir -p "$backup_dir/$(dirname "$destination_relative")"
    cp -p "$destination" "$backup_dir/$destination_relative"
  fi
  mkdir -p "$(dirname "$destination")"
  cp -p "$source" "$destination"
  printf 'installed: %s\n' "$destination"
}

if [[ ! -f "$source_dir/global/AGENTS.md" || ! -f "$source_dir/extensions/main-orchestrator-guard/index.ts" ]]; then
  printf 'ERROR: run this script from a complete omp-adaptive-workflow checkout.\n' >&2
  exit 1
fi

mkdir -p "$agent_dir"
copy_managed "global/AGENTS.md" "AGENTS.md"
copy_managed "global/RULES.md" "RULES.md"
for name in planner worker hard-worker ui-designer architect-reviewer; do
  copy_managed "agents/$name.md" "agents/$name.md"
done
copy_managed "extensions/main-orchestrator-guard/index.ts" "extensions/main-orchestrator-guard/index.ts"
copy_managed "config/model-profile.example.yml" "omp-adaptive-workflow/model-profile.example.yml"

# The profile remains separate: a stdlib-only YAML merge can corrupt unknown user
# configuration. Credentials and the user's existing config.yml are intentionally untouched.
printf 'preserved: %s (not merged)\n' "$agent_dir/config.yml"
printf 'preserved: provider authentication, sessions, caches, and all unrelated files\n'
if [[ -d "$backup_dir" ]]; then printf 'backup: %s\n' "$backup_dir"; else printf 'backup: none needed\n'; fi
printf 'profile: %s\n' "$agent_dir/omp-adaptive-workflow/model-profile.example.yml"
printf 'Next: review the profile and apply supported model mappings to config.yml manually.\n'
