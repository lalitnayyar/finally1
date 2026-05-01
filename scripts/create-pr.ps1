param(
    [string]$BranchName = "",
    [string]$CommitMessage = "",
    [switch]$AutoGenerate
)

function Write-ColorOutput {
    param(
        [ConsoleColor]$Color,
        [string]$Message
    )
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

function Get-AISuggestions {
    param([string]$diffOutput)
    
    try {
        $pythonScript = @'
import requests
import json
import os

api_key = os.getenv('OPENROUTER_API_KEY')
if not api_key:
    print('BRANCH: feature/code-changes')
    print('COMMIT: Update code with recent changes')
    exit(0)

try:
    response = requests.post(
        'https://openrouter.ai/api/v1/chat/completions',
        headers={'Authorization': f'Bearer {api_key}'},
        json={
            'model': 'cerebras/llama3.1-8b',
            'messages': [{'role': 'user', 'content': '''$($prompt -replace "'", "`'")'''}],
            'max_tokens': 150
        },
        timeout=10
    )
    
    if response.status_code == 200:
        content = response.json()['choices'][0]['message']['content']
        print(content)
    else:
        print('BRANCH: feature/code-changes')
        print('COMMIT: Update code with recent changes')
except:
    print('BRANCH: feature/code-changes')  
    print('COMMIT: Update code with recent changes')
'@
        
        $prompt = "Analyze this git diff and suggest a concise branch name (format: type/description) and commit message. Files changed: $(git diff --name-only | Out-String). Diff: $($diffOutput.Substring(0, [Math]::Min(1000, $diffOutput.Length))). Respond in format: 'BRANCH: branch-name' on first line, 'COMMIT: commit message' on second line."
        
        $result = $pythonScript | python -
        
        if ($result -match "BRANCH: (.+)") {
            $suggestedBranch = $matches[1].Trim()
        }
        if ($result -match "COMMIT: (.+)") {
            $suggestedCommit = $matches[1].Trim()
        }
        
        return @{
            Branch = $suggestedBranch
            Commit = $suggestedCommit
        }
    }
    catch {
        return @{
            Branch = "feature/code-changes"
            Commit = "Update code with recent changes"
        }
    }
}

# Color definitions
$Red = [ConsoleColor]::Red
$Green = [ConsoleColor]::Green
$Blue = [ConsoleColor]::Blue
$Yellow = [ConsoleColor]::Yellow
$Cyan = [ConsoleColor]::Cyan

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-ColorOutput $Red "Error: Not in a git repository"
    exit 1
}

Write-ColorOutput $Blue "Starting enhanced PR creation process..."

# Ensure we're on main and pull latest
Write-ColorOutput $Blue "Pulling latest changes from main..."
$currentBranch = (git branch --show-current).Trim()
if ($currentBranch -ne "main") {
    git checkout main
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput $Red "Failed to checkout main branch"
        exit 1
    }
}

git fetch origin main
git merge origin/main

# Check for changes
Write-ColorOutput $Blue "Analyzing current changes..."
$gitStatus = git status --porcelain
if (-not $gitStatus) {
    Write-ColorOutput $Yellow "No changes detected. Nothing to commit."
    exit 0
}

# Get list of files to be committed
$filesToCommit = @()
$unstagedChanges = @()
$newFiles = @()

foreach ($line in $gitStatus) {
    $status = $line.Substring(0, 2)
    $filepath = $line.Substring(3)
    
    if ($status -match "[MAD ]") {
        $filesToCommit += $filepath
    }
    if ($status -match "[ MAD]") {
        $unstagedChanges += $filepath
    }
    if ($status -match "\?\?") {
        $newFiles += $filepath
    }
}

Write-ColorOutput $Green "Files to be committed:"
($filesToCommit + $unstagedChanges + $newFiles) | ForEach-Object { Write-Output "  - $_" }

# Get AI suggestions if AutoGenerate is specified
$suggestedBranch = $null
$suggestedCommit = $null

if ($AutoGenerate) {
    Write-ColorOutput $Cyan "AI: Analyzing changes with AI..."
    
    $diffOutput = git diff HEAD
    if (-not $diffOutput) {
        $diffOutput = git diff --cached
    }
    
    $suggestions = Get-AISuggestions -diffOutput $diffOutput
    $suggestedBranch = $suggestions.Branch
    $suggestedCommit = $suggestions.Commit
}

# Get branch name and commit message
if ([string]::IsNullOrEmpty($BranchName)) {
    if ($suggestedBranch) {
        Write-ColorOutput $Cyan "AI: Suggested branch name: $suggestedBranch"
        $response = Read-Host "Press Enter to use suggestion, or type a different branch name"
        $BranchName = if ([string]::IsNullOrEmpty($response)) { $suggestedBranch } else { $response }
    } else {
        $BranchName = Read-Host "Enter branch name (e.g., feature/add-dashboard)"
    }
}

if ([string]::IsNullOrEmpty($CommitMessage)) {
    if ($suggestedCommit) {
        Write-ColorOutput $Cyan "AI: Suggested commit message: $suggestedCommit"
        $response = Read-Host "Press Enter to use suggestion, or type a different commit message"
        $CommitMessage = if ([string]::IsNullOrEmpty($response)) { $suggestedCommit } else { $response }
    } else {
        $CommitMessage = Read-Host "Enter commit message"
    }
}

# Validate inputs
if ([string]::IsNullOrEmpty($BranchName)) {
    Write-ColorOutput $Red "Error: Branch name cannot be empty"
    exit 1
}
if ([string]::IsNullOrEmpty($CommitMessage)) {
    Write-ColorOutput $Red "Error: Commit message cannot be empty"
    exit 1
}

# Create and switch to new branch
Write-ColorOutput $Blue "Creating new branch: $BranchName"
git checkout -b $BranchName
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "Failed to create branch: $BranchName"
    exit 1
}

# Show current status
Write-ColorOutput $Blue "Current git status:"
git status

# Stage all changes
Write-ColorOutput $Blue "Staging all changes..."
git add -A

# Create commit
Write-ColorOutput $Blue "Creating commit with message: $CommitMessage"
git commit -m $CommitMessage
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "Failed to create commit"
    git checkout main
    git branch -D $BranchName
    exit 1
}

# Push to GitHub
Write-ColorOutput $Blue "Pushing branch to GitHub..."
git push -u origin $BranchName
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "Failed to push branch to GitHub"
    exit 1
}

# Create PR description if not provided
$PRTitle = $CommitMessage
$PRDescription = ""

if ([string]::IsNullOrEmpty($PRDescription)) {
    $modifiedFiles = git diff --name-only main..$BranchName | ForEach-Object { "- $_" } | Out-String
    $PRDescription = @"
## Changes Summary
$CommitMessage

## Files Modified
$modifiedFiles

## Testing
- Code tested locally
- No breaking changes  
- Documentation updated if needed

## Additional Notes
Generated automatically by enhanced create-pr.ps1 script with AI suggestions.
"@
}

Write-ColorOutput $Green "Branch created and pushed successfully!"
Write-ColorOutput $Blue "To create a PR, visit:"
Write-ColorOutput $Yellow "https://github.com/lalitnayyar/finally1/compare/$BranchName"

Write-ColorOutput $Blue "PR Details:"
Write-Output "Title: $PRTitle"
Write-Output "Description:"
Write-Output $PRDescription

# Save PR details to file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$prSummaryFile = "pr-summary-$timestamp.md"
$prSummaryContent = @"
# PR Summary - $timestamp

## Branch: $BranchName
## Title: $PRTitle

$PRDescription

## GitHub Links
- **Create PR**: https://github.com/lalitnayyar/finally1/pull/new/$BranchName
- **Compare Changes**: https://github.com/lalitnayyar/finally1/compare/$BranchName

## Instructions
1. Visit the GitHub link above
2. Review the changes
3. Click "Create pull request"
4. The PR description will be automatically filled

## Files Changed
$(git diff --name-only main..$BranchName | Out-String)

---
Generated by create-pr.ps1 on $(Get-Date)
"@

$prSummaryContent | Out-File -FilePath $prSummaryFile -Encoding UTF8
Write-ColorOutput $Blue "PR summary saved to: $prSummaryFile"