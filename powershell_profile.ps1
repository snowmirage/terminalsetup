# Version: v1.0
# Date: 2026-02-12
# ==========================================================================
# PowerShell Profile — Terminal Setup Project
# Deployed to: $PROFILE
# ==========================================================================

# Shell version for Starship prompt indicator (shows PS7 or PS5)
$env:PS_VERSION = "PS$($PSVersionTable.PSVersion.Major)"

# Starship prompt
Invoke-Expression (&starship init powershell)

# PSReadLine enhancements (history-based autocomplete)
# PredictionSource/PredictionViewStyle require PSReadLine 2.2+ (ships with PowerShell 7)
if ((Get-Module PSReadLine).Version -ge [version]"2.2.0") {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
