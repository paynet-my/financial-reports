@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM Default values
REM ============================================================
set "API_URL=https://api.reports.paynet.my"
set "OUTPUT_DIR=.\"

REM ============================================================
REM Parse command line arguments
REM ============================================================
:parse_args
if "%~1"=="" goto validate_args
if "%~1"=="--client-id" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )
  set "CLIENT_ID=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--client-secret" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )
  set "CLIENT_SECRET=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--fiid" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )
  set "FIID=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--report" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )
  set "REPORT_TYPE=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--date" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )

  set "DDATE=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--output-dir" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )

  set "OUTPUT_DIR=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--product" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )
  
  REM Validate that product is either "san" or "mydebit"
  if /i not "%~2"=="san" if /i not "%~2"=="mydebit" (
      echo ERROR: Invalid product value. Allowed values: san, mydebit
      call :help
      exit /b 1
  )

  set "PRODUCT=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--api-url" (
  if "%~2"=="" (
      echo ERROR: Empty value provided for %~1
      call :help
      exit /b 1
  )
  REM Extract first two characters to check for -- prefix
  set "first_chars=%~2"
  set "first_chars=!first_chars:~0,2!"
  if "!first_chars!"=="--" (
      echo ERROR: Missing value for %~1
      call :help
      exit /b 1
  )

  set "API_URL=%~2"
  shift /1
  shift /1
  goto parse_args
)
if "%~1"=="--help" (
    call :usage
    exit /b 0
)
echo Unknown option: %1
call :usage
exit /b 1

REM ============================================================
REM Validate required parameters
REM ============================================================
:validate_args
if not defined CLIENT_ID (
    echo ERROR: Missing --client-id
    call :help
    exit /b 1
)
if not defined CLIENT_SECRET (
    echo ERROR: Missing --client-secret
    call :help
    exit /b 1
)
if not defined FIID (
    echo ERROR: Missing --fiid
    call :help
    exit /b 1
)
if not defined REPORT_TYPE (
    echo ERROR: Missing --report
    call :help
    exit /b 1
)
if not defined PRODUCT (
    echo ERROR: Missing --product
    call :help
    exit /b 1
)
if not defined DDATE (
    echo ERROR: Missing --date
    call :help
    exit /b 1
)

REM Validate date format (YYYY-MM-DD)
echo %DDATE%| findstr /r "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$" >nul
if errorlevel 1 (
    echo ERROR: Date must be in YYYY-MM-DD format
    exit /b 1
)

REM ============================================================
REM Create output directory if it doesn't exist
REM ============================================================
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%" 2>nul
    if errorlevel 1 (
        echo Failed to create output directory
        exit /b 1
    )
)

REM Ensure output directory path ends with a backslash
set "LAST_CHAR=!OUTPUT_DIR:~-1!"
if not "!LAST_CHAR!"=="\" if not "!LAST_CHAR!"=="/" (
    set "OUTPUT_DIR=!OUTPUT_DIR!\"
)

REM ============================================================
REM Display configuration
REM ============================================================
echo Configuration:
echo  - API URL: %API_URL%
echo  - FIID: %FIID%
echo  - Report Type: %REPORT_TYPE%
echo  - Product: %PRODUCT%
echo  - Date: %DDATE%
echo  - Output Directory: %OUTPUT_DIR%

REM ============================================================
REM Get OAuth token
REM ============================================================
echo Requesting OAuth token...
set "TEMP_TOKEN_FILE=%TEMP%\token_%RANDOM%.json"

curl -s -X POST "%API_URL%/token" ^
    -H "Content-Type: application/x-www-form-urlencoded" ^
    -d "grant_type=client_credentials&client_id=%CLIENT_ID%&client_secret=%CLIENT_SECRET%" > "%TEMP_TOKEN_FILE%"

REM Extract access token from JSON response
for /f "tokens=2 delims=:," %%a in ('findstr /C:"access_token" "%TEMP_TOKEN_FILE%"') do (
    set "ACCESS_TOKEN=%%~a"
    set "ACCESS_TOKEN=!ACCESS_TOKEN:"=!"
)
del "%TEMP_TOKEN_FILE%" 2>nul

if not defined ACCESS_TOKEN (
    echo Failed to obtain access token
    exit /b 1
)

echo Access token obtained successfully

REM ============================================================
REM Generate HMAC-SHA256 signature using PowerShell
REM ============================================================
echo Generating signature for download request...

REM Get new timestamp for download
for /f %%i in ('powershell -Command "Get-Date -Date (Get-Date).ToUniversalTime() -UFormat '%%s'"') do set "TIMESTAMP=%%i"
for /f "tokens=1 delims=." %%a in ("%TIMESTAMP%") do set "TIMESTAMP=%%a"

REM Generate signature
for /f "delims=" %%s in ('powershell -Command "$data=[System.Text.Encoding]::UTF8.GetBytes('%TIMESTAMP%'); $key=[System.Text.Encoding]::UTF8.GetBytes('%CLIENT_SECRET%'); $hmac = New-Object System.Security.Cryptography.HMACSHA256; $hmac.Key = $key; $sig = $hmac.ComputeHash($data); [System.BitConverter]::ToString($sig).Replace('-', '').ToLower()"') do (
    set "SIGNATURE=%%s"
)

echo  - Timestamp: %TIMESTAMP%
echo  - Signature: %SIGNATURE%

REM ============================================================
REM Prepare JSON payload and send report request
REM ============================================================
echo Sending report request...

set "TEMP_RESPONSE_FILE=%TEMP%\response_%RANDOM%.json"
set "PAYLOAD={\"fiid\":\"%FIID%\",\"report_type\":\"%REPORT_TYPE%\",\"product\":\"%PRODUCT%\",\"date\":\"%DDATE%\""
if defined WINDOW set "PAYLOAD=%PAYLOAD%,\"window\":\"%WINDOW%\""
set "PAYLOAD=%PAYLOAD%}"

curl -s -X POST "%API_URL%/v1/reports/download" ^
    -H "Authorization: Bearer %ACCESS_TOKEN%" ^
    -H "X-Timestamp: %TIMESTAMP%" ^
    -H "X-Signature: %SIGNATURE%" ^
    -H "Content-Type: application/json" ^
    -d "%PAYLOAD%" > "%TEMP_RESPONSE_FILE%"

REM Check if response contains URL
findstr /C:"url" "%TEMP_RESPONSE_FILE%" >nul
if errorlevel 1 (
    echo Failed to get download URL
    type "%TEMP_RESPONSE_FILE%"
    del "%TEMP_RESPONSE_FILE%" 2>nul
    exit /b 1
)

REM Extract download URL from response using PowerShell to properly parse JSON
for /f "delims=" %%u in ('powershell -Command "Get-Content '%TEMP_RESPONSE_FILE%' | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object -ExpandProperty url"') do (
    set "DOWNLOAD_URL=%%u"
)
del "%TEMP_RESPONSE_FILE%" 2>nul

if not defined DOWNLOAD_URL (
    echo Failed to extract download URL
    exit /b 1
)

REM Replace \u0026 with & in the URL
set "NEW_URL=%DOWNLOAD_URL:\u0026=&%"

echo Download URL obtained

REM ============================================================
REM Download the file
REM ============================================================
echo Downloading file...

set "HEADERS_FILE=%TEMP%\headers_%RANDOM%.txt"
set "BODY_FILE=%TEMP%\body_%RANDOM%.bin"

echo Making a single request to avoid invalidating the URL...

REM Perform a single request, writing headers and body to separate temp files
curl -sSL -D "%HEADERS_FILE%" -o "%BODY_FILE%" ^
    "%NEW_URL%"

REM Extract Content-Disposition header if present
set "CONTENT_DISPOSITION="
for /f "tokens=* usebackq" %%h in (`findstr /i "Content-Disposition" "%HEADERS_FILE%"`) do (
    set "CONTENT_DISPOSITION=%%h"
)

REM Default filename construction
set "DEFAULT_FILENAME=%REPORT_TYPE%_%PRODUCT%_%DDATE%"


REM Try to extract filename from Content-Disposition
set "FILENAME=%DEFAULT_FILENAME%"
if defined CONTENT_DISPOSITION (
    echo CONTENT_DISPOSITION is defined
    echo %CONTENT_DISPOSITION% | findstr /R /C:"filename\*=UTF-8''" > nul
    for /f "tokens=2 delims==" %%f in ("!CONTENT_DISPOSITION!") do (
        set "EXTRACTED=%%f"
        echo %EXTRACTED%
        REM Remove quotes, semicolons, and trim spaces
        set "EXTRACTED=!EXTRACTED:"=!"
        set "EXTRACTED=!EXTRACTED:;=!"
        set "EXTRACTED=!EXTRACTED: =!"
        if not "!EXTRACTED!"=="" (
            set "FILENAME=!EXTRACTED!"
            echo Server provided filename: !FILENAME!
        )
    )
) else (
    echo No Content-Disposition header. Using default filename: %FILENAME%
)

set "FULL_PATH=%OUTPUT_DIR%%FILENAME%"
echo Moving downloaded file to: %FULL_PATH%
move /Y "%BODY_FILE%" "%FULL_PATH%" >nul

REM ============================================================
REM Validate the downloaded file
REM ============================================================
if exist "%BODY_FILE%" del "%BODY_FILE%" 2>nul

REM Check for auth errors in content
findstr /C:"OTT invalid" /C:"Invalid token" "%FULL_PATH%" >nul
if not errorlevel 1 (
    echo ERROR: Authentication error when downloading the file
    echo File contents indicate an authentication problem:
    type "%FULL_PATH%"
    del "%FULL_PATH%" 2>nul
    exit /b 1
)

REM Check if file exists and is not empty
if not exist "%FULL_PATH%" (
    echo Download appeared to succeed, but file is not found
    echo Expected file path: %FULL_PATH%
    exit /b 1
)

for %%F in ("%FULL_PATH%") do if %%~zF==0 (
    echo Download appeared to succeed, but file is empty
    del "%FULL_PATH%" 2>nul
    exit /b 1
)

echo File downloaded successfully
echo Saved to: %FULL_PATH%

endlocal
exit /b 0

REM Script: download_report.bat
REM Description: Downloads reports using authentication tokens and signatures
REM Usage: download_report.bat [options]

REM ============================================================
REM Function to display usage
REM ============================================================
:usage
echo Usage: %~nx0 [OPTIONS]
echo.
echo Options:
echo   --client-id           Client ID for authentication (required)
echo   --client-secret       Client secret for authentication (required)
echo   --fiid                FIID or alias e.g. mbb, cimb, rhb (required)
echo   --report              Type of report to download (required)
echo   --date                Date for the report in YYYY-MM-DD format (required)
echo   --product             Product type (required)
echo   --output-dir          Directory to save downloaded files (optional)
echo   --api-url             API URL (optional)
echo   --help                Display this help message
echo.
echo Example:
echo   %~nx0 --client-id myclient --client-secret mysecret --fiid MBB --report SETL01 --date 2024-11-08 --product mydebit
echo   %~nx0 --client-id myclient --client-secret mysecret --fiid CIMB --report DFCUP --date 2024-11-08 --product san
echo   %~nx0 --client-id myclient --client-secret mysecret --fiid RHB --report SETL01_C1 --date 2024-11-08 --product mydebit --output-dir .\downloads
goto :eof

:help
echo Run %~nx0 --help' for usage information
goto :eof