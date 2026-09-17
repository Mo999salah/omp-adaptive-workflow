[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$sourceDir = Split-Path -Parent $PSScriptRoot
$agentDir = if ($env:OMP_AGENT_DIR) { $env:OMP_AGENT_DIR } else { Join-Path $HOME '.omp\agent' }
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$backupDir = Join-Path $agentDir "backups\omp-adaptive-workflow-$stamp"

function Copy-ManagedFile([string]$SourceRelative, [string]$DestinationRelative) {
    $source = Join-Path $sourceDir $SourceRelative
    $destination = Join-Path $agentDir $DestinationRelative
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing source file: $source" }
    if (Test-Path -LiteralPath $destination) {
        $backup = Join-Path $backupDir $DestinationRelative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backup) | Out-Null
        Copy-Item -LiteralPath $destination -Destination $backup -Force
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Force
    Write-Host "installed: $destination"
}

if (-not (Test-Path -LiteralPath (Join-Path $sourceDir 'global\AGENTS.md') -PathType Leaf)) {
    throw 'Run this script from a complete omp-adaptive-workflow checkout.'
}

New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
Copy-ManagedFile 'global\AGENTS.md' 'AGENTS.md'
Copy-ManagedFile 'global\RULES.md' 'RULES.md'
foreach ($name in 'planner', 'worker', 'hard-worker', 'ui-designer', 'architect-reviewer') {
    Copy-ManagedFile "agents\$name.md" "agents\$name.md"
}
Copy-ManagedFile 'extensions\main-orchestrator-guard\index.ts' 'extensions\main-orchestrator-guard\index.ts'
Copy-ManagedFile 'config\model-profile.example.yml' 'omp-adaptive-workflow\model-profile.example.yml'

# config.yml and all auth/session/provider state are intentionally untouched: a
# dependency-free YAML merge can damage unknown configuration.
Write-Host "preserved: $(Join-Path $agentDir 'config.yml') (not merged)"
Write-Host 'preserved: provider authentication, sessions, caches, and all unrelated files'
if (Test-Path -LiteralPath $backupDir) { Write-Host "backup: $backupDir" } else { Write-Host 'backup: none needed' }
Write-Host "profile: $(Join-Path $agentDir 'omp-adaptive-workflow\model-profile.example.yml')"
Write-Host 'Next: review the profile and apply supported model mappings to config.yml manually.'
