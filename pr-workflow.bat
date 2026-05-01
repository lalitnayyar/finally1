@echo off
setlocal

if "%~1"=="" (
    echo.
    echo ====================================
    echo   FinAlly GitHub Workflow Helper
    echo ====================================
    echo.
    echo Usage: pr-workflow.bat [create^|auto^|merge^|status^|help]
    echo.
    echo Commands:
    echo   create  - Create a new feature branch and PR ^(interactive^)
    echo   auto    - Create PR with AI-generated branch name and commit message
    echo   merge   - Merge an existing PR to main
    echo   status  - Show current git status
    echo   help    - Show detailed help
    echo.
    pause
    goto :eof
)

if /i "%1"=="create" (
    echo Creating new PR ^(interactive mode^)...
    powershell -ExecutionPolicy Bypass -File ".\scripts\create-pr.ps1"
    goto :eof
)

if /i "%1"=="auto" (
    echo Creating PR with AI suggestions...
    powershell -ExecutionPolicy Bypass -File ".\scripts\create-pr.ps1" -AutoGenerate
    goto :eof
)

if /i "%1"=="merge" (
    echo Merging PR...
    set /p branch_name="Enter branch name to merge: "
    powershell -ExecutionPolicy Bypass -File ".\scripts\merge-pr.ps1" -BranchName "%branch_name%"
    goto :eof
)

if /i "%1"=="status" (
    echo Current Git Status:
    echo ==================
    git status
    echo.
    echo Remote Repositories:
    echo ===================
    git remote -v
    pause
    goto :eof
)

if /i "%1"=="help" (
    echo.
    echo FinAlly GitHub Workflow Detailed Help
    echo ====================================
    echo.
    echo This tool helps you manage the GitHub workflow for the FinAlly project
    echo with AI-powered branch name and commit message generation.
    echo.
    echo WORKFLOW:
    echo 1. Make your code changes
    echo 2. Run: pr-workflow.bat create ^(interactive^) OR pr-workflow.bat auto ^(AI-powered^)
    echo 3. Go to GitHub and review/approve the PR
    echo 4. Run: pr-workflow.bat merge [branch-name]
    echo.
    echo COMMANDS:
    echo   create - Interactive mode: prompts for branch name and commit message
    echo            Provides AI suggestions that you can accept or modify
    echo.
    echo   auto   - Automatic mode: uses AI to analyze your changes and generate
    echo            branch names and commit messages automatically
    echo.
    echo   merge  - Merge an approved PR back to main branch
    echo.
    echo   status - Show current git status and repository information
    echo.
    echo BRANCH NAMING CONVENTIONS:
    echo - feature/description    ^(for new features^)
    echo - bugfix/description     ^(for bug fixes^)  
    echo - hotfix/description     ^(for urgent fixes^)
    echo - docs/description       ^(for documentation^)
    echo.
    echo AI FEATURES:
    echo - Analyzes git diff to understand your changes
    echo - Suggests appropriate branch names based on file types and changes
    echo - Generates descriptive commit messages
    echo - Falls back to manual input if AI is unavailable
    echo.
    echo EXAMPLES:
    echo pr-workflow.bat auto
    echo   ^(AI analyzes changes and suggests everything^)
    echo.
    echo pr-workflow.bat create
    echo   ^(Interactive with AI suggestions^)
    echo.
    echo pr-workflow.bat merge feature/user-dashboard
    echo.
    echo REQUIREMENTS:
    echo - OPENROUTER_API_KEY environment variable for AI features
    echo - Fallback to manual input if API key not available
    echo.
    echo FILES CREATED:
    echo - scripts/create-pr.ps1   ^(Enhanced PowerShell script with AI^)
    echo - scripts/merge-pr.ps1    ^(PowerShell script for merging PRs^)
    echo - pr-summary-*.md         ^(Generated PR summaries^)
    echo.
    pause
    goto :eof
)

echo Unknown command: %1
echo Use 'pr-workflow.bat help' for detailed usage
pause