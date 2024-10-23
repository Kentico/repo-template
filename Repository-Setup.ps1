param (
    [string]$ProjectName
)

# Validate that the project name is provided
if (-not $ProjectName) {
    Write-Host "Please provide a valid Project Name. Example: Kentico.Xperience.Lucene"
    exit 1
}

$searchText = "Kentico.Xperience.RepoTemplate"
$replaceText = "$ProjectName"

$files = Get-ChildItem -Path "./" `
 -Recurse:true | Where-Object {
    @(".json", ".yml", ".props", ".md") -contains $_.Extension
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
    } else {
        Write-Host "No match found in file: $($file.FullName)"
    }
}

# Define project directories
$srcProjectPath = "./src/$ProjectName"
$testProjectPath = "./tests/$ProjectName.Tests"
$examplesProjectPath = "./examples/DancingGoat"

# Create the class library project
dotnet new classlib `
    -n $ProjectName `
    -o $srcProjectPath
Write-Host "Created class library project: $srcProjectPath"

# Create the NUnit test project
dotnet new nunit `
    -n "$ProjectName.Tests" `
    -o $testProjectPath
Write-Host "Created NUnit test project: $testProjectPath"

# Add reference to the src project in the test project
dotnet add "$testProjectPath/$ProjectName.Tests.csproj" `
    reference "$srcProjectPath/$ProjectName.csproj"
Write-Host "Added reference from test project to class library project."

# Create the Dancing Goat sample application
dotnet new kentico-xperience-sample-mvc `
    -n "DancingGoat" `
    -o $examplesProjectPath --allow-scripts
Write-Host "Created Dancing Goat sample application: $examplesProjectPath"

# Add reference to the src project in the Dancing Goat sample application
dotnet add "$examplesProjectPath/DancingGoat.csproj" `
    reference "$srcProjectPath/$ProjectName.csproj"
Write-Host "Added reference from Dancing Goat project to class library project."

dotnet new sln -n "$ProjectName"
dotnet sln add $srcProjectPath
dotnet sln add $testProjectPath
dotnet sln add $examplesProjectPath

Write-Host "Project setup complete."
