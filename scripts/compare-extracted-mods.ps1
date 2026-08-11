[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RootDirectory,

    [string]$ContentRootName = 'natives',

    [switch]$FailOnConflict,

    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $RootDirectory).Path
$mods = @(Get-ChildItem -LiteralPath $root -Directory | Sort-Object Name)

if (-not $mods) {
    throw "No extracted mod directories found in: $root"
}

$rows = [System.Collections.Generic.List[object]]::new()
$missingRoots = [System.Collections.Generic.List[string]]::new()

foreach ($mod in $mods) {
    $candidateRoots = @()
    if ($mod.Name -ieq $ContentRootName) {
        $candidateRoots += $mod
    }
    $candidateRoots += @(Get-ChildItem -LiteralPath $mod.FullName -Directory -Recurse |
        Where-Object { $_.Name -ieq $ContentRootName })

    $candidateRoots = @($candidateRoots | Sort-Object FullName -Unique)
    if ($candidateRoots.Count -eq 0) {
        $missingRoots.Add($mod.Name)
        continue
    }
    if ($candidateRoots.Count -gt 1) {
        throw "Multiple '$ContentRootName' roots found for '$($mod.Name)'. Select one variant before comparing."
    }

    $contentRoot = $candidateRoots[0].FullName
    foreach ($file in Get-ChildItem -LiteralPath $contentRoot -File -Recurse) {
        $relative = $file.FullName.Substring($contentRoot.Length).TrimStart('\', '/')
        $destination = ($ContentRootName + '/' + ($relative -replace '\\', '/')).ToLowerInvariant()
        $rows.Add([PSCustomObject]@{
            Destination = $destination
            Mod = $mod.Name
            Source = $file.FullName
            Bytes = $file.Length
        })
    }
}

$conflicts = @($rows |
    Group-Object Destination |
    Where-Object { @($_.Group.Mod | Sort-Object -Unique).Count -gt 1 } |
    ForEach-Object {
        [PSCustomObject]@{
            Destination = $_.Name
            Mods = @($_.Group.Mod | Sort-Object -Unique)
            Sources = @($_.Group.Source)
        }
    })

$result = [PSCustomObject]@{
    RootDirectory = $root
    ContentRootName = $ContentRootName
    ModCount = $mods.Count
    FileCount = $rows.Count
    MissingContentRoots = @($missingRoots)
    ConflictCount = $conflicts.Count
    Conflicts = $conflicts
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
}
else {
    $result |
        Select-Object RootDirectory, ContentRootName, ModCount, FileCount,
            @{Name='MissingRoots'; Expression={$_.MissingContentRoots.Count}},
            ConflictCount |
        Format-List

    if ($conflicts) {
        $conflicts |
            Select-Object Destination,
                @{Name='Mods'; Expression={$_.Mods -join ' | '}} |
            Format-Table -AutoSize
    }
}

if ($FailOnConflict -and $conflicts.Count -gt 0) {
    exit 2
}
