@echo off
echo.
echo ====================================
echo   FinAlly GitHub Workflow Helper
echo ====================================
echo.

if "%~1"=="" (
    echo Usage: pr-workflow.bat [create^|auto^|merge^|status^|help]
    echo.
    echo Commands:
    echo   create  - Create a new feature branch and PR (interactive)
    echo   auto    - Create PR with AI-generated branch name and commit message
    echo   merge   - Merge an existing PR to main
    echo   status  - Show current git status
    echo   help    - Show detailed help
    echo.
    goto :end
)

if /i "%~1"=="create" (
    call :create_pr
) else if /i "%~1"=="auto" (
    call :auto_pr
) else if /i "%~1"=="merge" (
    call :merge_pr
) else if /i "%~1"=="status" (
    call :show_status
) else if /i "%~1"=="help" (
    call :show_help
) else (
    echo Unknown command: %~1
    echo Use 'pr-workflow.bat help' for detailed usage
)

goto :end

:create_pr
echo Creating new PR (interactive mode)...
powershell -ExecutionPolicy Bypass -File ".\scripts\create-pr.ps1"
goto :eof

:auto_pr
echo Creating PR with AI suggestions...
powershell -ExecutionPolicy Bypass -File ".\scripts\create-pr.ps1" -AutoGenerate
goto :eof

:merge_pr
echo Merging PR...
set /p branch_name="Enter branch name to merge: "
powershell -ExecutionPolicy Bypass -File ".\scripts\merge-pr.ps1" -BranchName "%branch_name%"
goto :eof

:show_status
echo Current Git Status:
echo ==================
git status
echo.
echo Remote Repositories:
echo ===================
git remote -v
goto :eof

:show_help
echo.
echo FinAlly GitHub Workflow Detailed Help
echo ====================================
echo.
echo This tool helps you manage the GitHub workflow for the FinAlly project
echo with AI-powered branch name and commit message generation.
echo.
echo WORKFLOW:
echo 1. Make your code changes
echo 2. Run: pr-workflow.bat create (interactive) OR pr-workflow.bat auto (AI-powered)
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
echo - feature/description    (for new features)
echo - bugfix/description     (for bug fixes)  
echo - hotfix/description     (for urgent fixes)
echo - docs/description       (for documentation)
echo.
echo AI FEATURES:
echo - Analyzes git diff to understand your changes
echo - Suggests appropriate branch names based on file types and changes
echo - Generates descriptive commit messages
echo - Falls back to manual input if AI is unavailable
echo.
echo EXAMPLES:
echo pr-workflow.bat auto
echo   (AI analyzes changes and suggests everything)
echo.
echo pr-workflow.bat create
echo   (Interactive with AI suggestions)
echo.
echo pr-workflow.bat merge feature/user-dashboard
echo.
echo REQUIREMENTS:
echo - OPENROUTER_API_KEY environment variable for AI features
echo - Fallback to manual input if API key not available
echo.
echo FILES CREATED:
echo - scripts/create-pr.ps1   (Enhanced PowerShell script with AI)
echo - scripts/merge-pr.ps1    (PowerShell script for merging PRs)
echo - pr-summary-*.md         (Generated PR summaries)
echo.
goto :eof

:end
echo.
pause