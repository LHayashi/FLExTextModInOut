# Specify the path to the directory containing the audio files
$directoryPath = "C:\Users\lhtre\Documents\App Builder\Reading Apps\App Projects\HaislaNuyemVol1\HaislaNuyemVol1_data\audio"

# Output XML file
$xmlFile = "C:\Users\lhtre\Documents\App Builder\Reading Apps\App Projects\HaislaNuyemVol1\HaislaNuyemVol1_data\audio\audio_report.xml"

# Create a Shell.Application object
$shell = New-Object -ComObject Shell.Application
$folder = $shell.Namespace($directoryPath)

# Define the property numbers for length and size
$lengthProperty = 27  # Audio length
$sizeProperty = 1     # File size

# Create XML document
$xmlWriter = New-Object System.XMl.XmlTextWriter($xmlFile, $null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteStartElement('AudioFiles')

# Process each audio file
$audioFiles = Get-ChildItem -Path $directoryPath -Include *.mp3, *.wav -Recurse
foreach ($file in $audioFiles) {
    $folderItem = $folder.ParseName($file.Name)
    if ($folderItem) {
        $duration = $folder.GetDetailsOf($folderItem, $lengthProperty)
        $size = $folder.GetDetailsOf($folderItem, $sizeProperty)

        $xmlWriter.WriteStartElement('File')
        $xmlWriter.WriteAttributeString('Name', $file.Name)
        $xmlWriter.WriteElementString('Duration', $duration)
        $xmlWriter.WriteElementString('Size', $size)
        $xmlWriter.WriteEndElement() # File
    }
}

# Close XML elements and document
$xmlWriter.WriteEndElement() # AudioFiles
$xmlWriter.WriteEndDocument()
$xmlWriter.Close()

# Cleanup COM object
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
Remove-Variable shell

Write-Output "XML report generated at $xmlFile"
