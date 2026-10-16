<#
.SYNOPSIS
    Creates the DancingGoat database with kentico-xperience-dbmanager.

.DESCRIPTION
    Defaults come from the CMSConnectionString in examples/DancingGoat/appsettings.json.
    dbmanager writes the connection string and a new CMSHashStringSalt to that file; the script then
    moves both into DancingGoat's user secrets and restores appsettings.json, so nothing local is
    committed. In CI (CI environment variable set) or with -NoUserSecrets, appsettings.json keeps
    the values instead: user secrets only load in the Development environment.

    Without a license file the database is still created; add the license on first sign-in
    to the administration (/admin, user "administrator").

.EXAMPLE
    ./scripts/Initialize-Database.ps1
    ./scripts/Initialize-Database.ps1 -LicenseFile ~/xperience/license.txt -Recreate
    ./scripts/Initialize-Database.ps1 -ServerName "localhost\SQLEXPRESS" -Username "" # Windows authentication
#>
[CmdletBinding()]
param (
    # SQL Server, e.g. "localhost,1433" (Docker) or "localhost\SQLEXPRESS". Defaults to the connection string's Data Source
    [string]$ServerName,

    # Defaults to the connection string's Initial Catalog
    [string]$DatabaseName,

    # SQL authentication. Defaults to the connection string's User ID / Password; empty Username uses Windows authentication
    [string]$Username,
    [string]$Password,

    # Password for the "administrator" account
    [string]$AdminPassword = $(if ($env:XPERIENCE_ADMIN_PASSWORD) { $env:XPERIENCE_ADMIN_PASSWORD } else { 'Pass@12345' }),

    # Xperience license file; optional
    [string]$LicenseFile = $env:XPERIENCE_LICENSE_FILE,

    # Drop and recreate the database if it exists
    [switch]$Recreate,

    # Keep dbmanager's values in appsettings.json instead of moving them to user secrets (default in CI)
    [switch]$NoUserSecrets = [bool]$env:CI
)

$ErrorActionPreference = 'Stop'

$root = Split-Path $PSScriptRoot -Parent
$project = Join-Path $root 'examples/DancingGoat'
$appsettingsPath = Join-Path $project 'appsettings.json'
$appsettingsOriginal = [IO.File]::ReadAllText($appsettingsPath)
$appsettings = $appsettingsOriginal | ConvertFrom-Json

$connection = [System.Data.Common.DbConnectionStringBuilder]::new()
# set_ConnectionString: PowerShell treats the builder as a dictionary, so property assignment would add a key instead
$connection.set_ConnectionString($appsettings.ConnectionStrings.CMSConnectionString)

function Get-ConnectionValue([string]$key) {
    if ($connection.ContainsKey($key)) { return [string]$connection[$key] }
    return ''
}

if (-not $PSBoundParameters.ContainsKey('ServerName')) { $ServerName = Get-ConnectionValue 'Data Source' }
if (-not $PSBoundParameters.ContainsKey('DatabaseName')) { $DatabaseName = Get-ConnectionValue 'Initial Catalog' }
if (-not $PSBoundParameters.ContainsKey('Username')) {
    $Username = if ((Get-ConnectionValue 'Integrated Security') -ieq 'True') { '' } else { Get-ConnectionValue 'User ID' }
}
if (-not $PSBoundParameters.ContainsKey('Password')) { $Password = Get-ConnectionValue 'Password' }

if (-not $ServerName) { throw 'No SQL Server: pass -ServerName or set Data Source in examples/DancingGoat/appsettings.json.' }
if (-not $DatabaseName) { throw 'No database name: pass -DatabaseName or set Initial Catalog in examples/DancingGoat/appsettings.json.' }

$arguments = @('--server-name', $ServerName, '--database-name', $DatabaseName, '--admin-password', $AdminPassword)
if ($Username) { $arguments += @('--username', $Username, '--password', $Password) }
if ($Recreate) { $arguments += '--recreate-existing-database' }

if ($LicenseFile) {
    if (Test-Path $LicenseFile -PathType Leaf) {
        $arguments += @('--license-file', (Resolve-Path $LicenseFile).Path)
    }
    else {
        Write-Warning "License file not found: $LicenseFile. Creating the database without a license."
    }
}

Write-Host "Creating database '$DatabaseName' on '$ServerName' ($(if ($Username) { "SQL login $Username" } else { 'Windows authentication' }))"

Push-Location $root
try {
    dotnet tool restore | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'dotnet tool restore failed' }

    Push-Location $project
    try {
        dotnet kentico-xperience-dbmanager -- @arguments
        if ($LASTEXITCODE -ne 0) { throw "kentico-xperience-dbmanager failed ($LASTEXITCODE)" }

        if (-not $NoUserSecrets) {
            $written = [IO.File]::ReadAllText($appsettingsPath) | ConvertFrom-Json
            dotnet user-secrets set 'ConnectionStrings:CMSConnectionString' $written.ConnectionStrings.CMSConnectionString | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'dotnet user-secrets set failed' }
            dotnet user-secrets set 'CMSHashStringSalt' $written.CMSHashStringSalt | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'dotnet user-secrets set failed' }
            [IO.File]::WriteAllText($appsettingsPath, $appsettingsOriginal)
            Write-Host 'Moved the connection string and CMSHashStringSalt to DancingGoat user secrets.'
        }
    }
    finally {
        Pop-Location
    }
}
finally {
    Pop-Location
}

Write-Host "Database ready. Sign in at /admin as 'administrator'."
