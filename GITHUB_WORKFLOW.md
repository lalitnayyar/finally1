# GitHub Workflow Process for FinAlly

This document describes the complete process for uploading updated code to GitHub using proper branching and Pull Request (PR) workflow.

## Overview

The workflow follows these principles:
1. **Never commit directly to main branch**
2. **Always use feature branches**
3. **Create PRs with detailed descriptions**
4. **Review before merging**
5. **Clean up branches after merging**

## Repository Setup

- **GitHub Repository:** https://github.com/lalitnayyar/finally1.git
- **Main Branch:** `main`
- **Remote:** `origin`

## Quick Start

### Option 1: Using the Batch File (Recommended)
```bash
# Create a new PR with AI suggestions (recommended)
pr-workflow.bat auto

# Create a new PR with interactive prompts
pr-workflow.bat create

# Merge an approved PR
pr-workflow.bat merge

# Check status
pr-workflow.bat status
```

### Option 2: Using PowerShell Scripts Directly
```powershell
# Auto-generate PR with AI
.\scripts\create-pr.ps1 -AutoGenerate

# Create PR with manual input
.\scripts\create-pr.ps1 -BranchName "feature/new-feature" -CommitMessage "Add new feature"

# Merge PR
.\scripts\merge-pr.ps1 -BranchName "feature/new-feature"
```

## AI-Powered Features

### Automatic Branch Naming
The AI analyzes your code changes and suggests appropriate branch names:
- **feature/[description]** - for new functionality
- **bugfix/[description]** - for bug fixes
- **docs/[description]** - for documentation changes
- **scripts/[description]** - for script/tooling changes
- **config/[description]** - for configuration updates

### Intelligent Commit Messages
Based on the actual code changes, the AI generates:
- Descriptive, concise commit messages
- Present tense formatting ("Add feature" not "Added feature")
- Context-aware descriptions based on file types and changes
- Professional formatting following Git best practices

### Requirements
- **OPENROUTER_API_KEY** environment variable for AI features
- Python available for API calls
- Fallback to manual input if AI unavailable
- Works offline with intelligent fallbacks

### Usage
```bash
# Fully automated (recommended)
pr-workflow.bat auto

# Interactive with AI suggestions
pr-workflow.bat create
# (AI provides suggestions, you can accept or modify)
```

## Traditional Workflow

### Step 1: Make Your Changes
1. Work on your code changes in the local repository
2. Test your changes thoroughly
3. Ensure all files are saved

### Step 2: Create Feature Branch and PR

#### Using AI Auto-Generation (Recommended):
```bash
pr-workflow.bat auto
```
- Automatically analyzes your code changes
- Suggests branch names based on file types and changes
- Generates descriptive commit messages
- No manual input required!

#### Using Interactive Mode:
```bash
pr-workflow.bat create
```
- AI provides suggestions for branch names and commit messages
- You can accept suggestions or provide your own
- Fallback to manual input if AI unavailable

#### Manual process:
```powershell
# Switch to main and pull latest
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Stage and commit changes
git add .
git commit -m "Your commit message"

# Push branch
git push -u origin feature/your-feature-name
```

### Step 3: Create Pull Request on GitHub
1. Visit the generated GitHub link (shown after running the script)
2. Review the auto-generated PR title and description
3. Add any additional details or reviewers
4. Create the pull request

### Step 4: Review Process
1. Review your own PR first
2. Check the "Files changed" tab
3. Ensure all changes are intentional
4. Add comments for any complex changes
5. Approve the PR when ready

### Step 5: Merge the PR

#### Using the batch file:
```bash
pr-workflow.bat merge
```
Enter the branch name when prompted.

#### Manual process:
```powershell
.\scripts\merge-pr.ps1 -BranchName "feature/your-feature-name"
```

This will:
- Switch to main branch
- Pull latest changes
- Merge your feature branch
- Push to GitHub
- Clean up local and remote branches

## Branch Naming Conventions

Use descriptive branch names with prefixes:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New features | `feature/user-authentication` |
| `bugfix/` | Bug fixes | `bugfix/login-validation` |
| `hotfix/` | Urgent fixes | `hotfix/security-patch` |
| `docs/` | Documentation | `docs/api-reference` |
| `refactor/` | Code refactoring | `refactor/database-layer` |

## Commit Message Best Practices

- Use present tense: "Add feature" not "Added feature"
- Be descriptive but concise
- Start with a capital letter
- Don't end with a period
- Include ticket numbers if applicable

Examples:
- ✅ "Add user dashboard with real-time charts"
- ✅ "Fix authentication timeout issue"
- ✅ "Update README with installation instructions"
- ❌ "fixed stuff"
- ❌ "updates"

## Files Created by This Process

### Scripts
- `scripts/create-pr.ps1` - Main PR creation script
- `scripts/merge-pr.ps1` - PR merging script  
- `pr-workflow.bat` - Easy-to-use batch interface

### Generated Files
- `pr-summary-[timestamp].md` - PR summary for each created PR
- Contains branch info, PR description, and GitHub links

## Troubleshooting

### Common Issues

1. **"Failed to push branch"**
   - Check internet connection
   - Verify GitHub authentication
   - Ensure remote URL is correct: `git remote -v`

2. **"Failed to merge branch"**
   - May have merge conflicts
   - Resolve conflicts manually: `git status`
   - Complete merge: `git commit`

3. **"Branch already exists"**
   - Choose a different branch name
   - Or delete existing branch: `git branch -d branch-name`

### Checking Repository Status
```bash
# Check current status
pr-workflow.bat status

# Or manually
git status
git remote -v
git branch -a
```

## Security Notes

- Never commit sensitive information (passwords, API keys)
- Use `.gitignore` for local config files
- Review changes before committing

## Integration with FinAlly Project

This workflow integrates with the existing FinAlly project structure:
- Respects existing `.gitignore` files
- Works with current directory structure
- Maintains compatibility with existing development process

## Next Steps

After setting up this workflow:
1. Test with a small change first
2. Train team members on the process  
3. Consider adding GitHub Actions for automated testing
4. Set up branch protection rules on GitHub

## Support

For issues with this workflow:
1. Check the troubleshooting section above
2. Review generated PR summary files
3. Check git status and remote configuration
4. Ensure proper GitHub access permissions