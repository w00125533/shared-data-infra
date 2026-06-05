param(
    [string[]]$Profiles = @("lakehouse")
)

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

$NormalizedProfiles = @(
    foreach ($profile in $Profiles) {
        foreach ($part in ($profile -split ",")) {
            $part.Trim()
        }
    }
) | Where-Object { $_ }

foreach ($profile in $NormalizedProfiles) {
    $ComposeArgs += @("--profile", $profile)
}

Push-Location $RepoRoot
try {
    & docker @ComposeArgs up -d
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    & docker @ComposeArgs ps
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
