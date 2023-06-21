<#
.SYNOPSIS
  This Script is used to Create VM Snaps
.DESCRIPTION
  Create VM Snaps
.PARAMETER
  No Parameters
.INPUTS
  No inputs
.OUTPUTS
  Email sent.
.NOTES
  Version:        1.0
  Author:         Dale Hassinger
  Creation Date:  04/20/2023
  PS Modules: PowerCLI
  Purpose/Change: Initial script development
.EXAMPLE
  # ./manual-vm-snap-now.ps1
#>





# ----- [ A Single VM Snap Now ] -----

$vmName          = 'LINUX-U-240'
$snapName        = 'DBH-Before Aria Upgrade'
$snapDescription = 'Upgrade to version 8.12'

Write-Output "Automation Starting..."

$output = "VMName: " + $vmName
Write-Output $output

$output = "Snap Name: " + $snapName
Write-Output $output

$output = "Snap Description: " + $snapDescription
Write-Output $output

# ----------------------------------------------------------- [ Start Execution ] -------------------------------------------------------

$output = 'Starting Process to Schedule SNAP for VM: ' + $vmName + '!'
Write-Output $output

# --- Connect vCenter
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force

Write-Output "Connected to vCenter"

New-Snapshot -VM $vmName -Name $snapName -Description $snapDescription

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false

# --- [ Start Add Alert to Teams Channel ] ---

# --- Create json body for Teams Alert   
$body = @'
{
    "type":"message",
    "attachments":[
        {
          "contentType":"application/vnd.microsoft.card.adaptive",
          "contentUrl":null,
          "content":{
              "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
              "type":"AdaptiveCard",
              "version":"1.5",
              "body": [
                {
                    "type": "TextBlock",
                    "text": "**Automated vCenter VM Snap:**"
                },
                {
                    "type": "TextBlock",
                    "text": "- **VM Name:** strvmName \r- **Created By:** strCreatedBy",
                    "wrap": true                    
                },
                {
                    "type": "TextBlock",
                    "text": " "
                },
                {
                    "type": "TextBlock",
                    "text": "- **Snap Date | Time:** strsnapTime \r- **Snap Name:** strsnapName \r- **Snap Description:** strsnapDescription",
                    "wrap": true
                }
            ]
        }
        }
    ]
  }
'@

$emailAddress = whoami
$emailAddress = $emailAddress.Replace("corp0\","")
$snapTime = (Get-Date).ToString("MM-dd-yyyy hh:mm")
$snapTime

$body = $body.Replace("strvmName",$vm)
$body = $body.Replace("strCreatedBy",$emailAddress)
$body = $body.Replace("strsnapTime",$snapTime)
$body = $body.Replace("strsnapName",$snapName)
$body = $body.Replace("strsnapDescription",$snapDescription)
#$body



# --- Next line is to send to Dale's O365 | Teams | Misc | General for testing
Write-Output "Adding entry to Teams Automation Alert Chat"
Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri "https://thornhilllanecom.webhook.office.com/webhookb2/1e7ce1b3-d36b-4097-b227--bbe7-4050-add6-6f36b7b44adb/IncomingWebhook/e64d1e3f810b459a9ff1daaa0c3ecf09/925be554-9960-4590-9251-65db25f05419"

# --- [ End Add Alert to Teams Channel ] ---

Write-Output "Automation completed."

# ----------------------------------------------------------- [ End Execution ] -------------------------------------------------------








# ----- Create Multiple VM Snaps Now -----

$vmName          = 'LINUX-U-240,LINUX-U-241,LINUX-U-242,LINUX-U-243'
$snapName        = 'DBH-Upgrade Orchestrator'
$snapDescription = 'Upgrade to version 8.12'

Write-Output "Automation Starting..."

$vmname = $vmName -split(",")

$output = 'Number of VMs: ' + $vmName.Count
Write-Output $output

# --- Connect vCenter
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
Write-Output "Connected to vCenter"

foreach($vm in $vmName){
  $output = "VMName: " + $vmName
  Write-Output $output

  $output = "Snap Name: " + $snapName
  Write-Output $output

  $output = "Snap Description: " + $snapDescription
  Write-Output $output

  # ----------------------------------------------------------- [ Start Execution ] -------------------------------------------------------

  $output = 'Starting Process to Create SNAP for VM: ' + $vmName + '!'
  Write-Output $output

  New-Snapshot -VM $vm -Name $snapName -Description $snapDescription
  clear
  # --- [ Start Add Alert to Teams Channel ] ---

  # --- Create json body for Teams Alert   
$body = @'
{
    "type":"message",
    "attachments":[
        {
          "contentType":"application/vnd.microsoft.card.adaptive",
          "contentUrl":null,
          "content":{
              "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
              "type":"AdaptiveCard",
              "version":"1.5",
              "body": [
                {
                    "type": "TextBlock",
                    "text": "**Automated vCenter VM Snap:**"
                },
                {
                    "type": "TextBlock",
                    "text": "- **VM Name:** strvmName \r- **Created By:** strCreatedBy",
                    "wrap": true                    
                },
                {
                    "type": "TextBlock",
                    "text": " "
                },
                {
                    "type": "TextBlock",
                    "text": "- **Snap Date | Time:** strsnapTime \r- **Snap Name:** strsnapName \r- **Snap Description:** strsnapDescription",
                    "wrap": true
                }
            ]
        }
        }
    ]
  }
'@

  $emailAddress = whoami
  $emailAddress = $emailAddress.Replace("corp0\","")
  $snapTime = (Get-Date).ToString("MM-dd-yyyy hh:mm")
  #$snapTime

  $body = $body.Replace("strvmName",$vm)
  $body = $body.Replace("strCreatedBy",$emailAddress)
  $body = $body.Replace("strsnapTime",$snapTime)
  $body = $body.Replace("strsnapName",$snapName)
  $body = $body.Replace("strsnapDescription",$snapDescription)
  #$body

  # --- Next line is to send to Dale's O365 | Teams | Misc | General for testing
  Write-Output "Adding entry to Teams Automation Alert Chat"
  Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri "https://thornhilllanecom.webhook.office.com/webhookb2/1e7ce1b3-4097-5568c1-bbe7-4050-add6-6f36b7b44adb/IncomingWebhook/e64d1e3f810b459a9ff1daaa0c3ecf09/925be554-9960-4590-9251-65db25f05419"

  # --- [ End Add Alert to Teams Channel ] ---

  Write-Output "Automation completed."

} # end foreach

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false

# ----------------------------------------------------------- [ End Execution ] -------------------------------------------------------




# ----- [ Check for Snaps ] -----

# --- [ Connect vCenter ] ---
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
clear
Write-Output "Connected to vCenter"

# --- [ Check for Snaps ] ---
$snapInfo = Get-VM | Get-Snapshot | Select-Object VM, Name, Created | Sort-Object VM

if(!$snapInfo){
  $outPut = 'There is currently no VM SNAPs!'
  Write-Output $outPut
} # End If
else {
  Write-Output $snapInfo | Format-Table -AutoSize
} # End Else

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false













# ----- Multiple VM Snap Cleanup -----
clear
$vmName = 'LINUX-U-240,LINUX-U-241,LINUX-U-242,LINUX-U-243'

Write-Output "Automation Starting..."

$vmname = $vmName -split(",")

$output = 'Number of VMs: ' + $vmName.Count
Write-Output $output

# --- Connect vCenter
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
Write-Output "Connected to vCenter"

foreach($vm in $vmName){
  $output = "VMName: " + $vmName
  Write-Output $output

  $output = "Snap Name: " + $snapName
  Write-Output $output

  $output = "Snap Description: " + $snapDescription
  Write-Output $output

  # ----------------------------------------------------------- [ Start Execution ] -------------------------------------------------------

  $output = 'Starting Process to Delete SNAP for VM: ' + $vmName + '!'
  Write-Output $output

  # Delete VM Snap
  $snapDetails = Get-VM -Name $vm | Get-Snapshot
  #$snapDetails.Name

  Get-VM -Name $vm | Get-Snapshot | Remove-Snapshot -Confirm:$false
  clear
  # --- [ Start Add Alert to Teams Channel ] ---

  # --- Create json body for Teams Alert   
$body = @'
{
    "type":"message",
    "attachments":[
        {
          "contentType":"application/vnd.microsoft.card.adaptive",
          "contentUrl":null,
          "content":{
              "$schema":"http://adaptivecards.io/schemas/adaptive-card.json",
              "type":"AdaptiveCard",
              "version":"1.5",
              "body": [
                {
                    "type": "TextBlock",
                    "text": "**Automated vCenter VM Snap Delete:**"
                },
                {
                    "type": "TextBlock",
                    "text": "- **VM Name:** strvmName \r- **Created By:** strCreatedBy",
                    "wrap": true                    
                },
                {
                    "type": "TextBlock",
                    "text": " "
                },
                {
                    "type": "TextBlock",
                    "text": "- **Snap Name:** strsnapName",
                    "wrap": true
                }
            ]
        }
        }
    ]
  }
'@
  
  $emailAddress = whoami
  $emailAddress = $emailAddress.Replace("corp0\","")
  $snapTime = (Get-Date).ToString("MM-dd-yyyy hh:mm")
  #$snapTime

  $body = $body.Replace("strvmName",$vm)
  $body = $body.Replace("strCreatedBy",$emailAddress)
  $body = $body.Replace("strsnapName",$snapDetails.Name)
  #$body

  # --- Next line is to send to Dale's O365 | Teams | Misc | General for testing
  Write-Output "Adding entry to Teams Automation Alert Chat"
  Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri "https://thornhilllanecom.webhook.office.com/webhookb2/1e7ce1b3-d36b-4097-b227-bbe7-4050-add6-6f36b7b44adb/IncomingWebhook/e64d1e3f810b459a9ff1daaa0c3ecf09/925be554-9960-4590-9251-65db25f05419"

  # --- [ End Add Alert to Teams Channel ] ---

  Write-Output "Automation completed."

} # end foreach

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false

# ----------------------------------------------------------- [ End Execution ] -------------------------------------------------------



















# ----- [ Check DRS Status ] -----

$clusterName = 'Cluster-01'

# --- [ Connect vCenter ] ---
Write-Output "Connecting to vCenter..."
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
clear

# --- [ Check DRS ] ---
$drsStatus = Get-Cluster -Name $clusterName | Select-Object *
#$drsStatus.DrsEnabled

$outPut = $clusterName + ' | DRS is enabled: ' + $drsStatus.DrsEnabled 
Write-Output $outPut

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false










# ----- [ Check Host Maintenance Mode ] -----

# --- [ Connect vCenter ] ---
Write-Output "Connecting to vCenter..."
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
clear

$hostNames = Get-VMHost | Sort-Object Name
#$hostNames.Name
#$hostNames.ConnectionState

# --- [ Check Maintenance Mode Status ] ---
foreach($hostName in $hostNames.Name){
  $hostStatus = Get-VMHost -Name $hostName
  $output = $hostName + ' | Maintenance Mode Status: ' + $hostStatus.ConnectionState
  Write-Output $output
} # End Foreach

# --- [ Disconnect from all vCenters ] ---
Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false










# ----- [ Check DataStores ] -----

# --- [ Connect vCenter ] ---
Write-Output "Connecting to vCenter..."
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
clear

Get-Datastore | Select-Object @{n="Datastore | Name";e={($_.Name)}},@{n="Capacity | GB";e={[system.math]::Round($_.CapacityGB,0)}},@{n="FreeSpace | GB";e={[system.math]::Round($_.FreeSpaceGB,0)}} | Sort-Object 'Datastore | Name' | Format-Table -AutoSize

# --- [ Disconnect from all vCenters ] ---
#Write-Output "Disconnecting from vCenter..."
Disconnect-VIServer * -Force -Confirm:$false










# ----- [ Check Scheduled Tasks that have completed ] -----
#$deleteTask = 'True'
$deleteTask = 'False'

$connectvCenter = Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force

# --- Starting Scheduled Tasks ---
clear
$output = "Starting Process to Cleanup Scheduled Tasks."
Write-Output $output

if($connectvCenter.IsConnected -eq 'True'){
  # --- Get List of All Scheduled Tasks that have run and can be deleted
  $TaskList = (Get-View ScheduledTaskManager).ScheduledTask | ForEach-Object{(Get-View $_).Info} | Where-Object {$_.Description -Like "vRA*" -and $_.NextRunTime -eq $null}
  #$TaskList
  #$TaskList.Count

  if($TaskList.Count -gt 0){
    $output = 'There are ' + $TaskList.Count + ' Scheduled tasks to delete that have already run.'
    Write-Output $output

    foreach($scheduledTask in $TaskList){
      #$scheduledTask

      $VMName = (Get-VM | Where-Object {$_.ID -eq $scheduledTask.Entity}).Name
      #$vmName

      if($deleteTask -eq 'True'){
        $output = 'Deleting Scheduled task: ' + $VMName + ' | ' + $scheduledTask.Name + ' | ' + $scheduledTask.Description
        Write-Output $output

        #Write-Host $TASk.ScheduledTask
        $si = Get-View ServiceInstance
        $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager
        $t = Get-View -Id $scheduledTaskManager.ScheduledTask | Where-Object {$_.MoRef -eq $scheduledTask.ScheduledTask}
        #$t

        # --- The next line removes the scheduled task from vCenter. Comment out Next line for TEST.
        $t.RemoveScheduledTask()

      } # End If
      else{
        $output = 'Scheduled task: ' + $VMName + ' | ' + $scheduledTask.Name + ' | ' + $scheduledTask.Description
        Write-Output $output
      } # End Else

    } # End foreach

  } # End if
  else{
    $output = 'No Scheduled Task(s) to Delete.'
    Write-Output $output

  } # End Else

} # End If

Write-Output 'Disconnecting from all vCenters...'
Disconnect-VIServer * -Force -Confirm:$false

if($deleteTask -eq 'True'){
  $output = "Process to Cleanup Scheduled Tasks complete."
  Write-Output $output
} # End If
else{
  $output = "Scheduled Tasks List has been completed."
  Write-Output $output
} # End Else









