$OctopusURL = "http://localhost/"
$OctopusAPIKey = "#{OD_Api_Key}" 
$MachineName = "#{Octopus.machine.name}" #Machine Display Name \
$SpaceId = "#{Octopus.Space.Id}"

$header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

$allVms = Invoke-RestMethod $OctopusURL/api/$SpaceID/machines/all -Method Get -Headers $header
$machineid = ($allVms | Where-Object name -eq "$MachineName").id
if(!$machineid){
   throw "Machine ID can't be located."
}


$body = @{ 
    Name = "Health" 
    Description = "Checking health of $MachineName" 
    Arguments = @{ 
        Timeout= "00:05:00" 
        MachineIds = @($machineId) #$MachinID could contain an array of machines too
        SpaceId = $SpaceId
    } 
} | ConvertTo-Json

$time = 0

while($($HC.state -ne "Success" -and $time -le 5)){
    if($null -eq $HC.state -or $HC.state -eq "Failed"){
        if($null -eq $HC.state){
            write-host "Initialising check."
        }else{
            write-host "Since State is failed, trying again."
        }
        $initHealthCheck = Invoke-RestMethod $OctopusURL/api/$SpaceId/tasks -Method Post -Body $body -Headers $header
        $time += 1
        write-host "INFO: Number of runs so far: $time, State: $($initHealthCheck.State) , TaskId $($initHealthCheck.id), Description: $($initHealthCheck.Description) "     
    }
    $HC = Invoke-RestMethod $OctopusURL/api/$SpaceId/tasks/$($initHealthCheck.Id) -Method get -Headers $header
    Write-Host "State: $($HC.state), Description: $($initHealthCheck.Description), Space: $($HC.SpaceId), Times: $time"
}

if($HC.state -eq "Success"){
    write-host "SUCCESS: $($initHealthCheck.Description)"
}else{
     Write-Error "FAILED: $($initHealthCheck.Description)"
}