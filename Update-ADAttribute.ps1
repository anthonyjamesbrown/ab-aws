New-EventLog -LogName Application -Source "InstanceIDADUpdate";

$wc = New-Object System.Net.WebClient;
$instanceID = $wc.DownloadString("http://169.254.169.254/latest/meta-data/instance-id");
$InstanceName = Get-CimInstance Win32_OperatingSystem | Select-Object csname -ExpandProperty csname;

$Message = "Instance Name: $InstanceName, InstanceID: $instanceID";
Write-EventLog -LogName "Application" -Source "InstanceIDADUpdate" -EventID 3001 -EntryType Information -Message $Message;

If((Get-WMIObject -class win32_ComputerSystem).PartOfDomain -eq $true)
{
    $Message = "$InstanceID was joined to the HQDomain.  Attempting to update AD computer object.";
    Write-EventLog -LogName "Application" -Source "InstanceIDADUpdate" -EventID 3001 -EntryType Information -Message $Message;

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement;
    $CT = [System.DirectoryServices.AccountManagement.ContextType]::Domain;
    $Computer = [System.DirectoryServices.AccountManagement.ComputerPrincipal]::FindByIdentity($CT, $InstanceName);
    $CompDirectoryEntry = $Computer.GetUnderlyingObject();
    $CompDirectoryEntry.serialNumber = $InstanceID;
    $CompDirectoryEntry.importedFrom = 'AWS';
    try {
        $CompDirectoryEntry.CommitChanges();
        $CompDirectoryEntry.Close();

        $Message = "AD computer object for $InstanceName has been updated.";
        Write-EventLog -LogName "Application" -Source "InstanceIDADUpdate" -EventID 3001 -EntryType Information -Message $Message;
        Remove-EC2Tag -Resource $instanceID -Tag @{ Key="TagADInstanceID" } -Force -Verbose;
    }
    catch {
        $CompDirectoryEntry.Close();

        $Message = "AD computer object for $InstanceName was not updated. Reason: $($_.Exception.ItemName) : $($_.Exception.Message)";
        Write-EventLog -LogName "Application" -Source "InstanceIDADUpdate" -EventID 4001 -EntryType Error -Message $Message;
    }
}
