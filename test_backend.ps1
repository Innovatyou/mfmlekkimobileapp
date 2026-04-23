$uri = "https://church.innovative.ng/initapp"
$token = "4f1a23de-8899-4b22-b111-98db6cc77b11"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    "data" = @{
        "email" = ""
    }
} | ConvertTo-Json

Write-Host "Testing POST to $uri"
Write-Host "Headers: $headers"
Write-Host "Body: $body"
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $uri -Method Post -Headers $headers -Body $body -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Error Status: $($_.Exception.Response.StatusCode)"
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody"
    }
}
