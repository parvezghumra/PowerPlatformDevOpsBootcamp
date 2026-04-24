# Script to transform a previously tokenised deployment settings file by replacing environment variables and connection references with their actual values.
param(
    [Parameter(Mandatory=$true)]
    $settingsFilePath,
    $environmentVariablesValues,
    $connectionTokens,
    $environmentId,
    $username,
    $password,
    $tenantId,
    $applicationId,
    $clientSecret
)
 
$ErrorActionPreference = 'Stop'
 
function Connect-AdminPowerApp {
    if ($username -and $password) {
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        try {
            Write-Host "Connecting to PowerApps Admin CLI with username and password..."
            Add-PowerAppsAccount -Username $username -Password $securePassword
        }
        catch {
            throw "Failed to authenticate to PowerApps Admin CLI using username and password."
        }
    }
    elseif ($tenantId -and $applicationId -and $clientSecret) {
        try {
            Write-Host "Connecting to PowerApps Admin CLI with service principal..."
            Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $applicationId -ClientSecret $clientSecret
        }
        catch {
            throw "Failed to authenticate to PowerApps Admin CLI using service principal."
        }
    }
    else {
        throw "Insufficient authentication parameters provided. Please provide either username and password, or tenantId, applicationId, and clientSecret."
    }
}
 
function Initialize-RequiredModules {
    Write-Host "Initializing modules..."
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force -AllowClobber -RequiredVersion 2.0.202
    Import-Module Microsoft.PowerApps.Administration.PowerShell -Scope Global -Force
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "Note: Execution policy is already set by a higher scope policy."
    }
}
 
function Update-EnvironmentVariables {
    param($property, $environmentVariablesValues)
   
    Write-Host "Processing SchemaName: $($property.SchemaName)"
    foreach($var in $environmentVariablesValues) {
        if($property.Value -eq $var.StaticToken) {
            $property.Value = $var.Value
            Write-Host "Updated value: $($property.Value)"
            return $true
        }
    }
    return $false
}
 
function Update-ConnectionReferences {
    param($property, $tokens, $connections)
    Write-Host "Processing ConnectorId: $($property.ConnectorId)"
    foreach($token in $tokens) {
        if($property.ConnectionId -eq $token.StaticToken) {
            Write-Host "Processing ConnectionId: $($property.ConnectionId)"
            $matchingConnection = $connections |
                Where-Object { $token.ConnectorId.EndsWith($_.ConnectorName) } |
                Select-Object -First 1
           
            if($matchingConnection) {
                $property.ConnectionId = $matchingConnection.ConnectionName
                Write-Host "Updated ConnectionId: $($property.ConnectionId)"
                return $true
            }
        }
    }
    return $false
}
 
try {
    if(-not (Test-Path $settingsFilePath)) {
        throw "Settings file not found at: $settingsFilePath"
    }
 
    $json = Get-Content -Path $settingsFilePath -Raw | ConvertFrom-Json
    $environmentVariablesValues = $environmentVariablesValues | ConvertFrom-Json
    $connectionTokens = $connectionTokens | ConvertFrom-Json
 
    Initialize-RequiredModules
 
    Connect-AdminPowerApp
 
    $connections = Get-AdminPowerAppConnection -EnvironmentName $environmentId -CreatedBy $username
   
    foreach ($object in $json.PSObject.Properties) {
        Write-Host "Processing object: $($object.Name)"
       
        if ([string]::IsNullOrEmpty($object)) {
            Write-Warning "The $($object.Name) array contains a null or empty string value."
            continue
        }
 
        foreach($property in $object.Value) {
            switch($object.Name) {
                "EnvironmentVariables" {
                    if(-not (Update-EnvironmentVariables -property $property -environmentVariablesValues $environmentVariablesValues)) {
                        throw "Failed to find JSON environment variable object with schemaname $($property.Value)."
                    }
                }
                "ConnectionReferences" {
                    if(-not (Update-ConnectionReferences -property $property -tokens $connectionTokens -connections $connections)) {
                        throw "Failed to find matching connection for connector $($property.ConnectorId)."
                    }
                }
            }
        }
    }
 
    $json | ConvertTo-Json -Depth 4 | Set-Content -Path $settingsFilePath
    Write-Host "Successfully updated settings file"
}
catch {
    Write-Error "Error processing settings file: $_"
    throw
}