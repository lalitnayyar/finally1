@echo off
echo.
echo ====================================
echo   FinAlly GitHub Workflow Helper
echo ====================================
echo.

if "%~1"=="" (
    echo Usage: pr-workflow.bat [create^|merge^|status]
    echo.
    echo Commands:
    echo   create  - Create a new feature branch and PR
    echo   merge   - Merge an existing PR to main
    echo   status  - Show current git status
    echo   help    - Show detailed help
    echo.
    goto :end
)

if /i "%~1"=="create" (
    call :create_pr
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
echo Creating new PR...
set /p branch_name="Enter branch name (e.g., feature/add-user-dashboard): "
set /p commit_msg="Enter commit message: "
powershell -ExecutionPolicy Bypass -File ".\scripts\create-pr.ps1" -BranchName "%branch_name%" -CommitMessage "%commit_msg%"
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
echo This tool helps you manage the GitHub workflow for the FinAlly project.
echo.
echo WORKFLOW:
echo 1. Make your code changes
echo 2. Run: pr-workflow.bat create
echo 3. Go to GitHub and review/approve the PR
echo 4. Run: pr-workflow.bat merge [branch-name]
echo.
echo BRANCH NAMING CONVENTIONS:
echo - feature/description    (for new features)
echo - bugfix/description     (for bug fixes)  
echo - hotfix/description     (for urgent fixes)
echo - docs/description       (for documentation)
echo.
echo EXAMPLES:
echo pr-workflow.bat create
echo   (then follow prompts)
echo.
echo pr-workflow.bat merge feature/user-dashboard
echo.
echo FILES CREATED:
echo - scripts/create-pr.ps1   (PowerShell script for creating PRs)
echo - scripts/merge-pr.ps1    (PowerShell script for merging PRs)
echo - pr-summary-*.md         (Generated PR summaries)
echo.
goto :eof

:end
echo.
pause