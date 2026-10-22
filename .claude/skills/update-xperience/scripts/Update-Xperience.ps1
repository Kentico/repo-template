<#
.SYNOPSIS
    Updates Xperience by Kentico dependencies and regenerates examples/DancingGoat for a new version.

.DESCRIPTION
    Generates pristine DancingGoat projects for the current and target versions, then three-way merges:
    base = current pristine, ours = examples/DancingGoat, theirs = target pristine. Repository changes to
    DancingGoat (project references, settings, sample usage) carry over; template changes come in.
    Also updates Kentico NuGet versions, the dbmanager tool, and admin client npm dependencies.

    Exit codes: 0 = done, 2 = merge conflicts left in examples/DancingGoat (markers in files).

.EXAMPLE
    ./.claude/skills/update-xperience/scripts/Update-Xperience.ps1
    ./.claude/skills/update-xperience/scripts/Update-Xperience.ps1 -Version 31.10.0 -Preview
#>
[CmdletBinding()]
param (
    # Target Xperience version. Defaults to the latest stable Kentico.Xperience.Templates on nuget.org
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version,

    # Print current and target versions and exit without changing anything
    [switch]$Preview
)

$ErrorActionPreference = 'Stop'

$root = (git rev-parse --show-toplevel).Trim()
Set-Location $root

$propsPath = Join-Path $root 'Directory.Packages.props'
[xml]$props = Get-Content $propsPath -Raw
$current = ($props.Project.ItemGroup.PackageVersion | Where-Object { $_.Include -ieq 'Kentico.Xperience.WebApp' }).Version
if (-not $current) { throw 'Kentico.Xperience.WebApp version not found in Directory.Packages.props' }

if (-not $Version) {
    $Version = (Invoke-RestMethod 'https://api.nuget.org/v3-flatcontainer/kentico.xperience.templates/index.json').versions |
        Where-Object { $_ -match '^\d+\.\d+\.\d+$' } |
        Sort-Object { [version]$_ } |
        Select-Object -Last 1
}

Write-Host "Current: $current"
Write-Host "Target:  $Version"

if ($Preview) { return }
if ($current -eq $Version) {
    Write-Host 'Already on the target version.'
    return
}

$work = Join-Path ([IO.Path]::GetTempPath()) "xperience-update-$current-$Version"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory $work | Out-Null

function Invoke-Native([scriptblock]$command, [int[]]$AllowedExitCodes = @(0)) {
    $output = & $command 2>&1
    if ($AllowedExitCodes -notcontains $LASTEXITCODE) {
        $output | Write-Host
        throw "Command failed ($LASTEXITCODE): $command"
    }
}

function New-Pristine($templateVersion, $name) {
    # Private template hive per version: leaves the user's installed templates alone and avoids
    # "Sequence contains more than one matching element" when the global hive has duplicate entries
    $hive = Join-Path $work "$name-hive"
    Invoke-Native { dotnet new install "Kentico.Xperience.Templates@$templateVersion" --debug:custom-hive $hive }
    $dg = Join-Path $work "$name-dg"
    # 104: the skipped "dotnet tool restore" post action; the project is still created
    Invoke-Native { dotnet new kentico-xperience-sample-mvc -n DancingGoat -o $dg --no-restore --allow-scripts No --no-update-check --debug:custom-hive $hive } -AllowedExitCodes 0, 104
    $admin = Join-Path $work "$name-admin"
    Invoke-Native { dotnet new kentico-xperience-admin-sample -n Admin -o $admin --no-restore --no-update-check --debug:custom-hive $hive }
    return @{ DancingGoat = $dg; Admin = $admin }
}

# Removes files the repository keeps elsewhere and pins generated random values,
# so the merge only sees real template changes
function Step-Normalize($dg) {
    foreach ($item in 'Directory.Packages.props', '.github', '.claude', '.config', '.mcp.json') {
        $path = Join-Path $dg $item
        if (Test-Path $path) { Remove-Item $path -Recurse -Force }
    }
    $csproj = Join-Path $dg 'DancingGoat.csproj'
    (Get-Content $csproj -Raw) -replace '<UserSecretsId>[^<]+</UserSecretsId>', '<UserSecretsId>00000000-0000-0000-0000-000000000000</UserSecretsId>' |
        Set-Content $csproj -NoNewline
    foreach ($file in 'appsettings.Development.json', 'Properties/launchSettings.json') {
        $path = Join-Path $dg $file
        if (-not (Test-Path $path)) { continue }
        $c = Get-Content $path -Raw
        $c = $c -replace '"Secret": "[^"]*"', '"Secret": ""'
        $c = $c -replace '"Port": \d+', '"Port": 0'
        $c = $c -replace 'localhost:\d+', 'localhost:0'
        Set-Content $path $c -NoNewline
    }
}

Write-Host 'Generating pristine DancingGoat projects...'
$base = New-Pristine $current 'base'
$target = New-Pristine $Version 'target'

# Values the repository keeps at the root, read before normalizing
[xml]$targetProps = Get-Content (Join-Path $target.DancingGoat 'Directory.Packages.props') -Raw
$targetTools = Get-Content (Join-Path $target.DancingGoat '.config/dotnet-tools.json') -Raw | ConvertFrom-Json
$targetMcp = Join-Path $target.DancingGoat '.mcp.json'
$targetMcpCopy = Join-Path $work 'target.mcp.json'
if (Test-Path $targetMcp) { Copy-Item $targetMcp $targetMcpCopy }
$targetSkills = Join-Path $target.DancingGoat '.github/skills'
$targetSkillsCopy = Join-Path $work 'target-skills'
if (Test-Path $targetSkills) { Copy-Item $targetSkills $targetSkillsCopy -Recurse }

Step-Normalize $base.DancingGoat
Step-Normalize $target.DancingGoat

# Three-way merge in a scratch repository
$merge = Join-Path $work 'merge'
New-Item -ItemType Directory $merge | Out-Null
Push-Location $merge
try {
    function Sync-Tree($source) {
        Get-ChildItem $merge -Force | Where-Object Name -NE '.git' | Remove-Item -Recurse -Force
        robocopy $source $merge /E /XD bin obj node_modules .git /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $LASTEXITCODE" }
        Set-Content (Join-Path $merge '.gitattributes') '* text=auto eol=lf' -NoNewline
        git add -A --renormalize . 2>$null
        git add -A 2>$null
    }

    git init -q -b base
    git config core.autocrlf false
    git config user.name update-xperience
    git config user.email update-xperience@localhost

    Sync-Tree $base.DancingGoat
    git commit -q -m "pristine $current"

    git switch -q -c ours
    Sync-Tree (Join-Path $root 'examples/DancingGoat')
    git commit -q -m 'repository DancingGoat' --allow-empty

    git switch -q base
    git switch -q -c theirs
    Sync-Tree $target.DancingGoat
    git commit -q -m "pristine $Version" --allow-empty

    # Fresh checkout: files left on disk by Sync-Tree keep the template's CRLF endings and would
    # show as modified in the repository
    Get-ChildItem $merge -Force | Where-Object Name -NE '.git' | Remove-Item -Recurse -Force
    git checkout -q -f ours
    git merge -q --no-edit theirs 2>&1 | Out-Null
    $conflicts = @(git diff --name-only --diff-filter=U)
    Remove-Item (Join-Path $merge '.gitattributes') -Force -ErrorAction SilentlyContinue
}
finally {
    Pop-Location
}

# Replace examples/DancingGoat with the merge result (keeps ignored build output)
$dgPath = Join-Path $root 'examples/DancingGoat'
git -C $root ls-files -z -- examples/DancingGoat | ForEach-Object { $_ -split "`0" } | Where-Object { $_ } |
    ForEach-Object { Remove-Item (Join-Path $root $_) -Force }
robocopy $merge $dgPath /E /XD .git /XF .gitattributes /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $LASTEXITCODE" }
Get-ChildItem $dgPath -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending |
    Where-Object { -not (Get-ChildItem $_.FullName -Force) } | Remove-Item

# Root NuGet versions: every package the target DancingGoat pins, when the root also pins it
$propsText = [IO.File]::ReadAllText($propsPath)
foreach ($pv in $targetProps.Project.ItemGroup.PackageVersion) {
    $pattern = "(<PackageVersion Include=`"(?i:$([regex]::Escape($pv.Include)))`" Version=`")[^`"]+(`")"
    if ($propsText -match $pattern) {
        $propsText = $propsText -replace $pattern, "`${1}$($pv.Version)`${2}"
        Write-Host "NuGet $($pv.Include) -> $($pv.Version)"
    }
}
[IO.File]::WriteAllText($propsPath, $propsText)

# Root tool manifest: dbmanager and any other tool the target DancingGoat pins
$toolsPath = Join-Path $root '.config/dotnet-tools.json'
$toolsText = [IO.File]::ReadAllText($toolsPath)
foreach ($tool in $targetTools.tools.PSObject.Properties) {
    $pattern = "(`"$([regex]::Escape($tool.Name))`":\s*\{\s*`"version`":\s*`")[^`"]+(`")"
    if ($toolsText -match $pattern) {
        $toolsText = $toolsText -replace $pattern, "`${1}$($tool.Value.version)`${2}"
        Write-Host "Tool $($tool.Name) -> $($tool.Value.version)"
    }
}
[IO.File]::WriteAllText($toolsPath, $toolsText)

# Admin client npm dependencies shared with the target admin sample
$sample = Get-Content (Join-Path $target.Admin 'Client/package.json') -Raw | ConvertFrom-Json
Get-ChildItem (Join-Path $root 'src') -Recurse -Filter package.json -File |
    Where-Object { $_.FullName -notmatch 'node_modules' -and $_.Directory.Name -eq 'Client' } |
    ForEach-Object {
        $text = [IO.File]::ReadAllText($_.FullName)
        foreach ($section in 'dependencies', 'devDependencies') {
            if (-not $sample.$section) { continue }
            # Only inside this section's block, so "overrides" and other sections stay untouched
            $block = [regex]::Match($text, "`"$section`":\s*\{[^}]*\}")
            if (-not $block.Success) { continue }
            $updated = $block.Value
            foreach ($dep in $sample.$section.PSObject.Properties) {
                $pattern = "(`"$([regex]::Escape($dep.Name))`":\s*`")[^`"]+(`")"
                $updated = $updated -replace $pattern, "`${1}$($dep.Value)`${2}"
            }
            $text = $text.Remove($block.Index, $block.Length).Insert($block.Index, $updated)
        }
        [IO.File]::WriteAllText($_.FullName, $text)
        Write-Host "npm dependencies updated in $([IO.Path]::GetRelativePath($root, $_.FullName))"
    }

Write-Host ''
Write-Host "Updated $current -> $Version"
Write-Host "Work folder (pristine projects, merge repo): $work"
if (Test-Path $targetMcpCopy) {
    Write-Host "Target .mcp.json for comparison with the root .mcp.json: $targetMcpCopy"
}
if (Test-Path $targetSkillsCopy) {
    Write-Host "Target DancingGoat skills for comparison with the root .claude/skills: $targetSkillsCopy"
}

if ($conflicts.Count -gt 0) {
    Write-Host ''
    Write-Host 'Merge conflicts in examples/DancingGoat:' -ForegroundColor Yellow
    $conflicts | ForEach-Object { Write-Host "  $_" }
    exit 2
}

exit 0
