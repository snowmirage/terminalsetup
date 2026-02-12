#Requires -Version 5.1
# ==========================================================================
# Terminal Setup — Deployment Script (Windows 11)
# Deploys: wezterm.lua, starship.toml, PowerShell profile
# Repeatable: re-run after pulling updates to refresh configs
# ==========================================================================

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupDir = "$HOME\.config-backups\terminalsetup\$Timestamp"
$BackupsMade = $false

# ========================= HELPERS =========================

function Write-Info    { param([string]$Msg) Write-Host "[INFO] $Msg" -ForegroundColor Blue }
function Write-Ok      { param([string]$Msg) Write-Host "[ OK ] $Msg" -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host "[WARN] $Msg" -ForegroundColor Yellow }
function Write-Err     { param([string]$Msg) Write-Host "[ERR ] $Msg" -ForegroundColor Red }
function Write-Header  { param([string]$Msg) Write-Host "`n--- $Msg ---`n" -ForegroundColor Cyan }

function Prompt-Continue {
    param([string]$Message = "Press Enter to continue, or Ctrl+C to abort...")
    Write-Host "  $Message" -ForegroundColor DarkGray -NoNewline
    Read-Host
}

function Prompt-YN {
    param([string]$Message)
    $answer = Read-Host "  $Message [y/N]"
    return $answer -match '^[Yy]'
}

function Test-CommandExists {
    param([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# ========================= PREREQUISITES =========================

function Check-Prerequisites {
    Write-Header "Checking Prerequisites"

    # PowerShell 7
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-Ok "PowerShell 7+ detected (v$($PSVersionTable.PSVersion))"
    } else {
        Write-Warn "Running Windows PowerShell $($PSVersionTable.PSVersion)"
        Write-Info "PowerShell 7 is recommended for best experience"
        Write-Info "Install with: winget install Microsoft.PowerShell"
        if (Prompt-YN "Install PowerShell 7 via winget?") {
            winget install Microsoft.PowerShell
        }
    }

    # WezTerm
    if (Test-CommandExists "wezterm") {
        Write-Ok "WezTerm is installed"
    } else {
        Write-Warn "WezTerm is not installed"
        Write-Info "Install with: winget install wez.wezterm"
        if (Prompt-YN "Install WezTerm via winget?") {
            winget install wez.wezterm
        }
    }

    # Starship
    if (Test-CommandExists "starship") {
        Write-Ok "Starship is installed"
    } else {
        Write-Warn "Starship is not installed"
        Write-Info "Install with: winget install Starship.Starship"
        if (Prompt-YN "Install Starship via winget?") {
            winget install Starship.Starship
        }
    }

    # Git
    if (Test-CommandExists "git") {
        Write-Ok "Git is installed"
    } else {
        Write-Warn "Git is not installed"
        Write-Info "Install with: winget install Git.Git"
        if (Prompt-YN "Install Git via winget?") {
            winget install Git.Git
        }
    }

    # Font reminder
    Write-Host ""
    Write-Info "JetBrainsMono Nerd Font is required for icons."
    Write-Info "Download from: https://www.nerdfonts.com/font-downloads"
    Write-Info "Install all .ttf files: right-click -> 'Install for all users'"
    Prompt-Continue
}

# ========================= BACKUP & CUSTOM DETECTION =========================

function Detect-CustomAdditions {
    param(
        [string]$ProjectFile,
        [string]$ExistingFile,
        [string]$DisplayName
    )

    if (-not (Test-Path $ExistingFile)) { return }

    $projectLines = Get-Content $ProjectFile
    $existingLines = Get-Content $ExistingFile

    # Find lines in existing file that aren't in our project file
    $customLines = $existingLines | Where-Object {
        $line = $_
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed)) { return $false }
        return $projectLines -notcontains $line
    }

    if ($null -eq $customLines -or $customLines.Count -eq 0) { return }

    Write-Host ""
    Write-Warn "================================================================"
    Write-Warn " $($customLines.Count) line(s) in existing $DisplayName NOT in this project"
    Write-Warn "================================================================"
    Write-Host ""
    Write-Info "These may be custom additions from other programs or manual edits:"
    Write-Host ""

    $customLines | Select-Object -First 50 | ForEach-Object {
        Write-Host "  | $_" -ForegroundColor DarkGray
    }

    if ($customLines.Count -gt 50) {
        Write-Info "  ... and $($customLines.Count - 50) more lines (see backup for full file)"
    }

    $backupFile = Join-Path $BackupDir (Split-Path -Leaf $ExistingFile)
    Write-Host ""
    Write-Info "If any of these are important (e.g., PATH additions, tool integrations),"
    Write-Info "re-add them to the new config after deployment."
    Write-Info "Your backup is at: $backupFile"
    Prompt-Continue
}

function Backup-AndDeploy {
    param(
        [string]$SourceName,
        [string]$Destination,
        [string]$DisplayName
    )

    $Source = Join-Path $ScriptDir $SourceName

    if (-not (Test-Path $Source)) {
        Write-Err "Source file not found: $Source"
        return
    }

    # Create destination directory
    $destDir = Split-Path -Parent $Destination
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }

    # Backup existing file
    if (Test-Path $Destination) {
        if (-not (Test-Path $BackupDir)) {
            New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
        }
        $backupFile = Join-Path $BackupDir (Split-Path -Leaf $Destination)
        Copy-Item $Destination $backupFile
        $script:BackupsMade = $true
        Write-Info "Backed up existing $DisplayName"
        Write-Info "  Backup location: $backupFile"

        # Check for custom additions
        Detect-CustomAdditions -ProjectFile $Source -ExistingFile $Destination -DisplayName $DisplayName
    } else {
        Write-Info "No existing $DisplayName found (first-time deployment)"
    }

    # Deploy
    Copy-Item $Source $Destination -Force
    Write-Ok "Deployed: $DisplayName -> $Destination"
}

# ========================= MAIN =========================

function Main {
    Write-Host ""
    Write-Host "+=================================================+" -ForegroundColor Cyan
    Write-Host "|       Terminal Setup - Deployment Script         |" -ForegroundColor Cyan
    Write-Host "|       Windows 11                                 |" -ForegroundColor Cyan
    Write-Host "+=================================================+" -ForegroundColor Cyan
    Write-Host ""

    Check-Prerequisites

    Write-Header "Deploying Configuration Files"

    # WezTerm config
    Backup-AndDeploy "wezterm.lua" "$HOME\.config\wezterm\wezterm.lua" "wezterm.lua (terminal config)"
    Write-Host ""

    # Starship config
    Backup-AndDeploy "starship.toml" "$HOME\.config\starship.toml" "starship.toml (prompt config)"
    Write-Host ""

    # PowerShell profile
    $profilePath = $PROFILE
    Backup-AndDeploy "powershell_profile.ps1" $profilePath "PowerShell profile ($profilePath)"
    Write-Host ""

    # Summary
    Write-Header "Deployment Complete"

    if ($BackupsMade) {
        Write-Info "Backups saved to: $BackupDir"
        Write-Host ""
        Get-ChildItem $BackupDir | Format-Table Name, Length, LastWriteTime -AutoSize
    }

    Write-Ok "Configuration files deployed successfully!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Info "  1. Close and reopen WezTerm to apply changes"
    Write-Info "  2. Verify: starship --version"
    Write-Info "  3. Verify: echo `$env:TERM_PROGRAM  (should print WezTerm)"
    Write-Host ""
    Write-Info "WSL users: Run 'bash deploy.sh' inside WSL to deploy .zshrc and starship.toml"
    Write-Host ""
}

Main
