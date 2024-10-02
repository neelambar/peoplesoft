# Path to your XML file
$xmlFilePath = "C:\path\to\your\file.xml"

# Load the XML file
[xml]$xml = Get-Content $xmlFilePath

# Define the namespace manager
$namespaceMgr = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)

# Add the namespace(s) used in the XML file (replace 'ns' and 'http://example.com/namespace' with actual values)
$namespaceMgr.AddNamespace("ns", "http://example.com/namespace")

# Loop through all 'content' tags in the namespace
foreach ($content in $xml.SelectNodes("//ns:content", $namespaceMgr)) {
    
    # Check if content length is greater than 70000
    if ($content.'#text'.Length -gt 70000) {
        
        # Get the parent node
        $parent = $content.ParentNode

        # Find the 'docid' tag under the parent node in the namespace
        $docid = $parent.SelectSingleNode("ns:docid", $namespaceMgr)
        
        # Output the docid value if it exists
        if ($docid -ne $null) {
            Write-Output "Content Length: $($content.'#text'.Length)"
            Write-Output "DocID: $($docid.InnerText)"
        }
    }
}
