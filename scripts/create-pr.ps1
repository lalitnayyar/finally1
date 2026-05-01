# PowerShell script to create a feature branch, commit changes, and create a PR
param(
    [Parameter(Mandatory=$true)]
    [string]$BranchName,
    
    [Parameter(Mandatory=$true)]
    [string]$CommitMessage,
    
    [string]$PRTitle = "",
    [string]$PRDescription = ""
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

Write-ColorOutput $Blue "Starting PR creation process..."

# Check if we're on main branch
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-ColorOutput $Yellow "WARNING: Switching to main branch first..."
    git checkout main
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput $Red "ERROR: Failed to switch to main branch"
        exit 1
    }
}

# Pull latest changes from main
Write-ColorOutput $Blue "Pulling latest changes from main..."
git pull origin main
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to pull latest changes"
    exit 1
}

# Create and checkout new feature branch
Write-ColorOutput $Blue "Creating new branch: $BranchName"
git checkout -b $BranchName
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to create branch $BranchName"
    exit 1
}

# Show current status
Write-ColorOutput $Blue "Current git status:"
git status

# Stage all changes
Write-ColorOutput $Blue "Staging all changes..."
git add .

# Create commit
Write-ColorOutput $Blue "Creating commit with message: $CommitMessage"
git commit -m $CommitMessage
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to create commit"
    exit 1
}

# Push branch to origin
Write-ColorOutput $Blue "Pushing branch to GitHub..."
git push -u origin $BranchName
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "ERROR: Failed to push branch"
    exit 1
}

# Generate PR title and description if not provided
if ([string]::IsNullOrEmpty($PRTitle)) {
    $PRTitle = $CommitMessage
}

if ([string]::IsNullOrEmpty($PRDescription)) {
    $PRDescription = @"
## Changes Summary
$CommitMessage

## Files Modified
$(git diff --name-only main..$BranchName | ForEach-Object { "- $_" } | Out-String)

## Testing
- Code tested locally
- No breaking changes  
- Documentation updated if needed

## Additional Notes
Generated automatically by create-pr.ps1 script.
"@
}

Write-ColorOutput $Green "Branch created and pushed successfully!"
Write-ColorOutput $Blue "To create a PR, visit:"
Write-ColorOutput $Yellow "https://github.com/lalitnayyar/finally1/compare/$BranchName"

Write-ColorOutput $Blue "PR Details:"
Write-Output "Title: $PRTitle"
Write-Output "Description:"
Write-Output $PRDescription

# Create a PR summary file
$prSummaryPath = "pr-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
@"
# Pull Request Summary

**Branch:** $BranchName
**Title:** $PRTitle
**Created:** $(Get-Date)

## Description
$PRDescription

## GitHub PR Link
https://github.com/lalitnayyar/finally1/compare/$BranchName

## Next Steps
1. Visit the GitHub link above
2. Review the changes
3. Create the pull request
4. Once approved, merge using: .\scripts\merge-pr.ps1 $BranchName
"@ | Out-File -FilePath $prSummaryPath -Encoding UTF8

Write-ColorOutput $Green "PR summary saved to: $prSummaryPath"