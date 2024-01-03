param(
    [string]$BranchName = "main",
    [string]$DirectoryName
)

$originalURL = "https://github.com/MicrosoftAzureAaron/deployVNETGW/blob/7711e56f944f0d3b483db742abb991eabca33bc2/VNETGateway/src/main.json"
$removeBlob = $originalURL.Remove($originalURL.IndexOf("/blob"), 5)
$shortURL = $removeBlob.Substring(14)
$rawURL = "https://raw.githubusercontent${shortURL}"
$encodedURL = [uri]::EscapeDataString($rawURL)

return "[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/${encodedURL})"
