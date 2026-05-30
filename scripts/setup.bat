@echo off
setlocal enabledelayedexpansion

echo =================================================================
echo === Starting Secure Azure Enclave Bootstrap (Windows CMD)    ===
echo =================================================================


call az account show >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run 'az login' in this command prompt first, then re-run this script.
    exit /b 1
)


for /f "tokens=*" %%i in ('az account show --query id -o tsv') do set SUBSCRIPTION_ID=%%i
for /f "tokens=*" %%i in ('az account show --query tenantId -o tsv') do set TENANT_ID=%%i

echo Targeting Subscription ID: %SUBSCRIPTION_ID%
echo Targeting Tenant ID: %TENANT_ID%


echo Creating Entra ID App Registration...
set APP_NAME=github-enclave-deployer
for /f "tokens=*" %%i in ('az ad app create --display-name %APP_NAME% --query appId -o tsv') do set CLIENT_ID=%%i


echo Assigning Contributor permissions to subscription...
call az ad sp create --id %CLIENT_ID% >nul 2>&1
call az role assignment create --assignee %CLIENT_ID% --role "Contributor" --scope "/subscriptions/%SUBSCRIPTION_ID%"


set /p GH_USER="Enter your GitHub Username or Organization: "
set /p GH_REPO="Enter your GitHub Repository Name: "


set CONFIG_FILE=%~dp0credential-config.json

echo {> "%CONFIG_FILE%"
echo     "name": "github-main-branch-access",>> "%CONFIG_FILE%"
echo     "issuer": "https://token.actions.githubusercontent.com",>> "%CONFIG_FILE%"
echo     "subject": "repo:%GH_USER%/%GH_REPO%:ref:refs/heads/main",>> "%CONFIG_FILE%"
echo     "description": "Allow GitHub Actions to deploy to Azure via passwordless OIDC",>> "%CONFIG_FILE%"
echo     "audiences": ["api://AzureADTokenExchange"]>> "%CONFIG_FILE%"
echo }>> "%CONFIG_FILE%"

echo Federating identity between Azure and GitHub...
call az ad app federated-credential create --id %CLIENT_ID% --parameters "%CONFIG_FILE%" >nul


if exist "%CONFIG_FILE%" del "%CONFIG_FILE%"

echo =================================================================
echo === Bootstrap Configuration Success!                          ===
echo =================================================================
echo Add the following parameters to your GitHub Actions Secrets:
echo -----------------------------------------------------------------
echo AZURE_CLIENT_ID: %CLIENT_ID%
echo AZURE_TENANT_ID: %TENANT_ID%
echo AZURE_SUBSCRIPTION_ID: %SUBSCRIPTION_ID%
echo -----------------------------------------------------------------

endlocal