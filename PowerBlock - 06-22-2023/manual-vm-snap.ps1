<#
.SYNOPSIS
  This Script is used to Schedule VM Snaps
.DESCRIPTION
  Schedule VM Snaps
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
  #.\manual-vm-snap.ps1
#>

$snapTime        = ([datetime]('2023-07-04T20:00')).AddHours(4)
$vmName          = 'LINUX-U-240'
$snapName        = 'DBH-Before Upgrade'
$snapDescription = 'Upgrade to version 8.12'
$emailAddress    = 'hdale@vmware.com'
$snapMemory      = 'False'


Write-Output "Automation Starting."

$output = "VMName: " + $vmName
Write-Output $output

$output = "Snap Date|Time: " + $snapTime
Write-Output $output

$output = "Snap Name: " + $snapName
Write-Output $output

$output = "Snap Description: " + $snapDescription
Write-Output $output

$output = "Email Address: " + $emailAddress
Write-Output $output

$output = "Snap Memory: " + $snapMemory
Write-Output $output

# ----------------------------------------------------------- [ Start Execution ] -------------------------------------------------------

$output = 'Starting Process to Schedule SNAP for VM: ' + $vmName + '!'
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
    If ($snapTime -le $currentDatetime ) {
        $snapTime = $currentDatetime.AddMinutes(1)
    } # End If

    $vm                   = Get-VM -Name $vmName -Server $VMvCenter
    #$vm.ExtensionData.MoRef.Value
    $si                   = Get-View ServiceInstance -Server $VMvCenter
    #$si
    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager -Server $VMvCenter
    #$scheduledTaskManager
    $spec                 = New-Object VMware.Vim.ScheduledTaskSpec
    $spec.Scheduler       = New-Object VMware.Vim.OnceTaskScheduler
    $spec.Scheduler.runat = $snapTime
    $spec.Notification    = $emailAddress
    $spec.Name            = "vRA Snapshot | " + $vm.Name + " | " + $snapTime.AddHours(-4)
    #$spec.Name            = "vRA Snapshot | " + $vm.Name + " | " + $snapTime
    $spec.Action          = New-Object VMware.Vim.MethodAction

    $Description          = "vRA Snapshot " + $snapDescription

    $spec.Action.Argument          = New-Object VMware.Vim.MethodActionArgument[] (4)
    $spec.Action.Argument[0]       = New-Object VMware.Vim.MethodActionArgument
    $spec.Action.Argument[0].Value = $snapName #'SNAP Name' 
    $spec.Action.Argument[1]       = New-Object VMware.Vim.MethodActionArgument
    $spec.Action.Argument[1].Value = $Description # 'Snap Description'
    $spec.Action.Argument[2]       = New-Object VMware.Vim.MethodActionArgument

    if($snapMemory -eq 'True'){
        $spec.Action.Argument[2].Value = $true # Snap Memory
    } # End If
    Else{
        $spec.Action.Argument[2].Value = $false # Snap Memory
    } # End Else
        
    $spec.Action.Argument[3]       = New-Object VMware.Vim.MethodActionArgument
    $spec.Action.Argument[3].Value = $false # Pause Guest System. This is always $false.
    $spec.Action.Name              = "CreateSnapshot_Task"
    $spec.Description              = "vRA Snapshot | " + $snapDescription
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
  
#$body = $body.Replace("strvCenterName",$VMvCenter)
$body = $body.Replace("strvmName",$vmName)
$body = $body.Replace("strCreatedBy",$emailAddress)
$body = $body.Replace("strsnapTime",$snapTime.AddHours(-4))
#$body = $body.Replace("strsnapTime",$snapTime)
$body = $body.Replace("strsnapName",$snapName)
$body = $body.Replace("strsnapDescription",$snapDescription)
#$body


# --- Next line is to send to Dale's O365 | Teams | Misc | General for testing
Write-Output "Adding entry to Teams Automation Alert Chat"
$results = Invoke-RestMethod -Method post -ContentType 'Application/Json' -Body $body -Uri "https://thornhilllanecom.webhook.office.com/webhookb2/1e7ce1b3-d36b-4097-5568c1-bbe7-4050-add6-6f36b7b44adb/IncomingWebhook/e64d1e3f810b459a9ff1daaa0c3ecf09/925be554-9960-4590-9251-65db25f05419"

# --- [ End Add Alert to Teams Channel ] ---

Write-Output "Automation completed."

# ----------------------------------------------------------- [ End Execution ] -------------------------------------------------------

