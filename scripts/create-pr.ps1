# PowerShell script to create a feature branch, commit changes, and create a PR
# Enhanced with AI-powered branch name and commit message generation
param(
    [string]$BranchName = "",
    [string]$CommitMessage = "",
    [string]$PRTitle = "",
    [string]$PRDescription = "",
    [switch]$AutoGenerate = $false
)

# Colors for output
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Red = [System.ConsoleColor]::Red
$Blue = [System.ConsoleColor]::Blue
$Cyan = [System.ConsoleColor]::Cyan

function Write-ColorOutput($ForegroundColor, $Text) {
    $currentColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = $ForegroundColor
    Write-Output $Text
    [Console]::ForegroundColor = $currentColor
}

function Get-AISuggestions($changes, $filelist) {
    Write-ColorOutput $Cyan "AI: Analyzing changes with AI..."
    
    # Create a focused prompt for the AI
    $prompt = @"
Based on the following code changes, suggest:
1. A branch name (format: type/short-description, e.g., feature/user-auth, bugfix/login-error, docs/readme-update)
2. A commit message (concise, descriptive, present tense)

Files changed: $($filelist -join ', ')

Changes summary:
$changes

Respond in this exact format:
BRANCH: [suggested branch name]
COMMIT: [suggested commit message]
"@

    try {
        # Use python to call AI (assuming OpenRouter/LiteLLM is available)
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
        
        $pythonScript | python -
        
    } catch {
        # Fallback suggestions
        Write-ColorOutput $Yellow "⚠️  AI unavailable, using fallback suggestions..."
        $fileTypes = $filelist | ForEach-Object { 
            $ext = [System.IO.Path]::GetExtension($_)
            switch ($ext) {
                ".md" { "docs" }
                ".ps1" { "scripts" }
                ".py" { "backend" }
                ".js" { "frontend" }
                ".ts" { "frontend" }
                ".json" { "config" }
                default { "feature" }
            }
        } | Select-Object -Unique
        
        $primaryType = if ($fileTypes.Count -eq 1) { $fileTypes[0] } else { "feature" }
        
        Write-Output "BRANCH: $primaryType/update-$(Get-Date -Format 'MMdd')"
        Write-Output "COMMIT: Update $($filelist.Count) files with recent changes"
    }
}

Write-ColorOutput $Blue "Starting enhanced PR creation process..."

# Check if we're on main branch
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-ColorOutput $Yellow "⚠️  Switching to main branch first..."
    git checkout main
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput $Red "❌ Failed to switch to main branch"
        exit 1
    }
}

# Pull latest changes from main
Write-ColorOutput $Blue "Pulling latest changes from main..."
git pull origin main
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "❌ Failed to pull latest changes"
    exit 1
}

# Analyze current changes
Write-ColorOutput $Blue "Analyzing current changes..."
$statusOutput = git status --porcelain
if (-not $statusOutput) {
    Write-ColorOutput $Yellow "⚠️  No changes detected. Make some changes first!"
    exit 1
}

# Get file list and changes
$changedFiles = git status --porcelain | ForEach-Object { $_.Substring(3) }
$diffOutput = git diff --staged HEAD 2>$null
if (-not $diffOutput) {
    $diffOutput = git diff HEAD 2>$null
}

Write-ColorOutput $Green "Files to be committed:"
$changedFiles | ForEach-Object { Write-Output "  - $_" }

# Generate AI suggestions if parameters not provided
if ([string]::IsNullOrEmpty($BranchName) -or [string]::IsNullOrEmpty($CommitMessage) -or $AutoGenerate) {
    $suggestions = Get-AISuggestions $diffOutput $changedFiles
    
    # Parse AI suggestions
    $suggestedBranch = ""
    $suggestedCommit = ""
    
    $suggestions -split "`n" | ForEach-Object {
        if ($_ -match "BRANCH:\s*(.+)") {
            $suggestedBranch = $matches[1].Trim()
        }
        elseif ($_ -match "COMMIT:\s*(.+)") {
            $suggestedCommit = $matches[1].Trim()
        }
    }
    
    # Use suggestions or prompt user
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
}

# Create and checkout new feature branch
Write-ColorOutput $Blue "Creating new branch: $BranchName"
git checkout -b $BranchName
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "❌ Failed to create branch $BranchName"
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
    Write-ColorOutput $Red "❌ Failed to create commit"
    exit 1
}

# Push branch to origin
Write-ColorOutput $Blue "Pushing branch to GitHub..."
git push -u origin $BranchName
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput $Red "❌ Failed to push branch"
    exit 1
}

# Generate PR title and description if not provided
if ([string]::IsNullOrEmpty($PRTitle)) {
    $PRTitle = $CommitMessage
}

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

# Create a PR summary file
$prSummaryPath = "pr-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
@"
# Pull Request Summary

**Branch:** $BranchName
**Title:** $PRTitle
**Created:** $(Get-Date)
**AI-Generated:** $(if ($suggestedBranch -or $suggestedCommit) { "Yes" } else { "No" })

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

Write-ColorOutput $Green "📄 PR summary saved to: $prSummaryPath"