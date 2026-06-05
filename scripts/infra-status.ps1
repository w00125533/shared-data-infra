$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ComposeFiles = @(
    "compose.yaml",
    "compose.lakehouse.yaml",
    "compose.streaming.yaml",
    "compose.starrocks.yaml"
)

$ComposeArgs = @("compose")
foreach ($file in $ComposeFiles) {
    $path = Join-Path $RepoRoot $file
    if (Test-Path $path) {
        $ComposeArgs += @("-f", $path)
    }
}

Push-Location $RepoRoot
try {
    & docker @ComposeArgs ps
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
