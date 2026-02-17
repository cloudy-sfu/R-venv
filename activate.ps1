# PowerShell 7
param(
    [string]$Path = ".venv"
)

$resolvedPath = [System.IO.Path]::GetFullPath($Path, (Get-Location).Path)
if (-not (Test-Path $resolvedPath -PathType Container)) {
    Write-Error "Error: Path '$Path' does not exist."
    exit 1
}

$renvironFile = ".Renviron"
$newLine = "R_LIBS_USER=`"$resolvedPath`""

if (Test-Path $renvironFile) {
    $lines = Get-Content $renvironFile | Where-Object { $_ -notmatch '^R_LIBS_USER=' }
    $lines = @($lines) + $newLine
    $lines | Set-Content $renvironFile -Encoding UTF8
} else {
    $newLine | Set-Content $renvironFile -Encoding UTF8
}

# Ensure trailing newline (Set-Content adds one by default in PS7)
Write-Host "Virtual environment $resolvedPath activated."
