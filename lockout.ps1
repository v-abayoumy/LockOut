#Start
if (!([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')) { Clear-Host; Read-Host "Please run PowerShell As Administrator and rerun this commands, Press any key to exit"; exit }
Import-Module activedirectory 
$PDC = (Get-ADDomainController -Filter * | Where-Object { $_.OperationMasterRoles -contains "PDCEmulator" })
$UserName = "abayoumy" # Read-Host "Please enter username"
$LockedOutEvents = Get-WinEvent -ComputerName $PDC.HostName -FilterHashtable @{LogName = 'Security'; Id = 4625, 4740, 4771; data = $UserName } -ErrorAction silentlycontinue | Sort-Object -Property TimeCreated
Write-Host "PDC: $($PDC.HostName)"
Write-Host "Found $($LockedOutEvents.count) Events"

while ($true)
{
    Foreach ($Event in $LockedOutEvents)
    {
        switch ($Event.Id)
        {
            4625
            {
                Write-Host $Event.Id "@" $Event.TimeCreated "From " $Event.Properties[13].Value - $Event.Properties[19].Value 
            }
            4771
            {
                Write-Host $Event.Id "@" $Event.TimeCreated "From " $Event.Properties[6].Value
            }
            4740
            {
                Write-Host $Event.Id "@" $Event.TimeCreated "locked From " $Event.Properties[1].Value
            }
            Default
            {
                Write-Host $Event.Id "@" $Event.TimeCreated  
            }
        }
    }
    Start-Sleep -Seconds 15
    Write-Host -
    if ($host.UI.RawUI.KeyAvailable)
    {
        $key = $host.UI.RawUI.ReadKey() 
        Write-Host $key
        exit 
    }
    $LockedOutEvents = Get-WinEvent -ComputerName $PDC.HostName -FilterHashtable @{LogName = 'Security'; Id = 4625, 4740, 4771; data = $UserName; StartTime = (Get-Date).AddSeconds(-30) } -ErrorAction silentlycontinue | Sort-Object -Property TimeCreated
}
