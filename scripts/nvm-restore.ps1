if (-not (Test-Path .nvm-prev)) {
    Write-Host "No saved version found (.nvm-prev)." -ForegroundColor Red
    exit 1
}

$version = (Get-Content .nvm-prev).Trim()
Remove-Item .nvm-prev
nvm use $version
