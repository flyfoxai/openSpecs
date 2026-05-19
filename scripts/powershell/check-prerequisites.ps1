#!/usr/bin/env pwsh

# Consolidated prerequisite checking script (PowerShell)

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$RequireSpec,
    [switch]$RequireBundle,
    [switch]$RequirePlan,
    [switch]$RequireTasks,
    [switch]$IncludeTasks,
    [switch]$PathsOnly,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output @"
Usage: check-prerequisites.ps1 [OPTIONS]

OPTIONS:
  -Json               Output in JSON format
  -RequireSpec        Require specs/<feature>/spec.md to exist
  -RequireBundle      Require spec.md and bundle.md to exist
  -RequirePlan        Require spec.md, bundle.md, and plan.md to exist
  -RequireTasks       Require plan.md and tasks.md to exist
  -IncludeTasks       Include tasks.md in AVAILABLE_DOCS when present
  -PathsOnly          Only output path variables
  -Help               Show this help message
"@
    exit 0
}

. "$PSScriptRoot/common.ps1"

$paths = Get-FeaturePathsEnv

function Convert-ToRepoRelative {
    param([string]$PathValue)
    if (-not $PathValue) { return '' }
    $repoPrefix = $paths.REPO_ROOT.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    if ($PathValue.StartsWith($repoPrefix)) {
        return $PathValue.Substring($repoPrefix.Length).TrimStart([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) -replace '\\', '/'
    }
    return $PathValue -replace '\\', '/'
}

function Set-FeatureDir {
    param([string]$FeatureDir)
    if (-not $FeatureDir) { return }
    if (-not [System.IO.Path]::IsPathRooted($FeatureDir)) {
        $FeatureDir = Join-Path $paths.REPO_ROOT $FeatureDir
    }
    $paths.FEATURE_DIR = $FeatureDir
    $paths.FEATURE_SPEC = Join-Path $FeatureDir 'spec.md'
    $paths.IMPL_PLAN = Join-Path $FeatureDir 'plan.md'
    $paths.TASKS = Join-Path $FeatureDir 'tasks.md'
    $paths.RESEARCH = Join-Path $FeatureDir 'research.md'
    $paths.DATA_MODEL = Join-Path $FeatureDir 'data-model.md'
    $paths.QUICKSTART = Join-Path $FeatureDir 'quickstart.md'
    $paths.CONTRACTS_DIR = Join-Path $FeatureDir 'contracts'
}

function Get-FeatureFromActiveContext {
    $activeContext = Join-Path $paths.REPO_ROOT '.specify/memory/active-context.md'
    if (-not (Test-Path $activeContext)) { return $null }
    foreach ($line in Get-Content -LiteralPath $activeContext) {
        $match = [regex]::Match($line, 'specs/([^/]+)/')
        if ($match.Success) { return $match.Groups[1].Value }
    }
    return $null
}

function Get-SingleFeatureDir {
    $specsDir = Join-Path $paths.REPO_ROOT 'specs'
    if (-not (Test-Path $specsDir -PathType Container)) { return $null }
    $dirs = @(Get-ChildItem -LiteralPath $specsDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name)
    if ($dirs.Count -eq 1) { return $dirs[0].FullName }
    return $null
}

if (-not (Test-Path $paths.FEATURE_DIR -PathType Container)) {
    $activeFeature = Get-FeatureFromActiveContext
    if ($activeFeature -and (Test-Path (Join-Path (Join-Path $paths.REPO_ROOT 'specs') $activeFeature) -PathType Container)) {
        Set-FeatureDir -FeatureDir (Join-Path (Join-Path $paths.REPO_ROOT 'specs') $activeFeature)
    } else {
        $singleFeatureDir = Get-SingleFeatureDir
        if ($singleFeatureDir) {
            Set-FeatureDir -FeatureDir $singleFeatureDir
        }
    }
}

$bundle = Join-Path $paths.FEATURE_DIR 'bundle.md'
$hasActiveFeature = $paths.FEATURE_DIR -and (Test-Path $paths.FEATURE_DIR -PathType Container)
$missing = New-Object System.Collections.Generic.List[string]
$requireAny = $RequireSpec -or $RequireBundle -or $RequirePlan -or $RequireTasks

function Add-Missing {
    param([string]$Label, [string]$PathValue)
    if ([string]::IsNullOrWhiteSpace($PathValue) -or -not (Test-Path $PathValue -PathType Leaf)) {
        $missing.Add($Label)
    }
}

if (-not $hasActiveFeature -and $requireAny) {
    $missing.Add('no_active_feature')
} else {
    if ($RequireSpec -or $RequireBundle -or $RequirePlan) {
        Add-Missing -Label 'spec.md' -PathValue $paths.FEATURE_SPEC
    }
    if ($RequireBundle -or $RequirePlan) {
        Add-Missing -Label 'bundle.md' -PathValue $bundle
    }
    if ($RequirePlan -or $RequireTasks) {
        Add-Missing -Label 'plan.md' -PathValue $paths.IMPL_PLAN
    }
    if ($RequireTasks) {
        Add-Missing -Label 'tasks.md' -PathValue $paths.TASKS
    }
}

$docs = @()
if (Test-Path $paths.FEATURE_SPEC -PathType Leaf) { $docs += 'spec.md' }
if (Test-Path $bundle -PathType Leaf) { $docs += 'bundle.md' }
if (Test-Path $paths.IMPL_PLAN -PathType Leaf) { $docs += 'plan.md' }
if (Test-Path $paths.RESEARCH -PathType Leaf) { $docs += 'research.md' }
if (Test-Path $paths.DATA_MODEL -PathType Leaf) { $docs += 'data-model.md' }
if ((Test-Path $paths.CONTRACTS_DIR -PathType Container) -and (Get-ChildItem -Path $paths.CONTRACTS_DIR -ErrorAction SilentlyContinue | Select-Object -First 1)) {
    $docs += 'contracts/'
}
if (Test-Path $paths.QUICKSTART -PathType Leaf) { $docs += 'quickstart.md' }
if ($IncludeTasks -and (Test-Path $paths.TASKS -PathType Leaf)) { $docs += 'tasks.md' }

if ($PathsOnly) {
    if ($Json) {
        $pathsOnlyFeatureDirRel = if ($hasActiveFeature) { Convert-ToRepoRelative $paths.FEATURE_DIR } else { '' }
        [PSCustomObject]@{
            REPO_ROOT = $paths.REPO_ROOT
            BRANCH = $paths.CURRENT_BRANCH
            FEATURE_DIR = if ($hasActiveFeature) { $paths.FEATURE_DIR } else { '' }
            FEATURE_SPEC = if ($hasActiveFeature) { $paths.FEATURE_SPEC } else { '' }
            BUNDLE = if ($hasActiveFeature) { $bundle } else { '' }
            IMPL_PLAN = if ($hasActiveFeature) { $paths.IMPL_PLAN } else { '' }
            TASKS = if ($hasActiveFeature) { $paths.TASKS } else { '' }
            hasActiveFeature = [bool]$hasActiveFeature
            activeFeature = if ($hasActiveFeature) { Split-Path -Leaf $paths.FEATURE_DIR } else { '' }
            featureDir = $pathsOnlyFeatureDirRel
        } | ConvertTo-Json -Compress
    } else {
        Write-Output "REPO_ROOT: $($paths.REPO_ROOT)"
        Write-Output "BRANCH: $($paths.CURRENT_BRANCH)"
        Write-Output "FEATURE_DIR: $($paths.FEATURE_DIR)"
        Write-Output "FEATURE_SPEC: $($paths.FEATURE_SPEC)"
        Write-Output "BUNDLE: $bundle"
        Write-Output "IMPL_PLAN: $($paths.IMPL_PLAN)"
        Write-Output "TASKS: $($paths.TASKS)"
    }
    exit 0
}

$activeFeatureName = if ($hasActiveFeature) { Split-Path -Leaf $paths.FEATURE_DIR } else { '' }
$featureDirRel = if ($hasActiveFeature) { Convert-ToRepoRelative $paths.FEATURE_DIR } else { '' }
$specPathRel = if ($hasActiveFeature) { Convert-ToRepoRelative $paths.FEATURE_SPEC } else { '' }
$bundlePathRel = if ($hasActiveFeature) { Convert-ToRepoRelative $bundle } else { '' }
$planPathRel = if ($hasActiveFeature) { Convert-ToRepoRelative $paths.IMPL_PLAN } else { '' }
$tasksPathRel = if ($hasActiveFeature) { Convert-ToRepoRelative $paths.TASKS } else { '' }
$outputFeatureDir = if ($hasActiveFeature) { $paths.FEATURE_DIR } else { '' }
$outputFeatureSpec = if ($hasActiveFeature) { $paths.FEATURE_SPEC } else { '' }
$outputBundle = if ($hasActiveFeature) { $bundle } else { '' }
$outputPlan = if ($hasActiveFeature) { $paths.IMPL_PLAN } else { '' }
$outputTasks = if ($hasActiveFeature) { $paths.TASKS } else { '' }

if ($Json) {
    [PSCustomObject]@{
        FEATURE_DIR = $outputFeatureDir
        FEATURE_SPEC = $outputFeatureSpec
        BUNDLE = $outputBundle
        IMPL_PLAN = $outputPlan
        TASKS = $outputTasks
        AVAILABLE_DOCS = $docs
        MISSING = @($missing)
        projectRoot = $paths.REPO_ROOT
        branch = $paths.CURRENT_BRANCH
        hasActiveFeature = [bool]$hasActiveFeature
        activeFeature = $activeFeatureName
        featureDir = $featureDirRel
        specPath = $specPathRel
        bundlePath = $bundlePathRel
        planPath = $planPathRel
        tasksPath = $tasksPathRel
        missing = @($missing)
    } | ConvertTo-Json -Compress
} else {
    Write-Output "FEATURE_DIR:$($paths.FEATURE_DIR)"
    Write-Output "AVAILABLE_DOCS:"
    Test-FileExists -Path $paths.FEATURE_SPEC -Description 'spec.md' | Out-Null
    Test-FileExists -Path $bundle -Description 'bundle.md' | Out-Null
    Test-FileExists -Path $paths.IMPL_PLAN -Description 'plan.md' | Out-Null
    Test-FileExists -Path $paths.RESEARCH -Description 'research.md' | Out-Null
    Test-FileExists -Path $paths.DATA_MODEL -Description 'data-model.md' | Out-Null
    Test-DirHasFiles -Path $paths.CONTRACTS_DIR -Description 'contracts/' | Out-Null
    Test-FileExists -Path $paths.QUICKSTART -Description 'quickstart.md' | Out-Null
    if ($IncludeTasks) {
        Test-FileExists -Path $paths.TASKS -Description 'tasks.md' | Out-Null
    }
}

if ($missing.Count -gt 0) {
    if ($missing -contains 'no_active_feature') {
        [Console]::Error.WriteLine('Missing required stage outputs: no_active_feature. No active feature was found; run sp.specify first (skills hosts: sp-specify).')
    } else {
        [Console]::Error.WriteLine("Missing required stage outputs: $($missing -join ', ')")
    }
    exit 1
}
