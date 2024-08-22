# Function to download a file with progress indication
function Download-FileWithProgress($url, $destination) {
    $client = New-Object System.Net.WebClient
    $client.AddHeaders("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6446.79 Safari/537.36")

    $client.DownloadProgressChanged += {
        Write-Progress -Activity "Downloading $url" -Status "($($client.Progress.PercentComplete)%)" -CurrentOperation "Downloading..." -Completed $client.Progress.BytesReceived -Total $client.Progress.TotalBytesToReceive
    }

    $client.DownloadFile($url, $destination)
}

# Function to download a web page and its linked resources
function Download-WebPage($url, $destination) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Encoding = [system.text.encoding]::UTF8

    try {
        $html = $webClient.DownloadString($url)
    } catch {
        Write-Warning "Failed to download $url: $($_.Exception.Message)"
        return
    }

    $baseUri = [Uri]($url)
    $destinationDir = Join-Path $destination $baseUri.AbsolutePath

    # Create destination directory if it doesn't exist
    if (!(Test-Path $destinationDir)) {
        New-Item -Path $destinationDir -ItemType Directory
    }

    # Extract links from HTML (excluding HTML links)
    $links = [regex]::Matches($html, "(src)=\'(?<url>[^\']+)\'") |
             ForEach-Object { $_.Groups["url"].Value } |
             Where-Object { $_.StartsWith("http") }

    # Download linked resources (excluding HTML links)
    foreach ($link in $links) {
        $uri = [Uri]($link)
        $relativePath = $uri.AbsolutePath

        if ($relativePath.EndsWith(".js")) {
            $targetDir = Join-Path $destinationDir "js"
        } elseif ($relativePath.EndsWith(".css")) {
            $targetDir = Join-Path $destinationDir "css"
        } elseif ($relativePath.EndsWith(".png") -or $relativePath.EndsWith(".jpg") -or $relativePath.EndsWith(".jpeg") -or $relativePath.EndsWith(".gif")) {
            $targetDir = Join-Path $destinationDir "images"
        } else {
            continue  # Skip non-resource links (HTML links)
        }

        # Create target directory if it doesn't exist
        if (!(Test-Path $targetDir)) {
            New-Item -Path $targetDir -ItemType Directory
        }

        $targetFile = Join-Path $targetDir $uri.AbsolutePath.Substring(1)
        Download-FileWithProgress $link $targetFile
    }

    # Save the downloaded HTML page
    $htmlFile = Join-Path $destinationDir "index.html"
    Set-Content -Path $htmlFile -Value $html
}

# Get the Confluence URL from the user
$confluenceUrl = Read-Host "Enter the Confluence URL:"

# Specify the destination directory
$destinationDir = "C:\ConfluenceDownload"

# Download the Confluence web page and its linked resources (excluding HTML links)
Download-WebPage $confluenceUrl $destinationDir
