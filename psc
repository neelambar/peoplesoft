function Get-Wget {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [string]$OutFile,

        [switch]$DownloadResources
    )

    # Define a base directory for downloaded resources
    $baseDirectory = Split-Path -Path $OutFile -Parent
    $cssDirectory = Join-Path $baseDirectory "css"
    $jsDirectory = Join-Path $baseDirectory "js"
    $imagesDirectory = Join-Path $baseDirectory "images"

    # Create directories for resources if they do not exist
    New-Item -ItemType Directory -Force -Path $cssDirectory, $jsDirectory, $imagesDirectory

    # Download the main HTML file
    Write-Host "Downloading $Url to $OutFile"
    Invoke-WebRequest -Uri $Url -OutFile $OutFile

    # If the -DownloadResources switch is specified, download linked resources
    if ($DownloadResources) {
        Write-Host "Downloading linked resources..."

        # Load the HTML content
        $htmlContent = Get-Content $OutFile -Raw

        # Regex patterns to identify resource URLs
        $cssRegex = '<link[^>]+href=["'']([^"''>]+\.css(\?[^"''>]*)?)["'']'
        $jsRegex = '<script[^>]+src=["'']([^"''>]+\.js(\?[^"''>]*)?)["'']'
        $imgRegex = '<img[^>]+src=["'']([^"''>]+(\?[^"''>]*)?)["'']'

        # Function to download resources and update the HTML
        function Download-And-UpdateResource {
            param (
                [string]$resourceUrl,
                [string]$destinationDirectory
            )

            # Remove query parameters from the resource URL
            $cleanUrl = $resourceUrl.Split('?')[0]

            # Resolve relative URLs
            $resourceUri = New-Object System.Uri($cleanUrl, [System.UriKind]::RelativeOrAbsolute)
            if (-not $resourceUri.IsAbsoluteUri) {
                $resourceUri = New-Object System.Uri((New-Object System.Uri($Url)), $resourceUri)
            }

            $fileName = [System.IO.Path]::GetFileName($resourceUri.AbsoluteUri)
            $destinationPath = Join-Path $destinationDirectory $fileName

            # Download the resource
            Write-Host "Downloading resource $resourceUri to $destinationPath"
            Invoke-WebRequest -Uri $resourceUri.AbsoluteUri -OutFile $destinationPath

            # Return the relative path for updating the HTML
            return "./" + [System.IO.Path]::GetFileName($destinationDirectory) + "/" + $fileName
        }

        # Function to process matches, download resources, and update HTML
        function Process-Matches {
            param (
                [string]$htmlContent,
                [string]$regexPattern,
                [string]$destinationDirectory
            )

            # Create a regex object and find matches
            $regex = New-Object System.Text.RegularExpressions.Regex($regexPattern)
            $matches = $regex.Matches($htmlContent)

            # Iterate over all matches
            foreach ($match in $matches) {
                $resourceUrl = $match.Groups[1].Value
                if ($resourceUrl) {
                    $newPath = Download-And-UpdateResource $resourceUrl $destinationDirectory
                    $escapedUrl = [regex]::Escape($resourceUrl)
                    $htmlContent = $htmlContent -replace $escapedUrl, $newPath
                }
            }
            return $htmlContent
        }

        # Process and download each resource type
        $htmlContent = Process-Matches $htmlContent $cssRegex $cssDirectory
        $htmlContent = Process-Matches $htmlContent $jsRegex $jsDirectory
        $htmlContent = Process-Matches $htmlContent $imgRegex $imagesDirectory

        # Save the updated HTML content
        Set-Content -Path $OutFile -Value $htmlContent
    }
}

# Example usage:
Get-Wget -Url "https://confluence.atlassian.com/doc/blog/2015/08/create-sprint-retrospective-and-demo-pages-like-a-boss" -OutFile "C:\temp\download\index.html" -DownloadResources
