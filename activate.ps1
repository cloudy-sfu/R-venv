# PowerShell 7
param(
    [Parameter(Mandatory)]
    [string]$Path
)
$resolvedPath = [System.IO.Path]::GetFullPath($Path, (Get-Location).Path)
$env:R_LIBS_USER = $resolvedPath
Write-Host "Virtual environment $resolvedPath activated."