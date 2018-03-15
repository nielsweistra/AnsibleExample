
$Filename = "vsts_agent_$($LatestRelease.tag_name).zip"
$DownloadPath = "$($env:APPDATA)\$($Filename)"

$InstallPath = "c:\vsts-agent"

function Install-VSTSAgent {
    Write-Host "Create install folder"
    New-Item -ItemType directory -Path $InstallPath | Out-Null

    Write-Host "Unpack $($Filename) to $($InstallPath) " 
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$DownloadPath", "$InstallPath")
}

function Get-VSTSAgent {
    $regex = '\b(?:(?:https?|ftp|file)://|www\.|ftp\.)(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#/%=~_|$?!:,.]*\)|[A-Z0-9+&@#/%=~_|$])'
    $LatestRelease = Invoke-WebRequest -Uri https://api.github.com/repos/Microsoft/vsts-agent/releases/latest|ConvertFrom-Json
    $ReleaseArtifacts = Select-String -Pattern $regex -input $LatestRelease.body -AllMatches | ForEach-Object {$_.matches} 
    Write-Host "Download version $($LatestRelease.tag_name) of VSTS-Agent from $($ReleaseArtifacts[0].Value)"
    Invoke-WebRequest $ReleaseArtifacts[0].Value -OutFile $DownloadPath
}

function Test-VSTSAgentExists {
    [CmdletBinding()]
    param(
        [string] $InstallPath
    )
    
    $agentConfigFile = Join-Path $InstallPath '.agent'

    if (Test-Path $agentConfigFile) {
        $Agent = Get-Content -Path $agentConfigFile | ConvertFrom-Json
        Write-Host " -------------------------------------------------- "
        Write-Host "| VSTS-Agent is already configured in this machine |"
        Write-Host " -------------------------------------------------- "
        Write-Host "|    AgentName       : $($Agent.agentName)         |"
        Write-Host "|    AgentID         : $($Agent.agentId)           |"
        Write-Host "|    AgentServerUrl  : $($Agent.serverUrl)         |"
        Write-Host " -------------------------------------------------- "
    }
}

If (!(Test-Path -Path $DownloadPath )) {
    Get-VSTSAgent    
}

If (!(Test-Path -Path $InstallPath)) {
    Install-VSTSAgent
}
else {
    $agentConfigFile = Join-Path $InstallPath '.agent'
    Write-Host "Agent already installed"
    if (!(Test-Path $agentConfigFile)) {
        Write-Host "Agent is not configured"
    }
    Else {
        Test-VSTSAgentExists -InstallPath $InstallPath
    }
    
}


