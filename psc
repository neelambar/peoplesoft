# Define the URL and the output directory
$url = "http://example.com"
$outputDir = "C:\path\to\output\directory"

# Create directories for resources
$cssDir = "$outputDir\css"
$jsDir = "$outputDir\js"
$imgDir = "$outputDir\img"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path $outputDir, $cssDir, $jsDir, $imgDir

# Download the HTML content
$htmlContent = Invoke-WebRequest -Uri $url

# Parse HTML content
$parsedHtml = [xml]$htmlContent.Content

# Function to download and replace resource links
function Download-Resource {
    param (
        [string]$resourceUrl,
        [string]$resourceDir,
        [string]$resourceTag,
        [string]$attribute
    )

    # Make sure resource URL is absolute
    $absoluteUrl = $resourceUrl
    if ($resourceUrl -notmatch "^https?://") {
        $absoluteUrl = [uri]::new($htmlContent.BaseResponse.ResponseUri, $resourceUrl).AbsoluteUri
    }

    # Determine the local file path
    $fileName = [System.IO.Path]::GetFileName($absoluteUrl)
    $localFilePath = "$resourceDir\$fileName"

    # Download the resource
    Invoke-WebRequest -Uri $absoluteUrl -OutFile $localFilePath

    # Update the HTML content with local file reference
    $parsedHtml.SelectNodes("//$resourceTag[@$attribute='$resourceUrl']") | ForEach-Object {
        $_.$attribute = "$resourceTag/$fileName"
    }
}

# Download and replace CSS links
$parsedHtml.SelectNodes("//link[@rel='stylesheet']") | ForEach-Object {
    $cssUrl = $_.href
    Download-Resource -resourceUrl $cssUrl -resourceDir $cssDir -resourceTag "link" -attribute "href"
}

# Download and replace JavaScript links
$parsedHtml.SelectNodes("//script[@src]") | ForEach-Object {
    $jsUrl = $_.src
    Download-Resource -resourceUrl $jsUrl -resourceDir $jsDir -resourceTag "script" -attribute "src"
}

# Download and replace image links
$parsedHtml.SelectNodes("//img[@src]") | ForEach-Object {
    $imgUrl = $_.src
    Download-Resource -resourceUrl $imgUrl -resourceDir $imgDir -resourceTag "img" -attribute "src"
}

# Save the modified HTML content
$parsedHtml.Save("$outputDir\index.html")

Write-Host "Download complete. HTML and resources saved to $outputDir"
