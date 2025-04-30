# report-proxy-fi



## Getting started

This is a public facing API running on a Lambda function of OSP's report API

## How to use the automation script

Below is a concise guide on how to use the provided Bash (`.sh`) and Batch (`.bat`) scripts for downloading reports.

## Script flags

**Options**

- `--client-id` – Client ID for authentication (required)
- `--client-secret` – Client secret for authentication (required)
- `--fiid` – (Optional) FIID or financial institution ID
- `--report` – Report type to download (required)
- `--date` – Date (YYYY-MM-DD) for the report (required)
- `--product` - Product type; san or mydebit (required)
- `--window` – (Optional) Additional windowing parameter for the report
- `--output-dir` – (Optional) Directory to save downloaded files; defaults to current directory if missing
- `--api-url` – (Optional) Report service API URL; defaults to https://api.reports.paynet.my
- `--help` – Display the script’s built-in usage message

### Bash Script (Linux/macOS)
**Prerequisites**

- Bash shell environment (e.g., Linux or macOS terminal).
- OpenSSL for generating HMAC signatures.
- curl for sending HTTP requests.

**How to Run**
```bash
./download_report.sh [OPTIONS]
```

If the script isn’t marked as executable, make it executable first:

```bash
chmod +x download_report.sh
```

Example
```bash
./download_report.sh \
  --client-id myclient \
  --client-secret mysecret \
  --report SETEL01 \
  --date 2024-06-10 \
  --product MYDEBIT \
  --fiid FIID \
  --api-url https://api.reports.uat.inet.paynet.my \
  --output-dir ./downloads
```

### Batch Script (Windows)

**Prerequisites**

- Windows environment (Command Prompt or PowerShell)
- curl.exe in your PATH

**How to Run**
Open Command Prompt or PowerShell, then run:

```shell
download_report.bat [OPTIONS]
```

Adjust the path if the script is not in the current directory.

**Example**

```shell
download_report.bat ^
  --client-id myclient ^
  --client-secret mysecret ^
  --report SETEL01 ^
  --date 2024-11-08 ^
  --product MYDEBIT ^
  --fiid FIID ^
  --api-url https://api.reports.uat.inet.paynet.my
```

### Troubleshooting

1. **OpenSSL or curl not found**

   - Install them or add to your system PATH.

2. **Permission denied (Linux/macOS)**

   - Ensure the script is executable: chmod +x download_report.sh.

3. **Invalid token / authentication failed**

   - Double-check your client credentials or HMAC signature logic.

4. **Empty/missing file/OTT Invalid**
   
   - The one-time URL may have expired or been used already. Retry obtaining the URL with fresh credentials.

### Troubleshooting

For more information , please visit the following online resource available on PayNet's Developer's Portal 

- [Overview](https://docs.developer.paynet.my/docs/operations/financial-reports/financial-reports-v1/overview) 
- [API Explorer](https://docs.developer.paynet.my/api-reference/reports/reports) 