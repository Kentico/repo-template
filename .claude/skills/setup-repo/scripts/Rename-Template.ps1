<#
.SYNOPSIS
    Renames the repository template's sentinel tokens, files, and folders for a new project.

.DESCRIPTION
    One-time setup step. Replaces every template token (see ../references/naming.md)
    in tracked text files, renames files and folders, and regenerates
    local-only secrets and ports. Fails if any template token remains afterwards.

.EXAMPLE
    ./.claude/skills/setup-repo/scripts/Rename-Template.ps1 -Family Labs -Name CoolThing [-Example]
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet('Kentico', 'Labs', 'Community')]
    [string]$Family,

    # PascalCase identifier, no spaces or periods, e.g. CoolThing
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Z][A-Za-z0-9]*$')]
    [string]$Name,

    # Human-readable name with spaces, e.g. "Cool Thing". Defaults to Name split on word boundaries
    [string]$DisplayName,

    # Example source code repository (not a published library). Labs examples get "labs" in the repository slug
    [switch]$Example,

    # Defaults to xperience-by-kentico-<name> (Labs example: xperience-by-kentico-labs-<name>; Community: xperience-community-<name>)
    [ValidatePattern('^[a-z0-9][a-z0-9-]*$')]
    [string]$RepoSlug,

    # Defaults to Kentico; required for Community
    [string]$GitHubOrg,

    # Print the derived names and exit without changing files
    [switch]$Preview
)

$ErrorActionPreference = 'Stop'

$root = (git rev-parse --show-toplevel).Trim()
Set-Location $root

$kebab = ($Name -creplace '(?<=[a-z])(?=[A-Z])|(?<=[A-Z0-9])(?=[A-Z][a-z])', '-').ToLowerInvariant()

$names = switch ($Family) {
    'Kentico' { @{ DotNet = "Kentico.Xperience.$Name"; AdminOrg = 'kentico'; AdminProject = "xperience-$kebab-admin"; Slug = "xperience-by-kentico-$kebab" } }
    'Labs' { @{ DotNet = "Kentico.Xperience.Labs.$Name"; AdminOrg = 'kentico'; AdminProject = "xperience-labs-$kebab-admin"; Slug = "xperience-by-kentico-$kebab" } }
    'Community' { @{ DotNet = "XperienceCommunity.$Name"; AdminOrg = 'xperience'; AdminProject = "community-$kebab-admin"; Slug = "xperience-community-$kebab" } }
}

if ($Example -and $Family -eq 'Labs') { $names.Slug = "xperience-by-kentico-labs-$kebab" }
if ($RepoSlug) { $names.Slug = $RepoSlug }

if (-not $GitHubOrg) {
    if ($Family -eq 'Community') { throw 'GitHubOrg is required for the Community family.' }
    $GitHubOrg = 'Kentico'
}

if (-not $DisplayName) { $DisplayName = $Name -creplace '(?<=[a-z])(?=[A-Z])|(?<=[A-Z0-9])(?=[A-Z][a-z])', ' ' }
$productPrefix = switch ($Family) {
    'Kentico' { 'Xperience by Kentico' }
    'Labs' { 'Xperience by Kentico Labs' }
    'Community' { 'Xperience Community' }
}

$dotNet = $names.DotNet
$moduleKey = "$($names.AdminOrg)-$($names.AdminProject)"

function Write-Names {
    Write-Host "Family:        $Family$(if ($Example) { ' (example)' })"
    Write-Host ".NET name:     $dotNet (+ $dotNet.Admin, $dotNet.Tests)"
    Write-Host "Repository:    $GitHubOrg/$($names.Slug)"
    Write-Host "Admin module:  $moduleKey"
    Write-Host "Product name:  $productPrefix`: $DisplayName"
}

if ($Preview) {
    Write-Names
    return
}

# Ordered most-specific first; later tokens are substrings of earlier ones
$tokens = @(
    , @('Kentico/xperience-by-kentico-repotemplate', "$GitHubOrg/$($names.Slug)")
    , @('xperience-by-kentico-repotemplate', $names.Slug)
    , @('"@kentico/xperience-repotemplate-admin', "`"@$($names.AdminOrg)/$($names.AdminProject)")
    , @('RegisterClientModule("kentico", "xperience-repotemplate-admin")', "RegisterClientModule(`"$($names.AdminOrg)`", `"$($names.AdminProject)`")")
    , @("orgName: 'kentico'", "orgName: '$($names.AdminOrg)'")
    , @('<AdminOrgName>kentico</AdminOrgName>', "<AdminOrgName>$($names.AdminOrg)</AdminOrgName>")
    , @('kentico-xperience-repotemplate-admin', $moduleKey)
    , @('xperience-repotemplate-admin', $names.AdminProject)
    , @('Kentico-Xperience-RepoTemplate', $dotNet.Replace('.', '-'))
    , @('Kentico.Xperience.RepoTemplate', $dotNet)
    , @('kentico.xperience.repotemplate', $dotNet.ToLowerInvariant())
    , @('Xperience by Kentico: Repo Template', "$productPrefix`: $DisplayName")
    , @('Repo Template', $DisplayName)
    , @('RepoTemplate', $Name)
    , @('repotemplate', $kebab)
)

$textExtensions = @(
    '.cs', '.csproj', '.props', '.targets', '.slnx', '.sln', '.json', '.yml', '.yaml', '.md',
    '.js', '.mjs', '.ts', '.tsx', '.css', '.cshtml', '.razor', '.ps1', '.xml', '.config', '.txt'
)
$textNames = @('.editorconfig', '.gitignore', '.gitattributes', 'CODEOWNERS')

# Template-only material that is not renamed: planning docs and this skill
$excluded = '^(\.agent-resources|\.claude/skills/setup-repo)/'

function Get-TemplateFiles {
    git ls-files --cached --others --exclude-standard |
        Where-Object { $_ -notmatch $excluded -and (Test-Path -LiteralPath $_ -PathType Leaf) } |
        Where-Object { $textExtensions -contains [IO.Path]::GetExtension($_) -or $textNames -contains [IO.Path]::GetFileName($_) }
}

# 1. Remove template-only CI
$smokeWorkflow = Join-Path $root '.github/workflows/template-smoke.yml'
if (Test-Path $smokeWorkflow) {
    Remove-Item $smokeWorkflow
    Write-Host 'Removed .github/workflows/template-smoke.yml'
}

# 2. Replace tokens in file contents (case-sensitive, ordered)
foreach ($file in Get-TemplateFiles) {
    $content = [IO.File]::ReadAllText((Join-Path $root $file))
    $updated = $content
    foreach ($token in $tokens) {
        $updated = $updated.Replace($token[0], $token[1])
    }
    if ($updated -cne $content) {
        [IO.File]::WriteAllText((Join-Path $root $file), $updated)
        Write-Host "Updated $file"
    }
}

# 3. Rename files and folders, deepest first
$paths = git ls-files --cached --others --exclude-standard |
    Where-Object { $_ -notmatch $excluded } |
    ForEach-Object {
        $parts = $_ -split '/'
        for ($i = 1; $i -le $parts.Length; $i++) { ($parts[0..($i - 1)] -join '/') }
    } |
    Sort-Object -Unique |
    Where-Object { (Split-Path $_ -Leaf) -cmatch 'RepoTemplate' } |
    Sort-Object { ($_ -split '/').Length } -Descending

foreach ($path in $paths) {
    $leaf = Split-Path $path -Leaf
    $newLeaf = $leaf.Replace('Kentico.Xperience.RepoTemplate', $dotNet).Replace('RepoTemplate', $Name)
    if (Test-Path -LiteralPath $path) {
        Rename-Item -LiteralPath $path -NewName $newLeaf
        Write-Host "Renamed $path -> $newLeaf"
    }
}

# 4. Regenerate local-only secrets, ports, and license year
$dg = 'examples/DancingGoat'
$appPort = Get-Random -Minimum 40000 -Maximum 60000
$clientPort = Get-Random -Minimum 3010 -Maximum 3100
$secret = "mcp_secret_$([guid]::NewGuid().ToString().ToUpperInvariant())"

function Update-File($path, [scriptblock]$transform) {
    $full = Join-Path $root $path
    if (-not (Test-Path $full)) { return }
    $content = [IO.File]::ReadAllText($full)
    [IO.File]::WriteAllText($full, (& $transform $content))
}

foreach ($project in "$dg/DancingGoat.csproj", 'examples/AppHost/AppHost.csproj') {
    Update-File $project { param($c) $c -replace '<UserSecretsId>[^<]+</UserSecretsId>', "<UserSecretsId>$([guid]::NewGuid())</UserSecretsId>" }
}

# Aspire dashboard / resource service / OTLP ports: each committed port gets one new random port
Update-File 'examples/AppHost/Properties/launchSettings.json' {
    param($c)
    $portMap = @{}
    [regex]::Replace($c, 'localhost:(\d+)', {
            param($match)
            $old = $match.Groups[1].Value
            if (-not $portMap.ContainsKey($old)) { $portMap[$old] = Get-Random -Minimum 15000 -Maximum 25000 }
            "localhost:$($portMap[$old])"
        })
}
Update-File "$dg/appsettings.Development.json" {
    param($c)
    $c = $c -replace '"Secret": "[^"]*"', "`"Secret`": `"$secret`""
    $c = $c -replace '(?s)("ManagementApi":\s*\{\s*"Port":\s*)\d+', "`${1}$appPort"
    $c = $c -replace '"ServiceDomain": "localhost:\d+"', "`"ServiceDomain`": `"localhost:$appPort`""
    $c -replace "(?s)(`"$([regex]::Escape($moduleKey))`":\s*\{[^}]*`"Port`":\s*)\d+", "`${1}$clientPort"
}
Update-File 'LICENSE.md' { param($c) $c -replace 'Copyright \(c\) \d{4}', "Copyright (c) $((Get-Date).Year)" }
Update-File "$dg/Properties/launchSettings.json" { param($c) $c -replace 'http://localhost:\d+', "http://localhost:$appPort" }
Update-File '.mcp.json' {
    param($c)
    $c = $c -replace '"MANAGEMENT_API_SECRET": "[^"]*"', "`"MANAGEMENT_API_SECRET`": `"$secret`""
    $c -replace 'http://localhost:\d+/kentico-api', "http://localhost:$appPort/kentico-api"
}
Get-ChildItem src -Recurse -Filter webpack.config.js -File | Where-Object FullName -NotMatch 'node_modules' | ForEach-Object {
    Update-File ([IO.Path]::GetRelativePath($root, $_.FullName)) { param($c) $c -replace 'port: \d+', "port: $clientPort" }
}

# 5. Verify no template tokens remain
$leftovers = Get-TemplateFiles | ForEach-Object {
    if ((Split-Path $_ -Leaf) -match '(?i)repo[- ]?template') { "$_ (path)" }
    Select-String -LiteralPath $_ -Pattern '(?i)repo[- ]?template' | ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
}

Write-Host ''
Write-Names
Write-Host "Ports:         app $appPort, admin client $clientPort"

if ($leftovers) {
    Write-Host ''
    Write-Host 'Template tokens remain:' -ForegroundColor Red
    $leftovers | ForEach-Object { Write-Host "  $_" }
    exit 1
}
