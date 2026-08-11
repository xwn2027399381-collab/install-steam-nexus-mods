[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$UnrealPakPath,

    [ValidateRange(1, 4096)]
    [int]$MaxFallbackSizeMB = 256
)

$resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
$pakFiles = if ((Get-Item -LiteralPath $resolved).PSIsContainer) {
    Get-ChildItem -LiteralPath $resolved -Recurse -File -Filter '*.pak'
} else {
    Get-Item -LiteralPath $resolved
}

if (-not $UnrealPakPath) {
    $command = Get-Command 'UnrealPak.exe' -ErrorAction SilentlyContinue
    if ($command) {
        $UnrealPakPath = $command.Source
    }
}

$assetPattern = '(?i)(?:\.\./){0,8}[A-Za-z0-9_ .()\-\\/]{3,240}\.(?:uasset|uexp|ubulk|umap|ini|locres)'

foreach ($pak in $pakFiles) {
    $hints = @()
    $method = 'readable-index-fallback'

    if ($UnrealPakPath -and (Test-Path -LiteralPath $UnrealPakPath)) {
        $method = 'UnrealPak'
        $listing = & $UnrealPakPath $pak.FullName -List 2>&1
        $hints = $listing | ForEach-Object {
            [regex]::Matches([string]$_, $assetPattern) | ForEach-Object { $_.Value }
        }
    } elseif ($pak.Length -le ($MaxFallbackSizeMB * 1MB)) {
        $bytes = [System.IO.File]::ReadAllBytes($pak.FullName)
        $text = [System.Text.Encoding]::ASCII.GetString($bytes)
        $hints = [regex]::Matches($text, $assetPattern) | ForEach-Object { $_.Value }
    } else {
        $method = 'skipped-size-limit'
    }

    $hints = @($hints | ForEach-Object { $_ -replace '\\', '/' } | Sort-Object -Unique)
    if ($hints.Count -eq 0) {
        [pscustomobject]@{
            Pak       = $pak.FullName
            Bytes     = $pak.Length
            Method    = $method
            AssetPath = $null
        }
        continue
    }

    foreach ($hint in $hints) {
        [pscustomobject]@{
            Pak       = $pak.FullName
            Bytes     = $pak.Length
            Method    = $method
            AssetPath = $hint
        }
    }
}
