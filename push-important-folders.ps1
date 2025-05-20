# PowerShell script to ensure .github and infra folders are committed and pushed to remote

Write-Host "Making sure .github and infra folders are tracked by Git..." -ForegroundColor Green

# Navigate to the project directory where the Git repository is initialized
$projectDir = "c:\Users\vivanovski\Projects\Test-Project\github-contributor-gallery"
Set-Location $projectDir

# Create .github folder in the root if it doesn't exist
$repoRootGithubDir = "c:\Users\vivanovski\Projects\Test-Project\.github"
$projectGithubDir = "$projectDir\.github"

if (Test-Path $repoRootGithubDir) {
    Write-Host "Copying .github folder from repository root to project directory..." -ForegroundColor Cyan
    if (!(Test-Path $projectGithubDir)) {
        # Create directory if it doesn't exist
        New-Item -ItemType Directory -Path $projectGithubDir | Out-Null
    }

    # Copy workflows directory
    $workflowsSource = "$repoRootGithubDir\workflows"
    $workflowsDest = "$projectGithubDir\workflows"
    
    if (Test-Path $workflowsSource) {
        if (!(Test-Path $workflowsDest)) {
            New-Item -ItemType Directory -Path $workflowsDest | Out-Null
        }
        
        # Copy all workflow files
        Copy-Item -Path "$workflowsSource\*.yml" -Destination $workflowsDest
        Write-Host "Workflow files copied successfully" -ForegroundColor Green
    } else {
        Write-Host "No workflows found in the repository root .github folder" -ForegroundColor Yellow
    }
}

# Make sure infra folder is not ignored
Write-Host "Adding infra folder..." -ForegroundColor Cyan
git add -f infra/

# Make sure .github folder is not ignored
Write-Host "Adding .github folder..." -ForegroundColor Cyan
git add -f .github/

# Commit the changes
Write-Host "Committing changes..." -ForegroundColor Cyan
git commit -m "Add .github workflows and infrastructure files"

# Push to remote
Write-Host "Pushing to remote repository..." -ForegroundColor Cyan
git push

Write-Host "`nDone! The .github and infra folders should now be pushed to your remote repository." -ForegroundColor Green
