# Define variables
$tenantId = "<Your-Tenant-ID>"
# Service principal ID 
$clientId = "<Your-Client-ID>"
# Service principal secret 
$clientSecret = "<Your-Client-Secret>"
# ID of the group to add to the enterprise application
$groupId = "<IdP-Group-ID>"
# ID of the enterprise application
$enterpriseAppId = "<Enterprise-Application-ID>"

# Get an access token
$body = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $clientId
    client_secret = $clientSecret
}

$response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $response.access_token

# Add the group to the enterprise application
$uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$enterpriseAppId/appRoleAssignments"
$headers = @{
    Authorization = "Bearer $accessToken"
    ContentType   = "application/json"
}

$body = @{
    principalId   = $groupId
    resourceId    = $enterpriseAppId
    appRoleId     = "00000000-0000-0000-0000-000000000000" # Use the appropriate app role ID
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body

Write-Output "Group added to the enterprise application successfully."