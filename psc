/* Load XML into XmlDoc */
Local XmlDoc &xmlDoc = CreateXmlDoc("<?xml version='1.0' encoding='UTF-8'?>
<root xmlns:ns='http://example.com/ns'>
  <ns:item>Item 1</ns:item>
  <ns:item>Item 2</ns:item>
</root>");

/* Define the namespace prefix and URI */
Local string &namespacePrefix = "ns";
Local string &namespaceUri = "http://example.com/ns";

/* Register the namespace */
&xmlDoc.AddNameSpace(&namespacePrefix, &namespaceUri);

/* Find nodes with namespace using XPath */
Local XmlNode &rootNode = &xmlDoc.DocumentElement;
Local XmlNodeList &nodeList = &rootNode.SelectNodes("//ns:item");

Local XmlNode &node;
For &node in &nodeList
   /* Process each found node */
   WinMessage("Node Value: " | &node.NodeValue, 0);
End-For;
