param(
  [string]$ProjectName = "academicdash",
  [string]$Target = "production"
)

$ErrorActionPreference = "Stop"

if (-not $env:VERCEL_TOKEN) {
  throw "Missing VERCEL_TOKEN. Create one at https://vercel.com/account/tokens, then set `$env:VERCEL_TOKEN before running."
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$files = @("index.html", "vercel.json", "package.json") | ForEach-Object {
  $path = Join-Path $root $_
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required file: $_"
  }
  @{
    file = $_
    data = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  }
}

$body = @{
  name = $ProjectName
  target = $Target
  files = $files
  projectSettings = @{
    framework = $null
    buildCommand = $null
    devCommand = $null
    installCommand = $null
    outputDirectory = $null
  }
} | ConvertTo-Json -Depth 8

$headers = @{
  Authorization = "Bearer $env:VERCEL_TOKEN"
  "Content-Type" = "application/json"
}

$uri = "https://api.vercel.com/v13/deployments?skipAutoDetectionConfirmation=1&forceNew=1"
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body

[pscustomobject]@{
  Id = $response.id
  ReadyState = $response.readyState
  Url = "https://$($response.url)"
  InspectUrl = $response.inspectorUrl
}
