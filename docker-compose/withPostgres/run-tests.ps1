# Test Automation Script for n8n Property Agent Workflow

# 1. Load Sample Data
$sampleDataPath = ".\test-data\sample_data.json"
if (-not (Test-Path $sampleDataPath)) {
    # Fallback path just in case
    $sampleDataPath = "C:\Users\kaisian\.gemini\antigravity\brain\3c1c8613-c0c1-43cb-8dca-f94cbd18beff\test-data\sample_data.json"
}

if (-not (Test-Path $sampleDataPath)) {
    Write-Error "Sample data file not found!"
    exit
}

$data = Get-Content $sampleDataPath | ConvertFrom-Json

# 2. Prompt for Webhook URL
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Property Agent Workflow Tester      " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please enter your n8n Webhook URL."
Write-Host "You can find this in the 'Telegram Webhook' node in n8n."
Write-Host "Format: https://...hooks.n8n.cloud/webhook/..."
Write-Host "   OR: http://localhost:5678/webhook-test/... (for local testing)"
Write-Host ""

$webhookUrl = Read-Host "Webhook URL"

if ([string]::IsNullOrWhiteSpace($webhookUrl)) {
    Write-Error "URL cannot be empty."
    exit
}

# 3. Execute Tests
$testCases = $data.test_webhooks

foreach ($test in $testCases) {
    Write-Host "`n------------------------------------------"
    Write-Host "Running Test: $($test.description)" -ForegroundColor Yellow
    Write-Host "Sending Message: $($test.payload.message.text)"
    
    try {
        # Convert payload to JSON string
        $body = $test.payload | ConvertTo-Json -Depth 10
        
        # Send POST request
        $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        
        Write-Host "Status: Success" -ForegroundColor Green
        Write-Host "Response: $response"
    }
    catch {
        Write-Host "Status: Failed" -ForegroundColor Red
        Write-Host "Error: $_"
    }
    
    Start-Sleep -Seconds 1
}

Write-Host "`nDone! Check your n8n 'Executions' tab to see the detailed flow." -ForegroundColor Cyan
