[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ArchiveDirectory,

    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ArchiveDirectory).Path
$supported = @('.zip', '.rar', '.7z')
$archives = @(Get-ChildItem -LiteralPath $root -File |
    Where-Object { $supported -contains $_.Extension.ToLowerInvariant() } |
    Sort-Object Name)

if (-not $archives) {
    throw "No supported archives found in: $root"
}

function Get-ArchiveEntries {
    param([System.IO.FileInfo]$Archive)

    if ($Archive.Extension -ieq '.zip') {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Archive.FullName)
        try {
            return @($zip.Entries | ForEach-Object {
                [PSCustomObject]@{
                    Path = $_.FullName
                    IsDirectory = [string]::IsNullOrEmpty($_.Name)
                }
            })
        }
        finally {
            $zip.Dispose()
        }
    }

    $paths = @(& tar -tf $Archive.FullName 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to list $($Archive.Name): $($paths -join ' ')"
    }
    $verbose = @(& tar -tvf $Archive.FullName 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to inspect entry types for $($Archive.Name): $($verbose -join ' ')"
    }
    if ($paths.Count -ne $verbose.Count) {
        throw "Archive entry count mismatch for $($Archive.Name)"
    }

    return @(for ($i = 0; $i -lt $paths.Count; $i++) {
        [PSCustomObject]@{
            Path = $paths[$i]
            IsDirectory = $verbose[$i].StartsWith('d')
        }
    })
}

$results = foreach ($archive in $archives) {
    try {
        $entries = @(Get-ArchiveEntries -Archive $archive)
        $files = @($entries | Where-Object { -not $_.IsDirectory -and $_.Path })
        $normalized = @($files | ForEach-Object { $_.Path -replace '\\', '/' })
        $unsafe = @($normalized | Where-Object {
            $_ -match '(^|/)\.\.(/|$)' -or $_ -match '^/' -or $_ -match '^[A-Za-z]:'
        })
        $code = @($normalized | Where-Object {
            [IO.Path]::GetExtension($_).ToLowerInvariant() -in
                @('.exe', '.dll', '.asi', '.bat', '.cmd', '.ps1', '.msi', '.com', '.scr')
        })
        $pak = @($normalized | Where-Object { $_.ToLowerInvariant().EndsWith('.pak') })
        $ucas = @($normalized | Where-Object { $_.ToLowerInvariant().EndsWith('.ucas') })
        $utoc = @($normalized | Where-Object { $_.ToLowerInvariant().EndsWith('.utoc') })
        $modInfo = @($normalized | Where-Object { $_ -match '(?i)(^|/)modinfo\.ini$' })
        $topRoots = @($normalized | ForEach-Object { $_.Split('/')[0] } | Sort-Object -Unique)
        $hasUnrealSet = ($pak.Count + $ucas.Count + $utoc.Count) -gt 0

        [PSCustomObject]@{
            Archive = $archive.Name
            Bytes = $archive.Length
            SHA256 = (Get-FileHash -LiteralPath $archive.FullName -Algorithm SHA256).Hash
            Files = $files.Count
            TopLevelRoots = $topRoots
            ModInfoFiles = $modInfo
            Pak = $pak.Count
            Ucas = $ucas.Count
            Utoc = $utoc.Count
            UnrealSetBalanced = if ($hasUnrealSet) {
                $pak.Count -eq $ucas.Count -and $ucas.Count -eq $utoc.Count
            } else {
                $null
            }
            ExecutableContent = $code
            UnsafePaths = $unsafe
            Entries = $normalized
            Error = $null
        }
    }
    catch {
        [PSCustomObject]@{
            Archive = $archive.Name
            Bytes = $archive.Length
            SHA256 = $null
            Files = 0
            TopLevelRoots = @()
            ModInfoFiles = @()
            Pak = 0
            Ucas = 0
            Utoc = 0
            UnrealSetBalanced = $null
            ExecutableContent = @()
            UnsafePaths = @()
            Entries = @()
            Error = $_.Exception.Message
        }
    }
}

if ($Json) {
    $results | ConvertTo-Json -Depth 6
}
else {
    $results |
        Select-Object Archive, Bytes, Files,
            @{Name='Roots'; Expression={$_.TopLevelRoots.Count}},
            @{Name='ModInfo'; Expression={$_.ModInfoFiles.Count}},
            Pak, Ucas, Utoc, UnrealSetBalanced,
            @{Name='CodeFiles'; Expression={$_.ExecutableContent.Count}},
            @{Name='UnsafePaths'; Expression={$_.UnsafePaths.Count}},
            Error |
        Format-Table -AutoSize
}

$failed = @($results | Where-Object {
    $_.Error -or @($_.UnsafePaths).Count -gt 0
})

if ($failed.Count -gt 0) {
    exit 2
}
