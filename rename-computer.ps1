$clientName = "Client"
function sanitizeName($computerName){
    $clearSpaces = $computerName.trim()
    if($clearSpaces.length -gt 15){
        $fifteen = $clearSpaces.Substring(0,[Math]::Min(15,$clearSpaces.length))
        return $fifteen
    }
    else {
        return $clearSpaces
    }
}
if($chassisType -ne 9 -or $chassisType -ne 10 -or $chassisType -ne 14){
    Write-Host -ForegroundColor yellow "Turning Off Hibernation and Disk Timeout and Sleepmode."
    powercfg.exe -x -monitor-timeout-ac 15
    powercfg.exe -x -monitor-timeout-dc 15
    powercfg.exe -x -disk-timeout-ac 0
    powercfg.exe -x -disk-timeout-dc 15
    powercfg.exe -x -standby-timeout-ac 0
    powercfg.exe -x -standby-timeout-dc 15
    powercfg.exe -h off
    $newName = $clientName + "-PC-" + $serialNumber
    $sanitizedName = sanitizeName $newName
    Write-Host -ForegroundColor green "Changing name of computer to: $sanitizedName"
    Rename-Computer -NewName $sanitizedName
}
if($chassisType -eq 9 -or $chassisType -eq 10 -or $chassisType -eq 14){
    Write-Host -ForegroundColor yellow "Turning Off Hibernation and Leaving Sleep mode Turned on."
    powercfg.exe -x -monitor-timeout-ac 45
    powercfg.exe -x -monitor-timeout-dc 15
    powercfg.exe -x -disk-timeout-ac 0
    powercfg.exe -x -disk-timeout-dc 15
    powercfg.exe -x -standby-timeout-ac 45
    powercfg.exe -x -standby-timeout-dc 15
    powercfg.exe -h off
    $newName = $clientName + "-LT-" + $serialNumber
    $sanitizedName = sanitizeName $newName
    Write-Host -ForegroundColor green "Changing name of computer to: $sanitizedName"
    Rename-Computer -NewName $sanitizedName
}