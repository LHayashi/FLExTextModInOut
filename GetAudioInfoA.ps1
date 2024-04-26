# Specify the path to the directory containing the audio files
$directoryPath = "C:\Users\lhtre\Documents\App Builder\Reading Apps\App Projects\HaislaNuyemVol1\HaislaNuyemVol1_data\audio"

# Output XML file
$xmlFile = "C:\Users\lhtre\Documents\App Builder\Reading Apps\App Projects\HaislaNuyemVol1\HaislaNuyemVol1_data\audio\audio_report.xml"

# Path to ffmpeg executable
$ffmpegProbePath = "C:\Program Files\ffmpeg-master-latest-win64-gpl-shared\bin\ffprobe.exe"

# Create XML document
$xmlWriter = New-Object System.Xml.XmlTextWriter($xmlFile, $null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteStartElement('AudioFiles')

# Get all audio files in the directory
$audioFiles = Get-ChildItem -Path $directoryPath -Include *.mp3, *.wav -Recurse
foreach ($file in $audioFiles) {
    # Run ffmpeg to get the duration in seconds, log errors to a separate file
    $args = "-i `"$($file.FullName)`" -show_entries format=duration -v quiet -of csv=`"p=0`""
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $ffmpegProbePath
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    $processInfo.Arguments = $args
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $process.Start() | Out-Null
    $process.WaitForExit()
    $output = $process.StandardOutput.ReadToEnd()
    $errors = $process.StandardError.ReadToEnd()

    # Handle ffmpeg output for duration
    if (-not [string]::IsNullOrWhiteSpace($output)) {
        $durationInSeconds = 0
        [double]::TryParse($output, [ref]$durationInSeconds)
        $durationInMilliseconds = $durationInSeconds * 1000
    } else {
        $durationInMilliseconds = 0
    }

    # Get file size directly from the file properties
    $fileSizeBytes = $file.Length

    # Write details to XML
    $xmlWriter.WriteStartElement('File')
    $xmlWriter.WriteAttributeString('Name', $file.Name)
    $xmlWriter.WriteElementString('DurationMillis', $durationInMilliseconds.ToString("F0"))
    $xmlWriter.WriteElementString('SizeBytes', $fileSizeBytes.ToString())
    $xmlWriter.WriteEndElement() # File

    # Log errors if any
    if ($errors) {
        Add-Content -Path "C:\Path\To\Your\ffmpeg_error.log" -Value "Error processing file $($file.FullName): $errors"
    }
}

# Close XML elements and document
$xmlWriter.WriteEndElement() # AudioFiles
$xmlWriter.WriteEndDocument()
$xmlWriter.Close()

Write-Output "XML report generated at $xmlFile"
Write-Output "Check ffmpeg_error.log for any processing errors"












