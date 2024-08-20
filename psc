# Define the URL and output directory
$url = "https://example.com"
$outputDirectory = "C:\path\to\downloaded_site"

# Create the output directory if it doesn't exist
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -Path $outputDirectory -ItemType Directory
}

# Function to download the HTML page
function Download-HTMLPage {
    param(
        [string]$url,
        [string]$outputDirectory
    )
    
    # Download the HTML content
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    $htmlContent = $response.Content
    
    # Save the HTML content to a file
    $htmlFilePath = Join-Path $outputDirectory "index.html"
    Set-Content -Path $htmlFilePath -Value $htmlContent
    
    return $htmlFilePath
}

# Function to download resources and update HTML
function Download-Resources {
    param(
        [string]$htmlFilePath,
        [string]$outputDirectory
    )
    
    # Load the HTML content
    $htmlContent = Get-Content -Path $htmlFilePath
    
    # Match resource links (images, CSS, JS)
    $htmlContent = $htmlContent -replace '(<img[^>]+?src=["\'])([^"\']+)(["\'])', {
        $resourceUrl = $matches[2]
        $localPath = Download-Resource -url $resourceUrl -outputDirectory $outputDirectory
        "$($matches[1])$localPath$($matches[3])"
    }
    
    $htmlContent = $htmlContent -replace '(<link[^>]+?href=["\'])([^"\']+)(["\'])', {
        $resourceUrl = $matches[2]
        $localPath = Download-Resource -url $resourceUrl -outputDirectory $outputDirectory
        "$($matches[1])$localPath$($matches[3])"
    }
    
    $htmlContent = $htmlContent -replace '(<script[^>]+?src=["\'])([^"\']+)(["\'])', {
        $resourceUrl = $matches[2]
        $localPath = Download-Resource -url $resourceUrl -outputDirectory $outputDirectory
        "$($matches[1])$localPath$($matches[3])"
    }

    # Save the modified HTML content
    Set-Content -Path $htmlFilePath -Value $htmlContent
}

# Function to download individual resources
function Download-Resource {
    param(
        [string]$url,
        [string]$outputDirectory
    )

    # Handle relative URLs
    if ($url -notmatch "^https?:\/\/") {
        $baseUri = [System.Uri]$global:url
        $resourceUri = New-Object System.Uri($baseUri, $url)
        $url = $resourceUri.AbsoluteUri
    }
    
    # Get the resource file name
    $fileName = [System.IO.Path]::GetFileName($url)
    $outputPath = Join-Path $outputDirectory $fileName

    try {
        # Download the resource
        Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
        Write-Host "Downloaded: $url -> $outputPath"
        return $fileName
    } catch {
        Write-Warning "Failed to download resource: $url"
        return $url  # Return the original URL if download fails
    }
}

# Start the process
$htmlFilePath = Download-HTMLPage -url $url -outputDirectory $outputDirectory
Download-Resources -htmlFilePath $htmlFilePath -outputDirectory $outputDirectory

Write-Host "Download completed successfully."
