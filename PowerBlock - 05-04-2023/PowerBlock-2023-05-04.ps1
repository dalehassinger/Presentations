# This code is for demo purposes only.
# ALWAYS Test in a DEV environement before using in a PROD environment.
# Please take the time to understand the code before running the code.




# ----- [ Connect to vCenter ] -----
Connect-VIServer -Server 'vcsa-8x.corp.local' -User 'administrator@corp.local' -Password 'VMware1!' -Force

# ----- [ SNAPS ] -----

# Get every SNAP for every VM
$allSnaps = Get-Snapshot -VM *

# Get VM,Created,Description info about SNAP
$allSnapsInfo = $allSnaps | Select-Object VM,Created,Description

# Show all Snaps
Write-Output $allSnapsInfo

# Export SNAP info as an csv file to view in excel.
$allSnapsInfo | Export-Csv -Path C:\vCenterInfo\snaps.csv -NoTypeInformation

# ----- [ Disconnect from vCenter ] -----
Disconnect-VIServer -Server * -Confirm:$false



# ----- [ Connect to vCenter ] -----
Connect-VIServer -Server 'vcsa-8x.corp.local' -User 'administrator@corp.local' -Password 'VMware1!' -Force


# ----- [ Network Adapters ] -----

# Get all nics for evry VM
$allNics     = Get-NetworkAdapter -VM *
$allNicsInfo = $allNics | Select-Object Parent,Type,Name
$allNicsInfo | Export-Csv -Path C:\vCenterInfo\nics.csv -NoTypeInformation

# Get all nics for evry VM but only show NICs that are not Vmxnet3
$allNics     = Get-NetworkAdapter -VM *
$allNicsInfo = $allNics | Select-Object Parent,Type,Name | Where-Object {$_.Type -ne "Vmxnet3"}
$allNicsInfo | Export-Csv -Path C:\vCenterInfo\nics-not-vmxnet3.csv -NoTypeInformation

# ----- [ Disconnect from vCenter ] -----
Disconnect-VIServer -Server * -Confirm:$false





# ----- [ VMware Tools ] -----

# ----- [ Connect to vCenter ] -----
Connect-VIServer -Server 'vcsa-8x.corp.local' -User 'administrator@corp.local' -Password 'VMware1!' -Force

# Get Tools info  for evry VM
$allVMs = Get-VM

$vmToolsInfo = @'
'@

$header       = '"VM","ToolsVersion","ToolsStatus","ToolsRunningStatus"'
$vmToolsInfo += "$header" + "`n"

foreach($vmName in $allVMs.name){
    $toolsInfo    = Get-VM $vmName | Get-VMGuest
    $output       = '"' + $toolsInfo.VmName + '","' + $toolsInfo.ToolsVersion + '","' + $toolsInfo.ExtensionData.ToolsStatus + '","' + $toolsInfo.ExtensionData.ToolsRunningStatus + '"'
    $vmToolsInfo += "$output" + "`n"
    #Write-Output $output
} # End Foreach

Write-Output $vmToolsInfo

# Delete existing csv file and create new csv file
Remove-Item C:\vCenterInfo\vmware-tools.csv -Confirm:$false
Add-Content C:\vCenterInfo\vmware-tools.csv $vmToolsInfo

# ----- [ Disconnect from vCenter ] -----
Disconnect-VIServer -Server * -Confirm:$false










# ----- [ vCenter TAGs ] -----

# ----- [ Connect to vCenter ] -----
Connect-VIServer -Server 'vcsa-8x.corp.local' -User 'administrator@corp.local' -Password 'VMware1!' -Force

# Get VM info based on vCenter TAG
$tagName = "TAG-Web-Server"
$allVMs = Get-VM -Tag $tagName | Select-Object Name,NumCpu,MemoryGB

# Create csv file with VM info
$allVMs | Export-Csv -Path C:\vCenterInfo\$tagName.csv -NoTypeInformation

# ----- [ Disconnect from vCenter ] -----
Disconnect-VIServer -Server * -Confirm:$false




















# ----- [ Disconnect CD drive ] -----

# ----- [ Connect to vCenter ] -----
Connect-VIServer -Server 'vcsa-8x.corp.local' -User 'administrator@corp.local' -Password 'VMware1!' -Force

# Code Disconnect CD from all VMs
Get-VM | Where-Object {$_.PowerState –eq “PoweredOn”} | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$False

# ----- [ Disconnect from vCenter ] -----
Disconnect-VIServer -Server * -Confirm:$false










# Code Disconnect CD from all VMs
Get-VM | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$False

Get-VM -Name Linux* | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$False






# ----- [ SCSI Controller Type ] -----

# ----- [ Connect to vCenter ] -----
Connect-VIServer -Server 'vcsa-8x.corp.local' -User 'administrator@corp.local' -Password 'VMware1!' -Force

# Code SCSI Controller Type from all VMs
$allSCSIControllers = get-vm -name * | Get-ScsiController | Select-Object Parent,Type | Sort-Object Parent
$allSCSIControllers | Export-Csv -Path C:\vCenterInfo\SCSI-Controllers.csv -NoTypeInformation

# ----- [ Disconnect from vCenter ] -----
Disconnect-VIServer -Server * -Confirm:$false



