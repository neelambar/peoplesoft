# Set variables
$confluenceUrl = "https://your-confluence-instance.atlassian.net/wiki"
$spaceKey = "SPACEKEY"
$username = "your.email@example.com"
$apiToken = "your_api_token"
$outputDirectory = "C:\path\to\output\"

# Create the authorization header
$authHeader = @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$username:$apiToken"))
}

# Function to export a single page as PDF
function Export-PageAsPdf {
    param (
        [string]$pageId,
        [string]$title
    )

    # Replace invalid characters in the title for file naming
    $safeTitle = $title -replace '[\/:*?"<>|]', ''

    # Form the URL to download the page as PDF
    $pdfUrl = "$confluenceUrl/export/pdf/$pageId"

    # Define the output path for the PDF
    $outputPath = Join-Path -Path $outputDirectory -ChildPath "$safeTitle.pdf"

    # Make the API request to download the PDF
    Invoke-WebRequest -Uri $pdfUrl -Headers $authHeader -Method Get -OutFile $outputPath

    Write-Output "Downloaded $title as PDF"
}

# Get all pages in the space
$pageUrl = "$confluenceUrl/rest/api/content?spaceKey=$spaceKey&limit=1000&expand=title"
$response = Invoke-RestMethod -Uri $pageUrl -Headers $authHeader -Method Get

# Export each page as PDF
foreach ($page in $response.results) {
    Export-PageAsPdf -pageId $page.id -title $page.title
}

Write-Output "All pages from space '$spaceKey' have been exported."
