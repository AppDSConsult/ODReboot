# ODReboot

$OctopusURL = "http://localhost/"
$OctopusAPIKey = "#{OD_Api_Key}" 
$MachineName = "#{Octopus.machine.name}" #Machine Display Name \
$SpaceId = "#{Octopus.Space.Id}"

Set these variables up in your OD project for the script to work.

This script should also be set-up as a separate step and should be executed on the Octopus (or worker) server, not the target tentacle.