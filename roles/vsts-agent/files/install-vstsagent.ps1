$LatestRelease = Invoke-WebRequest -Uri https://api.github.com/repos/Microsoft/vsts-agent/releases/latest|ConvertFrom-Json
$Filename = "vsts_agent_$($LatestRelease.tag_name).zip"
$DownloadPath = "$($env:APPDATA)\$($Filename)"

$InstallPath = "c:\vsts-agent"

function Install-VSTSAgent{
    mkdir -Path $InstallPath
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$DownloadPath", "$InstallPath")
}

function Get-VSTSAgent{
    Write-Host "Download version ($($LatestRelease.tag_name)) of VSTS-Agent"
    Invoke-WebRequest $LatestRelease.zipball_url -OutFile $DownloadPath
}

function Test-VSTSAgentExists
{
    [CmdletBinding()]
    param(
        [string] $InstallPath
    )
    
    $agentConfigFile = Join-Path $InstallPath '.agent'

    if (Test-Path $agentConfigFile)
    {
        $Agent = Get-Content -Path $agentConfigFile | ConvertFrom-Json
        Write-Host " ------------------------------------------------ "
        Write-Host "|VSTS-Agent is already configured in this machine|"
        Write-Host " ------------------------------------------------ "
        Write-Host "    AgentName       : $($Agent.agentName)         "
        Write-Host "    AgentID         : $($Agent.agentId)           "
        Write-Host "    AgentServerUrl  : $($Agent.serverUrl)         "
    }
}

If(!(Test-Path -Path $DownloadPath )){
    Get-VSTSAgent    
}

If(!(Test-Path -Path $InstallPath)){
    Install-VSTSAgent
}
else {
    $agentConfigFile = Join-Path $InstallPath '.agent'
    Write-Host "Agent already installed"
    if (!(Test-Path $agentConfigFile))
    {
        Write-Host "Agent is not configured"
    }
    Else{
        Test-VSTSAgentExists -InstallPath $InstallPath
    }
    
}


