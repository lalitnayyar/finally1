# PowerShell script to merge a PR by switching to main, merging, and cleaning up
param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName,
    
    [switch]$DeleteBranch = $true
)

# Colors for output
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Red = [System.ConsoleColor]::Red
$Blue = [System.ConsoleColor]::Blue

function Write-ColorOutput($ForegroundColor, $Text) {
    $currentColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = $ForegroundColor
    Write-Output $Text
    [Console]::ForegroundColor = $currentColor
}

Write-ColorOutput $Blue "Starting PR merge process for branch: $BranchName"

# Switch to main branch
Write-ColorOutput $Blue "Switching to main branch..."
git checkout main
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to switch to main branch"
    exit 1
}

# Pull latest changes
Write-ColorOutput $Blue "Pulling latest changes from main..."
git pull origin main
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to pull latest changes"
    exit 1
}

# Merge the feature branch
Write-ColorOutput $Blue "Merging branch $BranchName into main..."
git merge $BranchName --no-ff -m "Merge pull request from $BranchName"
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to merge branch $BranchName"
    Write-ColorOutput $Yellow "WARNING: You may need to resolve conflicts manually"
    exit 1
}

# Push the merged changes
Write-ColorOutput $Blue "Pushing merged changes to main..."
git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to push merged changes"
    exit 1
}

# Delete local branch if requested
if ($DeleteBranch) {
    Write-ColorOutput $Blue "Deleting local branch $BranchName..."
    git branch -d $BranchName
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput $Yellow "WARNING: Could not delete branch $BranchName (may have unmerged changes)"
    }
    
    # Delete remote branch
    Write-ColorOutput $Blue "Deleting remote branch $BranchName..."
    git push origin --delete $BranchName
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput $Yellow "WARNING: Could not delete remote branch $BranchName"
    }
}

Write-ColorOutput $Green "PR merge completed successfully!"
Write-ColorOutput $Blue "Current status:"
git status

Write-ColorOutput $Green "Branch $BranchName has been merged into main and pushed to GitHub!"