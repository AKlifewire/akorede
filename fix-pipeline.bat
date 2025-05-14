@echo off
echo === Fixing Smart Home Pipeline ===

REM Create a GitHub personal access token
echo First, create a GitHub personal access token with repo and admin:repo_hook permissions
echo Visit: https://github.com/settings/tokens
echo.
echo Press any key when you have created your token...
pause > nul

REM Update the GitHub token in AWS Secrets Manager
echo Enter your GitHub personal access token:
set /p GITHUB_TOKEN=

REM Store the token in AWS Secrets Manager
echo Storing token in AWS Secrets Manager...
aws secretsmanager put-secret-value --secret-id github-token --secret-string "%GITHUB_TOKEN%"

echo.
echo === Starting Pipeline Execution ===
aws codepipeline start-pipeline-execution --name SmartHomeCDKPipeline

echo.
echo === Pipeline Fix Complete ===
echo You can monitor the deployment in the AWS CodePipeline console:
echo https://console.aws.amazon.com/codesuite/codepipeline/pipelines/SmartHomeCDKPipeline/view