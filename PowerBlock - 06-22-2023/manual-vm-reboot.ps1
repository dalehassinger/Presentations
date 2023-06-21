<#
.SYNOPSIS
  This Script is used to Schedule VM Reboot
.DESCRIPTION
  Schedule VM Reboot
.PARAMETER
  No Parameters
.INPUTS
  No inputs
.OUTPUTS
  Email sent.
.NOTES
  Version:        1.0
  Author:         Dale Hassinger
  Creation Date:  05/23/2023
  PS Modules: PowerCLI
  Purpose/Change: Initial script development
.EXAMPLE
  #.\manual-vm-reboot.ps1
#>


$rebootTime        = ([datetime]('2023-07-04T19:00')).AddHours(4)
$vmName            = 'LINUX-U-240'
$rebootName        = 'DBH-Before Upgrade'
$rebootDescription = 'Testing Automated reboot'
$emailAddress      = 'hdale@vmware.com'


#change Date/Time to match how vCenter is exspecting format.

Write-Output "Automation Starting."

$output = "VMName: " + $vmName
Write-Output $output

$output = "reboot Date|Time: " + $rebootTime
Write-Output $output

$output = "reboot Name: " + $rebootName
Write-Output $output

$output = "reboot Description: " + $rebootDescription
Write-Output $output

$output = "Email Address: " + $emailAddress
Write-Output $output

# ----------------------------------------------------------- [ Start Execution ] -------------------------------------------------------

$output = 'Starting Process to Schedule reboot for VM: ' + $vmName + '!'
Write-Output $output

# --- Connect vCenter
Connect-VIServer -Server '192.168.0.100' -User 'administrator@corp.local' -Password 'VMware1!' -Protocol https -Force
Write-Output "Connected to vCenter"

# --- Get VM Information
$VMInfo = Get-VM -Name $vmName
$output = 'VM Count: ' + $VMInfo.Count
Write-Output $output

if($VMInfo.Count -eq 1){

    # --- Verify Date/Time.
    $currentDatetime = Get-Date
    If ($rebootTime -le $currentDatetime ) {
        $rebootTime = $currentDatetime.AddMinutes(1)
    } # End If

    $vm                   = Get-VM -Name $vmName -Server $VMvCenter
    #$vm.ExtensionData.MoRef.Value
    $si                   = Get-View ServiceInstance -Server $VMvCenter
    #$si
    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager -Server $VMvCenter
    #$scheduledTaskManager
    $spec                 = New-Object VMware.Vim.ScheduledTaskSpec
    $spec.Scheduler       = New-Object VMware.Vim.OnceTaskScheduler
    $spec.Scheduler.runat = $rebootTime
    $spec.Notification    = $emailAddress
    $spec.Name            = "vRA reboot | " + $vm.Name + " | " + $rebootTime.AddHours(-4)
    $spec.Action          = New-Object VMware.Vim.MethodAction

    $spec.Action.Name              = "RebootGuest"
    $spec.Description              = "vRA reboot | " + $rebootDescription
    $spec.Enabled                  = $true
    $scheduledTaskManager          = Get-View -Id 'ScheduledTaskManager-ScheduledTaskManager'

    Write-Output "Creating Scheduled Task in vCenter..."
    $scheduledTaskManager.CreateObjectScheduledTask($vm.ExtensionData.MoRef, $spec) # Creates the scheduled task
} # End If
else{
    # VM Not Found
} # End else



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
                    "text": "**Automated vCenter VM Reboot:**"
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
                    "text": "- **reboot Date | Time:** strrebootTime \r- **reboot Name:** strrebootName \r- **reboot Description:** strrebootDescription",
                    "wrap": true
                }
            ]
        }
        }
    ]
  }
'@
  
#$body = $body.Replace("strvCenterName",$VMvCenter)
$body = $body.Replace("strvmName",$vmName)
$body = $body.Replace("strCreatedBy",$emailAddress)
$body = $body.Replace("strrebootTime",$rebootTime.AddHours(-4))
$body = $body.Replace("strrebootName",$rebootName)
$body = $body.Replace("strrebootDescription",$rebootDescription)
#$body


# --- Next line is to send to Dale's O365 | Teams | Misc | General for testing
Write-Output "Adding entry to Teams Automation Alert Chat"
$results = Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri "https://thornhilllanecom.webhook.office.com/webhookb2/1e7ce1b3-d36b-4097-568c1-bbe7-4050-add6-6f36b7b44adb/IncomingWebhook/e64d1e3f810b459a9ff1daaa0c3ecf09/925be554-9960-4590-9251-65db25f05419"

# --- [ End Add Alert to Teams Channel ] ---

Write-Output "Automation completed."

# ----------------------------------------------------------- [ End Execution ] -------------------------------------------------------

