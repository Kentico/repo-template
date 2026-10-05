## Delete me after project setup!

param (
    [string]$ProjectName,
    [switch]$AdminUiExtension
)

# Validate that the project name is provided
if (-not $ProjectName) {
    Write-Host "Please provide a valid Project Name. Example: Kentico.Xperience.Lucene"
    exit 1
}

$searchText = "Kentico.Xperience.RepoTemplate"
$replaceText = "$ProjectName"

$files = Get-ChildItem -Path "./" `
    -Recurse:$true | Where-Object {
    @(".json", ".yml", ".props", ".md", ".slnx") -contains $_.Extension
}

foreach ($file in $files) {
    # Read the file content
    $content = Get-Content -Path $file.FullName

    # Check if the file contains the search text
    if ($content -like "*Kentico.Xperience.RepoTemplate*") {
        Write-Host "Processing file: $($file.FullName)"
        
        # Replace the text in the file content
        $newContent = $content -replace $searchText, $replaceText

        # Write the updated content back to the file
        Set-Content -Path $file.FullName -Value $newContent

        Write-Host "Replaced text in file: $($file.FullName)"
    }
}

# Rename the root solution file to match the new project name and reuse it
$rootSlnxPath = Join-Path "./" "$ProjectName.slnx"
Rename-Item -Path "./Kentico.Xperience.RepoTemplate.slnx" -NewName "$ProjectName.slnx"
Write-Host "Renamed solution file to: $rootSlnxPath"

# Define project directories
$mainProjectName = $ProjectName
if ($AdminUiExtension) {
    $mainProjectName = "$ProjectName.Admin"
}

$srcProjectPath = Join-Path "./src" $mainProjectName
$testProjectPath = Join-Path "./tests" "$mainProjectName.Tests"
$examplesProjectPath = Join-Path "./examples" "DancingGoat"

if ($AdminUiExtension) {
    dotnet new kentico-xperience-admin-sample `
        -n $mainProjectName `
        -o $srcProjectPath `
        --no-restore `
        --allow-scripts Yes
    Write-Host "Created Admin UI extension project: $srcProjectPath"
}
else {
    dotnet new classlib `
        -n $mainProjectName `
        -o $srcProjectPath `
        --no-restore
    Write-Host "Created class library project: $srcProjectPath"
}

dotnet new nunit `
    -n "$mainProjectName.Tests" `
    -o $testProjectPath `
    --no-restore
Write-Host "Created NUnit test project: $testProjectPath"

dotnet new kentico-xperience-sample-mvc -n DancingGoat -o $examplesProjectPath --no-restore --allow-scripts Yes
Write-Host "Created Dancing Goat sample application: $examplesProjectPath"

Move-Item -Path (Join-Path $examplesProjectPath ".mcp.json") -Destination "./.mcp.json" -ErrorAction Stop
Write-Host "Moved generated MCP configuration to the repository root."

dotnet add "$testProjectPath/$mainProjectName.Tests.csproj" `
    reference $srcProjectPath
Write-Host "Added reference from test project to main project."

dotnet add "$examplesProjectPath/DancingGoat.csproj" `
    reference $srcProjectPath
Write-Host "Added reference from Dancing Goat project to main project."

dotnet sln $rootSlnxPath add $srcProjectPath
dotnet sln $rootSlnxPath add $testProjectPath
dotnet sln $rootSlnxPath add $examplesProjectPath

Set-Location (Join-Path "./src")

dotnet new sln -n "$ProjectName.Libs"
dotnet sln add $mainProjectName

Write-Host "Project setup complete."
