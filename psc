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

# Function to download a single attachment
function Download-Attachment {
    param (
        [string]$downloadUrl,
        [string]$fileName,
        [string]$pageTitle
    )

    # Create a safe directory name based on the page title
    $safeTitle = $pageTitle -replace '[\/:*?"<>|]', ''
    $pageDirectory = Join-Path -Path $outputDirectory -ChildPath $safeTitle

    # Create the directory if it doesn't exist
    if (-not (Test-Path -Path $pageDirectory)) {
        New-Item -Path $pageDirectory -ItemType Directory | Out-Null
    }

    # Define the full output path for the attachment
    $outputPath = Join-Path -Path $pageDirectory -ChildPath $fileName

    # Download the attachment
    Invoke-WebRequest -Uri $downloadUrl -Headers $authHeader -OutFile $outputPath

    Write-Output "Downloaded $fileName from $pageTitle"
}

# Get all pages in the space
$pageUrl = "$confluenceUrl/rest/api/content?spaceKey=$spaceKey&limit=1000&expand=title"
$response = Invoke-RestMethod -Uri $pageUrl -Headers $authHeader -Method Get

# Iterate over each page
foreach ($page in $response.results) {
    $pageId = $page.id
    $pageTitle = $page.title

    # Get all attachments for the current page
    $attachmentUrl = "$confluenceUrl/rest/api/content/$pageId/child/attachment?limit=1000"
    $attachmentsResponse = Invoke-RestMethod -Uri $attachmentUrl -Headers $authHeader -Method Get

    foreach ($attachment in $attachmentsResponse.results) {
        $fileName = $attachment.title
        $downloadUrl = "$confluenceUrl$($attachment._links.download)"
        Download-Attachment -downloadUrl $downloadUrl -fileName $fileName -pageTitle $pageTitle
    }
}

Write-Output "All attachments from space '$spaceKey' have been downloaded."
