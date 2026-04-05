param(
    [Parameter(Position = 0)]
    [string]$TargetDir,

    [switch]$Yes,

    [string]$ArchiveUrl
)

$ErrorActionPreference = "Stop"

$script:DownloadDir = $null

function Cleanup {
    if ($script:DownloadDir -and (Test-Path $script:DownloadDir)) {
        Remove-Item -Recurse -Force $script:DownloadDir
    }
}

function Show-Usage {
    @"
Usage:
  powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 [target_dir]
  powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Yes [target_dir]
  powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -ArchiveUrl <zip-url> [target_dir]

Behavior:
  - If target_dir is omitted, install into the current directory.
  - Prompts for confirmation before writing files unless -Yes is used.
  - Windows local mode copies assets from the current repository.
  - iwr|iex mode requires -ArchiveUrl or SP_INSTALL_ARCHIVE_URL.
  - Remote mode can also use SP_INSTALL_TARGET_DIR and SP_INSTALL_AUTO_YES.
"@
}

function Get-ExistingCount {
    param(
        [string]$TargetAbs
    )

    $managed = @(
        "docs",
        "layer-1-business-clarification",
        "layer-2-delivery",
        ".specify/memory",
        "specs",
        ".sp/install-manifest.json",
        "docs/sp-overview.zh-CN.md",
        "docs/sp-overview-details.zh-CN.md",
        "docs/sp-overview.en.md",
        "docs/sp-overview-details.en.md"
    )

    $count = 0
    foreach ($rel in $managed) {
        if (Test-Path (Join-Path $TargetAbs $rel)) {
            $count++
        }
    }
    return $count
}

function Copy-Tree {
    param(
        [string]$Source,
        [string]$Destination
    )

    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

function Resolve-SourceRoot {
    param(
        [string]$ArchiveUrlValue
    )

    $localRoot = $null
    if ($PSScriptRoot) {
        $candidate = Resolve-Path (Join-Path $PSScriptRoot "..") -ErrorAction SilentlyContinue
        if ($candidate) {
            $localRoot = $candidate.Path
        }
    }

    if (
        $localRoot -and
        (Test-Path (Join-Path $localRoot "docs")) -and
        (Test-Path (Join-Path $localRoot "installer-assets"))
    ) {
        return @{
            Root = $localRoot
            Mode = "local"
        }
    }

    if (-not $ArchiveUrlValue) {
        throw "No local source found and no archive URL was provided. Use -ArchiveUrl when running through iwr|iex."
    }

    $script:DownloadDir = Join-Path ([System.IO.Path]::GetTempPath()) ("sp-install-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $script:DownloadDir | Out-Null

    $archivePath = Join-Path $script:DownloadDir "sp-install.zip"
    Invoke-WebRequest -UseBasicParsing -Uri $ArchiveUrlValue -OutFile $archivePath

    $extractPath = Join-Path $script:DownloadDir "extract"
    Expand-Archive -Path $archivePath -DestinationPath $extractPath -Force

    if ((Test-Path (Join-Path $extractPath "docs")) -and (Test-Path (Join-Path $extractPath "installer-assets"))) {
        return @{
            Root = $extractPath
            Mode = "archive"
        }
    }

    $match = Get-ChildItem -Path $extractPath -Directory -Recurse |
        Where-Object {
            (Test-Path (Join-Path $_.FullName "docs")) -and
            (Test-Path (Join-Path $_.FullName "installer-assets"))
        } |
        Select-Object -First 1

    if (-not $match) {
        throw "Downloaded archive does not contain the expected sp asset layout."
    }

    return @{
        Root = $match.FullName
        Mode = "archive"
    }
}

try {
    if (-not $PSBoundParameters.ContainsKey("TargetDir") -or [string]::IsNullOrWhiteSpace($TargetDir)) {
        if ($env:SP_INSTALL_TARGET_DIR) {
            $TargetDir = $env:SP_INSTALL_TARGET_DIR
        }
        else {
            $TargetDir = "."
        }
    }

    if (-not $PSBoundParameters.ContainsKey("ArchiveUrl") -and $env:SP_INSTALL_ARCHIVE_URL) {
        $ArchiveUrl = $env:SP_INSTALL_ARCHIVE_URL
    }

    $autoYes = $Yes.IsPresent
    if ((-not $autoYes) -and $env:SP_INSTALL_AUTO_YES -match '^(?i:1|true|yes|y)$') {
        $autoYes = $true
    }

    if ($args -contains "--help" -or $args -contains "-h") {
        Show-Usage
        exit 0
    }

    $sourceInfo = Resolve-SourceRoot -ArchiveUrlValue $ArchiveUrl
    $sourceRoot = $sourceInfo.Root
    $sourceMode = $sourceInfo.Mode

    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    $targetAbs = (Resolve-Path $TargetDir).Path
    $existingCount = Get-ExistingCount -TargetAbs $targetAbs

    if (-not $autoYes) {
        Write-Host ""
        Write-Host "sp installer is about to write the document-stage starter pack."
        Write-Host ""
        Write-Host "Target directory:"
        Write-Host "  $targetAbs"
        Write-Host ""
        Write-Host "This will install or refresh:"
        Write-Host "  - docs/sp-*.md and overview docs"
        Write-Host "  - layer-1-business-clarification/"
        Write-Host "  - layer-2-delivery/"
        Write-Host "  - .specify/memory/"
        Write-Host "  - specs/"
        Write-Host "  - .sp/install-manifest.json"
        Write-Host ""
        Write-Host "Managed paths that already exist:"
        Write-Host "  $existingCount"
        Write-Host ""
        Write-Host "Unrelated files will not be deleted."
        $answer = Read-Host "Continue? [y/N]"
        if ($answer -notin @("y", "Y", "yes", "YES")) {
            throw "Installation cancelled."
        }
    }

    Copy-Tree -Source (Join-Path $sourceRoot "docs") -Destination (Join-Path $targetAbs "docs")
    Copy-Tree -Source (Join-Path $sourceRoot "installer-assets/project/docs") -Destination (Join-Path $targetAbs "docs")
    Copy-Tree -Source (Join-Path $sourceRoot "layer-1-business-clarification") -Destination (Join-Path $targetAbs "layer-1-business-clarification")
    Copy-Tree -Source (Join-Path $sourceRoot "layer-2-delivery") -Destination (Join-Path $targetAbs "layer-2-delivery")
    Copy-Tree -Source (Join-Path $sourceRoot "installer-assets/project/.specify/memory") -Destination (Join-Path $targetAbs ".specify/memory")

    New-Item -ItemType Directory -Force -Path (Join-Path $targetAbs "specs") | Out-Null

    $version = "unknown"
    $packageJson = Join-Path $sourceRoot "package.json"
    if (Test-Path $packageJson) {
        $packageRaw = Get-Content -Raw -Path $packageJson
        try {
            $package = $packageRaw | ConvertFrom-Json
            if ($package.version) {
                $version = [string]$package.version
            }
        }
        catch {
            $versionMatch = [regex]::Match($packageRaw, '"version"\s*:\s*"(?<version>[^"]+)"')
            if ($versionMatch.Success) {
                $version = $versionMatch.Groups["version"].Value
            }
        }
    }

    $manifestDir = Join-Path $targetAbs ".sp"
    New-Item -ItemType Directory -Force -Path $manifestDir | Out-Null

    $manifest = [ordered]@{
        name = "sp-document-workflow"
        version = $version
        installedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        sourceMode = $sourceMode
        targetDir = $targetAbs
    } | ConvertTo-Json

    Set-Content -Path (Join-Path $manifestDir "install-manifest.json") -Value $manifest

    Write-Host "sp document-stage starter pack installed to:"
    Write-Host "  $targetAbs"
    Write-Host ""
    Write-Host "Recommended next steps:"
    Write-Host "  1. Read docs/sp-overview.zh-CN.md or docs/sp-overview.en.md"
    Write-Host "  2. Review .specify/memory/constitution.md"
    Write-Host "  3. Start your first feature with sp.specify"
}
finally {
    Cleanup
}
