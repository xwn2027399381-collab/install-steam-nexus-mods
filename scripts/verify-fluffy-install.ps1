[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ManagerGameDirectory,

    [Parameter(Mandatory = $true)]
    [string]$GameDirectory,

    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$managerRoot = (Resolve-Path -LiteralPath $ManagerGameDirectory).Path
$gameRoot = (Resolve-Path -LiteralPath $GameDirectory).Path
$installedPath = Join-Path $managerRoot 'installed.ini'
$modsRoot = Join-Path $managerRoot 'Mods'

if (-not (Test-Path -LiteralPath $installedPath -PathType Leaf)) {
    throw "Missing Fluffy installed.ini: $installedPath"
}
if (-not (Test-Path -LiteralPath $modsRoot -PathType Container)) {
    throw "Missing Fluffy Mods directory: $modsRoot"
}

$sections = [System.Collections.Generic.List[object]]::new()
$current = $null

foreach ($line in Get-Content -LiteralPath $installedPath) {
    if ($line -match '^\[(.+)\]$') {
        $current = [PSCustomObject]@{
            Folder = $Matches[1]
            ModName = $Matches[1]
            Files = [System.Collections.Generic.List[string]]::new()
        }
        $sections.Add($current)
        continue
    }
    if ($null -eq $current) {
        continue
    }
    if ($line -match '^ModName=(.*)$') {
        $current.ModName = $Matches[1]
    }
    elseif ($line -match '^file=(.*)$') {
        $current.Files.Add($Matches[1])
    }
}

$owners = @{}
$missingSource = [System.Collections.Generic.List[object]]::new()

foreach ($section in $sections) {
    $modRoot = Join-Path $modsRoot $section.Folder
    foreach ($relative in $section.Files) {
        $normalized = $relative -replace '/', '\'
        $source = Join-Path $modRoot $normalized
        $key = $normalized.ToLowerInvariant()
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            $missingSource.Add([PSCustomObject]@{
                Mod = $section.ModName
                RelativePath = $normalized
                ExpectedSource = $source
            })
            continue
        }
        $owners[$key] = [PSCustomObject]@{
            Mod = $section.ModName
            RelativePath = $normalized
            Source = $source
        }
    }
}

$missingDestination = [System.Collections.Generic.List[object]]::new()
$hashMismatch = [System.Collections.Generic.List[object]]::new()
$verified = 0

foreach ($owner in $owners.Values) {
    $destination = Join-Path $gameRoot $owner.RelativePath
    if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
        $missingDestination.Add([PSCustomObject]@{
            Mod = $owner.Mod
            RelativePath = $owner.RelativePath
            ExpectedDestination = $destination
        })
        continue
    }

    $sourceHash = (Get-FileHash -LiteralPath $owner.Source -Algorithm SHA256).Hash
    $destinationHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    if ($sourceHash -ne $destinationHash) {
        $hashMismatch.Add([PSCustomObject]@{
            Mod = $owner.Mod
            RelativePath = $owner.RelativePath
            SourceHash = $sourceHash
            DestinationHash = $destinationHash
        })
        continue
    }
    $verified++
}

$recordedReferences = ($sections | ForEach-Object { $_.Files.Count } | Measure-Object -Sum).Sum
$result = [PSCustomObject]@{
    ManagerGameDirectory = $managerRoot
    GameDirectory = $gameRoot
    InstalledSectionCount = $sections.Count
    InstalledMods = @($sections | ForEach-Object ModName)
    RecordedFileReferences = $recordedReferences
    UniqueDestinationFiles = $owners.Count
    VerifiedFiles = $verified
    MissingSourceCount = $missingSource.Count
    MissingDestinationCount = $missingDestination.Count
    HashMismatchCount = $hashMismatch.Count
    MissingSources = @($missingSource)
    MissingDestinations = @($missingDestination)
    HashMismatches = @($hashMismatch)
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
}
else {
    $result |
        Select-Object InstalledSectionCount, RecordedFileReferences,
            UniqueDestinationFiles, VerifiedFiles, MissingSourceCount,
            MissingDestinationCount, HashMismatchCount |
        Format-List

    $sections |
        Select-Object ModName, @{Name='RecordedFiles'; Expression={$_.Files.Count}} |
        Format-Table -AutoSize
}

if ($missingSource.Count -gt 0 -or
    $missingDestination.Count -gt 0 -or
    $hashMismatch.Count -gt 0) {
    exit 2
}
