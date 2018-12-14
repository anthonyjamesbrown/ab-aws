
Import-Module -Name AWSPowerShell -WarningAction SilentlyContinue

$Name = "AB-UpdateAD-Object-Test8"  # Instance Name Tag
$KeyName = 'AB-Keypair' # The keypair to use for access


$ImageID = (Get-EC2ImageByName -Name "WINDOWS_2016_BASE").ImageId
$SecurityGroupID = (Get-EC2SecurityGroup | Where-Object GroupName -eq 'Windows Standard Operations').GroupID

$SubNetList = Get-ABAWSec2Subnet | Where-Object VPCName -ne 'DO_NOT_USE' | Select-Object Name,CidrBlock,VPCName,SubnetId

$count = 0
foreach($Subnet in $SubNetList)
{
    Write-Host "[ $count ]" $Subnet.Name $Subnet.CIDRBlock $Subnet.VPCName
    $count++ 
}

if($count -gt 1)
{
    Write-Host 'Which subnet do you want to use? ' -NoNewLine -ForegroundColor Yellow 
    $index = Read-Host 
}

$SubNetID = $SubNetList[$index].SubnetID

$Script = Get-Content -Raw C:\Support\script.txt.txt # This is an example of pointing to a user script file to execute during the build.
$UserData = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Script))

# Because I want the ec2config service to join the domain for me, I have to put the instance in the 'Join-Domain' IAM role that is referenced as InstanceProfile_Name
$Props = @{
    'ImageID'               = "$ImageID";
    'SubnetID'              = "$SubNetID";
    'InstanceType'          = "t2.micro";
    'KeyName'               = "$KeyName";
    'SecurityGroupID'       = "$SecurityGroupID";
    'UserData'              = $UserData;
    'InstanceProfile_Name'  = "Join-Domain";       
}

# Start the build and get the InstanceID back
$NewInstanceResponse = New-EC2Instance @Props
$InstanceID = ($NewInstanceResponse.Instances).InstanceID

# Wait until the Instance registers as existing
Do
{
    Start-Sleep -Seconds 1
}
Until (((Get-EC2Instance).RunningInstance).instanceid -ccontains $InstanceID)

# Create an hash tabel of key pairs to populate the instance Tags, the ones below are an example
#  then set the Tags on the new instance
$Tags = @(  
            @{key="Name";value="$Name"},
            @{key="BUSINESS_UNIT";value="OPERATIONS"},
            @{key="BUSINESS_REGION";value="NORTHAMERICA"},
            @{key="PLATFORM";value="COMMONSERVICES"},
            @{key="CLIENT";value="NONE"},
            @{key="SCHEDULER:SLEEP";value="FOLLOWTHESUN"}
            #,@{key="TagADInstanceID";value="YES"}
         )
New-EC2Tag -ResourceID $InstanceID -Tags $Tags

# I have found that pausing for 20 seconds at this point is good for working in the us-east-1 region
Start-Sleep -seconds 20

# The next command assumes that a SSM document called 'AB-JoinDomain' exists.  It does in most of the main AWS environments we use.  Especially where AD Connectors have been configured
#  This command will associate the AB-JoinDomain SSM document with the new instance.  The ec2config service will process this document and join the system to the AD domain.
New-SSMAssociation -InstanceId $InstanceID -Name "AB-JoinDomain" 

#Start-Sleep 300 # Building a new instance can take up to 5 or more minutes before the admin password can be retrived.

# The next section will output the admin password, instance id, and private IP address
Get-EC2PasswordData -InstanceId $InstanceID -PemFile C:\Support\AB-Keypair.pem
$InstanceID
$NewInstanceResponse.Instances.PrivateIpAddress
