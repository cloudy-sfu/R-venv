# PowerShell 7
$renvironFile = ".Renviron"

if (-not (Test-Path $renvironFile)) {
    Write-Error "No .Renviron file found in current directory."
    exit 1
}

$lines = Get-Content $renvironFile | Where-Object { $_ -notmatch '^R_LIBS_USER=' }

if ($lines.Count -eq 0 -or ($lines -join '').Trim() -eq '') {
    Remove-Item $renvironFile
} else {
    $lines | Set-Content $renvironFile -Encoding UTF8
}

Write-Host "Virtual environment deactivated."
