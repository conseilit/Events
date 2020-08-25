# Revert Snapshot
$VMNames="AD",”SRV1”,”SRV2”
$VMNames | GET-VM | Stop-VM -Force
$VMNames | GET-VM | Get-VMHardDiskDrive | where path -Like "*data*"| Remove-Item  
$VMNames | GET-VM | GET-VMSnapshot | RESTORE-VMSnapshot –confirm:$False


# Start VMs
$VMNames=”AD"
$VMNames | GET-VM | Start-VM

# Start VMs
$VMNames=”SRV1”,”SRV2”
$VMNames | GET-VM | Start-VM


# Checkpoint VMs
$VMNames=”AD”,”SRV1”,”SRV2”
$VMNames | GET-VM | CHECKPOINT-VM –SnapshotName ‘Base’

# Stop VMs
$VMNames=”SRV1”,”SRV2”,”AD”
$VMNames | GET-VM | Stop-VM -Force

