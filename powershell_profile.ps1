# Version: v1.0
# Date: 2026-02-12
# ==========================================================================
# PowerShell Profile — Terminal Setup Project
# Deployed to: $PROFILE
# ==========================================================================

# Starship prompt
Invoke-Expression (&starship init powershell)

# PSReadLine enhancements (history-based autocomplete)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
