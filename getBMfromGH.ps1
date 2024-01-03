# Function to download .bicep files from GitHub URLs
function get-BiMods {
    param (
        [string]$ListFilePath,
        [string]$LocalModuleFolder
    )

    # Create the local module folder if it doesn't exist
    if (-not (Test-Path $LocalModuleFolder)) {
        New-Item -ItemType Directory -Path $LocalModuleFolder | Out-Null
    }

    # Read the list of GitHub URLs from the text file
    $urls = Get-Content $ListFilePath

    foreach ($url in $urls) {
        # Extract the file name and subfolder from the URL
        $uri = [System.Uri]$url
        #write-host "uri = $uri"
        $subfolder = $uri -replace "^https://raw.githubusercontent.com/MicrosoftAzureAaron/deployVNETGW/main/modules/", ""
        #write-host "subfolder1 = $subfolder"
        $subfolder = $subfolder -replace '[^/]*$', ''
        #write-host "subfolder2 = $subfolder"
        $subfolder = $subfolder -replace '/', ''
        #write-host "subfolder3 = $subfolder"
        $fileName = $uri -replace '.+\/', ''
        #write-host "filename = $filename"
        
        if (-not (Test-Path $LocalModuleFolder)) {
            New-Item -ItemType Directory -Path $LocalModuleFolder | Out-Null
            write-host "created module folder $LocalModuleFolder"
        }

        # Construct the local subfolder path for the downloaded file
        $localSubfolder = Join-Path $LocalModuleFolder $subfolder

        #write-host "looking for $subfolder in $moduleFolder"
        # Create the local subfolder if it doesn't exist
        if (-not (Test-Path $localSubfolder)) {
            New-Item -ItemType Directory -Path $localSubfolder | Out-Null
            write-host "created sub folder $localsubfolder"
        }
        
        # Construct the local path for the downloaded file
        $localPath = Join-Path $localSubfolder $fileName
        write-host "writing to $localpath"

        # Download the file using wget or Invoke-WebRequest
        Invoke-WebRequest -Uri $url -OutFile $localPath
    }
}

# Function to read main.bicep and identify required modules
function Get-RequiredModules {
    param (
        [string]$MainBicepFilePath
    )

    # Read the content of main.bicep
    $mods = Get-Content $MainBicepFilePath -Raw

    foreach ($mod in $mods -split '\r?\n') {
        if ($mod -match '^\s*module\s') {
            $mod = $mod -replace '.*modules/', ''
            $mod = $mod -replace "\' = \{", ''
            #write-host "$mod"
            $moduleNames += "$mod`n"
        }
    }
    
    return $moduleNames
}

# Example usage
$moduleFolder = "C:\Users\aarosanders\OneDrive - Microsoft\Desktop\Deploy VNET GW Bicep\Azure_Networking_Labs\modules"
$listFilePath = "C:\Users\aarosanders\OneDrive - Microsoft\Desktop\Deploy VNET GW Bicep\Azure_Networking_Labs\repolist.txt"
$mainBicepFilePath = "C:\Users\aarosanders\OneDrive - Microsoft\Desktop\Deploy VNET GW Bicep\Azure_Networking_Labs\VNETGateway\src\main.bicep"

# Download .bicep files from the list
get-BiMods -ListFilePath $listFilePath -LocalModuleFolder $moduleFolder

# Get required modules from main.bicep
$requiredModules = Get-RequiredModules -MainBicepFilePath $mainBicepFilePath

# Display the list of required modules
Write-Host "Required Modules: `n$requiredModules"