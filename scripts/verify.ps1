[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$agentDir = if ($env:OMP_AGENT_DIR) { $env:OMP_AGENT_DIR } else { Join-Path $HOME '.omp\agent' }
$pass = 0; $warn = 0; $fail = 0
function Pass([string]$Message) { Write-Host "PASS  $Message"; $script:pass++ }
function Warn([string]$Message) { Write-Host "WARN  $Message"; $script:warn++ }
function Fail([string]$Message) { Write-Host "FAIL  $Message"; $script:fail++ }
function Need-File([string]$Relative) { if (Test-Path -LiteralPath (Join-Path $agentDir $Relative) -PathType Leaf) { Pass $Relative } else { Fail "missing $Relative" } }
function Need-Text([string]$Relative, [string]$Text, [string]$Label) {
    $path = Join-Path $agentDir $Relative
    if ((Test-Path -LiteralPath $path -PathType Leaf) -and (Select-String -LiteralPath $path -SimpleMatch $Text -Quiet)) { Pass $Label } else { Fail $Label }
}

Need-File 'AGENTS.md'; Need-File 'RULES.md'
foreach ($name in 'planner', 'worker', 'hard-worker', 'ui-designer', 'architect-reviewer') { Need-File "agents\$name.md" }
Need-File 'extensions\main-orchestrator-guard\index.ts'
Need-Text 'AGENTS.md' 'Cross-turn planning continuity' 'cross-turn planning rule'
Need-Text 'AGENTS.md' 'Reviewer availability' 'reviewer availability rule'
Need-Text 'AGENTS.md' 'The accompanying guard is deliberately domain-agnostic' 'mechanical guard explanation'
foreach ($name in 'worker', 'hard-worker', 'ui-designer') { Need-Text "agents\$name.md" 'Verification ownership' "$name owns verification" }

$guard = Join-Path $agentDir 'extensions\main-orchestrator-guard\index.ts'
if ((Test-Path -LiteralPath $guard -PathType Leaf) -and -not (Select-String -LiteralPath $guard -Pattern 'auth|finance|permission|migration|frappe|payment|security' -CaseSensitive:$false -Quiet)) { Pass 'guard has no semantic/domain routing classifier terms' } else { Fail 'guard contains a prohibited semantic/domain routing term' }
$profile = Join-Path $agentDir 'omp-adaptive-workflow\model-profile.example.yml'
if (Test-Path -LiteralPath $profile -PathType Leaf) {
    $text = Get-Content -LiteralPath $profile -Raw
    if ($text.Contains('google-antigravity/gemini-3.8-flash:high') -and $text.Contains('task: []') -and $text.Contains('review: []')) { Pass 'recommended isolated fallback profile visible' } else { Warn 'model profile exists but fallback isolation could not be confirmed' }
} else { Warn 'model profile not installed; config.yml was intentionally not inspected' }
Write-Host "`nSummary: PASS=$pass WARN=$warn FAIL=$fail"
if ($fail -gt 0) { exit 1 }
