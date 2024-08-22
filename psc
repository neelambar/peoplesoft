# Define the URL of the page to download
$url = "https://example.com"

# Define the output directory
$outputDir = "C:\DownloadedPage"
$jsDir = "js"
$cssDir = "css"
$imgDir = "img"
$indexFile = "index.html"

# Create the output directory and subdirectories if they don't exist
$dirs = @($outputDir, "$outputDir\$jsDir", "$outputDir\$cssDir", "$outputDir\$imgDir")
foreach ($dir in $dirs) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -Path $dir -ItemType Directory | Out-Null
    }
}

# Download the HTML page
$html = Invoke-WebRequest -Uri $url -UseBasicParsing
$rawHtml = $html.Content

# Save the HTML to a local file
$indexPath = Join-Path -Path $outputDir -ChildPath $indexFile
Set-Content -Path $indexPath -Value $rawHtml

# Function to download resources and update links
function Download-ResourceAndUpdateLink {
    param (
        [string]$resourceUrl,
        [string]$subDir
    )
    
    # Get the resource URI
    $resourceUri = New-Object Uri($resourceUrl, [UriKind]::RelativeOrAbsolute)
    
    if ($resourceUri.IsAbsoluteUri -eq $false) {
        $resourceUri = New-Object Uri($html.BaseResponse.ResponseUri, $resourceUrl)
    }
    
    # Determine the local file path for the resource
    $resourceFileName = [System.IO.Path]::GetFileName($resourceUri.AbsolutePath)
    $localResourcePath = Join-Path -Path (Join-Path -Path $outputDir -ChildPath $subDir) -ChildPath $resourceFileName
    
    # Download the resource
    try {
        Invoke-WebRequest -Uri $resourceUri.AbsoluteUri -OutFile $localResourcePath -UseBasicParsing
    } catch {
        Write-Warning "Failed to download $resourceUri"
        return $resourceUrl  # Return the original URL if download fails
    }
    
    # Return the local resource path relative to the output directory
    return Join-Path -Path $subDir -ChildPath $resourceFileName
}

# Update the HTML content and download resources
$rawHtml = $rawHtml -replace "(href|src)=([""'])([^""']+)([""'])", {
    param($match)
    $attribute = $match[1]
    $quote = $match[2]
    $resourceUrl = $match[3]
    
    # Determine the correct subdirectory based on the resource type
    $subDir = switch -regex ($resourceUrl) {
        '\.js$' { $jsDir }
        '\.css$' { $cssDir }
        '\.(jpg|jpeg|png|gif|svg)$' { $imgDir }
        default { "" }
    }

    if ($subDir) {
        $localResource = Download-ResourceAndUpdateLink $resourceUrl $subDir
        return "$attribute=$quote$localResource$quote"
    } else {
        return $match.Value  # Keep the original URL if the resource type is not recognized
    }
}

# Save the updated HTML
Set-Content -Path $indexPath -Value $rawHtml

Write-Host "Downloaded HTML and resources to $outputDir"
