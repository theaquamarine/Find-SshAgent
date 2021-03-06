#Inspired by ssh-find-agent https://github.com/wwalker/ssh-find-agent

function Find-SshAgentSockets() {
    (Get-ChildItem $env:TEMP -Filter 'ssh*' |
    Get-ChildItem -Filter 'agent.*'
    ).FullName.Replace($env:TEMP,'/tmp').Replace('\','/')
}

function Test-AgentSocket() {
    $env:SSH_AUTH_SOCK = $_
    & 'C:\Program Files\Git\bin\ssh-add' '-l' *> $null # Not quick if agent is dead
    # exit codes:
    # 0 = success
    # 1 = specified command fails (running, no identities)
    # 2 = unable to contact agent
    Remove-Item Env:\SSH_AUTH_SOCK
    if ($LastExitCode -eq 0 -or $LastExitCode -eq 1) {return $true}
    else {return $false}
}

function Test-SshAgentSockets() {
    param(
    [Parameter(
        Position=0,
        Mandatory,
        ValueFromPipeline
    )]
    [String[]]$Agents
    )
    process {
        foreach($Agent in $Agents) {
            if (Test-AgentSocket $Agent) {
                Write-Output $Agent
            }
        }
    }
}

function Set-SshAgentSocket() {
    param(
    [Parameter(
        Position=0,
        Mandatory,
        ValueFromPipeline
    )]
    [String[]]$Agents
    )

    $env:SSH_AUTH_SOCK = $Agents | Select -First 1
}

Find-SshAgentSockets |
Test-SshAgentSockets |
Set-SshAgentSocket

#TODO: clean up any dead agents
#TODO: exit as soon as a working agent is found
#TODO: compare number of keys loaded
#TODO: sort found agents somehow to test most likely first