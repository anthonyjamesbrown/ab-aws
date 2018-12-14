function Get-ABAWSNameTag
{
    <#
        .SYNOPSIS
            Returns the Name tag value for a given AWS resource-id
        .DESCRIPTION
            This script will get the Name tag value for a given AWS resource-id

            This script assumes that you have already authenticated with AWS using
            Set-AWSCredential or Set-AWSRole (discussed below)
        .EXAMPLE
            This example gets the VPC Name tag value for the VPC object with a 
            vpcid of vpc-06233a13830bc67a2

            PS> Get-ABAWSNameTag -ResourceID vpc-06233a13830bc67a2
            myAWSVPC
        
        .PARAMETER ResourceID
            This is the name of the resource id to return the Name tag value for.          
        .NOTES
            Author: Anthony Brown
            https://github.com/anthonyjamesbrown 
    #>    
    [CmdletBinding()]
    param 
    (
        [Parameter(
            Mandatory=$true
        )]
        [string]
        $ResourceID
    ) # end param
    (Get-EC2Tag -filter @{Name="resource-id";Values=$ResourceID},@{Name="key";Values="Name"}).Value 
} # end function Get-ABAWSNameTag

function Get-ABAWSEC2vpc
{
    <#
        .SYNOPSIS
            Returns brief information about the configured VPCs for a connected aws account.
        .DESCRIPTION
            This script is a wrapper for Get-EC2VPC that includes the Name tag value.

            This script assumes that you have already authenticated with AWS using
            Set-AWSCredential or Set-AWSRole (discussed below)            
        .EXAMPLE
            PS> Get-ABAWSEC2Vpc

            Name            :
            CidrBlock       : 172.31.0.0/16
            VpcId           : vpc-3294a149
            DhcpOptionsId   : dopt-f0ad678b
            InstanceTenancy : default
            State           : available

            Name            : myAWSVPC
            CidrBlock       : 10.0.0.0/16
            VpcId           : vpc-06233a13830bc67a3
            DhcpOptionsId   : dopt-f0ad678b
            InstanceTenancy : default
            State           : available            

            ...           
        .NOTES
            Author: Anthony Brown
            https://github.com/anthonyjamesbrown 
    #>
    [CmdletBinding()]
    param()

    Get-EC2Vpc | Select-Object @{n="Name";e={Get-ABAWSNameTag -ResourceID $_.VpcId}},cidrblock,VpcID,DhcpOptionsID,InstanceTenancy,State
} # end function Get-ABAWSEC2vpc

function Get-ABAWSEC2Subnet
{
    <#
        .SYNOPSIS
            Returns brief information about the configured subnets for a connected aws account.
        .DESCRIPTION
            This script is a wrapper for Get-EC2Subnet that includes the Name tag value.

            This script assumes that you have already authenticated with AWS using
            Set-AWSCredential or Set-AWSRole (discussed below)            
        .EXAMPLE
            PS> Get-ABAWSec2Subnet

            Name                        :
            SubnetState                 : available
            AssignIpv6AddressOnCreation : False
            AvailabilityZone            : us-east-1f
            AvailableIpAddressCount     : 4091
            CidrBlock                   : 172.31.48.0/20
            DefaultForAz                : True
            Ipv6CidrBlockAssociationSet : {}
            MapPublicIpOnLaunch         : True
            State                       : available
            SubnetId                    : subnet-7fd65d70
            VpcId                       : vpc-3294a149
            VpcName                     :

            Name                        : 10.0.2.0 - us-east-1b - Private
            SubnetState                 : available
            AssignIpv6AddressOnCreation : False
            AvailabilityZone            : us-east-1b
            AvailableIpAddressCount     : 251
            CidrBlock                   : 10.0.2.0/24
            DefaultForAz                : False
            Ipv6CidrBlockAssociationSet : {}
            MapPublicIpOnLaunch         : False
            State                       : available
            SubnetId                    : subnet-05f714113d243cc8b
            VpcId                       : vpc-06233a13830bc67a3
            VpcName                     : myAWSVPC
            ...           
        .NOTES
            Author: Anthony Brown
            https://github.com/anthonyjamesbrown 
    #>
    [CmdletBinding()]
    param()

    Get-EC2Subnet  | Select-Object @{n="Name";e={Get-ABAWSNameTag -ResourceID $_.SubnetID}},*,@{n="VpcName";e={Get-ABAWSNameTag -ResourceID $_.VpcID}} -ExcludeProperty Tag, tags
} # end function Get-ABAWSEC2Subnet

function Get-ABAWSInstance
{
    <#
        .SYNOPSIS
            Returns a list of running AWS instances.
        .DESCRIPTION
            This script will return a list of running AWS instances including the Name tag information.

            This script assumes that you have already authenticated with AWS using
            Set-AWSCredential or Set-AWSRole (discussed below)            
        .EXAMPLE
            PS> Get-ABAWSInstance

            ...
        .PARAMETER PropertySet
            This parameter takes either a value of long or short.  This value is used to determine if the list of returned
            parameters should be prefiltered.          
        .NOTES
            Author: Anthony Brown
            https://github.com/anthonyjamesbrown 
    #>    
    [CmdletBinding()]
    param 
    (
        [Parameter(
            Mandatory=$true)
        ]
        [ValidateSet("long","short")]
        [string]
        $PropertrySet
    ) # end params

    $Data = Get-EC2Instance | ForEach-Object { $_.RunningInstance } | Select-Object @{n="Name";e={Get-ABAWSNameTag -ResourceID $_.InstanceID}},@{n="Status";e={((Get-EC2InstanceStatus -InstanceId $_.InstanceID).InstanceState).Name}},*,@{n="ImageName";e={(Get-EC2Image -ImageID $_.ImageID).Name}},@{n="SubnetName";e={Get-ABAWSNameTag -ResouceID $_.SubnetID}},@{n="VpcName";e={Get-ABAWSNameTag -ResouceID $_.VpcID}}
    
    if($PropertrySet -eq "long")
    {
        $Data
    }
    else
    {
        $Data | Select-Object Name,InstanceID,Status,Platform,InstanceType,KeyName,LaunchTime,PrivateIPAddress,SubnetName,VPCName,ImageName
    } # end if
} # end function Get-ABAWSInstance

function New-ABAWSEC2SecurityGroup 
{
    <#
        .SYNOPSIS
            Create a new EC2 Security Group with a preset list of rules.
        .DESCRIPTION
            This script will create a new EC2 Security Group with a preset list of inbound rules.
            The rules here are used as an example and would probably be overly permissive for use
            on non lab instances.

            This script assumes that you have already authenticated with AWS using
            Set-AWSCredential or Set-AWSRole (discussed below)            
        .EXAMPLE
            
            $props = @{
                'GroupName' = 'AD Member Server SG'
                'Description' = 'Common com ports for Windows servers.'
                'VpcID' = 'vpc-06233a13830bc67a3'
            }
            New-EC2SecurityGroup @props

            sg-0737830ddb3ced801
            ...
        .PARAMETER GroupName
            This is the name of the new Security Group.
        .PARAMETER Description
            This is the description of the new Security Group.
        .PARAMETER VPCID
            This is the VPCID to create the new Security group in.
        .NOTES
            Author: Anthony Brown
            https://github.com/anthonyjamesbrown 
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(
            Mandatory=$true
        )]
        [string]
        $VPCID,

        [Parameter(
            Mandatory=$true
        )]
        [string]
        $GroupName,

        [Parameter(
            Mandatory=$true
        )]
        [string]
        $Description
    )

    $SG = New-EC2SecurityGroup -GroupName $GroupName -Description $Description -VpcId $VPCID

    $ipPerms = @(
        @{ IpProtocol="udp"; FromPort="445"; ToPort="445"; IpRanges="10.0.0.0/8" },         # SMB        
        @{ IpProtocol="udp"; FromPort="445"; ToPort="445"; IpRanges="172.16.0.0/12" },      # SMB
        @{ IpProtocol="udp"; FromPort="137"; ToPort="138"; IpRanges="10.0.0.0/8" },         # Netlogon
        @{ IpProtocol="udp"; FromPort="137"; ToPort="138"; IpRanges="172.16.0.0/12" },      # Netlogon
        @{ IpProtocol="tcp"; FromPort="49152"; ToPort="65535"; IpRanges="10.0.0.0/8" },     # Dynamic ports for RPC
        @{ IpProtocol="tcp"; FromPort="49152"; ToPort="65535"; IpRanges="172.16.0.0/12" },  # Dynamic ports for RPC
        @{ IpProtocol="tcp"; FromPort="139"; ToPort="139"; IpRanges="10.0.0.0/8" },         # Netlogon
        @{ IpProtocol="tcp"; FromPort="139"; ToPort="139"; IpRanges="172.16.0.0/12" },      # Netlogon
        @{ IpProtocol="tcp"; FromPort="135"; ToPort="135"; IpRanges="10.0.0.0/8" },         # RPC
        @{ IpProtocol="tcp"; FromPort="135"; ToPort="135"; IpRanges="172.16.0.0/12" },      # RPC
        @{ IpProtocol="tcp"; FromPort="10123"; ToPort="10123"; IpRanges="10.3.95.154/32" }, # SCCM
        @{ IpProtocol="tcp"; FromPort="10123"; ToPort="10123"; IpRanges="10.3.95.155/32" }, # SCCM
        @{ IpProtocol="tcp"; FromPort="10123"; ToPort="10123"; IpRanges="10.3.95.156/32" }, # SCCM
        @{ IpProtocol="tcp"; FromPort="10123"; ToPort="10123"; IpRanges="10.5.49.146/32" }, # SCCM
        @{ IpProtocol="tcp"; FromPort="3389"; ToPort="3389"; IpRanges="10.0.0.0/8" },       # RDP
        @{ IpProtocol="tcp"; FromPort="3389"; ToPort="3389"; IpRanges="172.16.0.0/12" },    # RDP
        @{ IpProtocol="tcp"; FromPort="445"; ToPort="445"; IpRanges="10.0.0.0/8" },         # SMB
        @{ IpProtocol="tcp"; FromPort="445"; ToPort="445"; IpRanges="172.16.0.0/12" },      # SMB
        @{ IpProtocol="tcp"; FromPort="5985"; ToPort="5986"; IpRanges="10.0.0.0/8" },       # Sophos
        @{ IpProtocol="tcp"; FromPort="5985"; ToPort="5986"; IpRanges="172.16.0.0/12" }     # Sophos
    )
    Grant-EC2SecurityGroupIngress -GroupId $SG -IpPermission $ipPerms
    $SG
} # end function New-ABAWSEC2SecurityGroup 

function New-ABAWSInstance
{
    <#
        .SYNOPSIS
            Creates a new AWS instance.
        .DESCRIPTION
            This script will create a new AWS instance.

            This script assumes that you have already authenticated with AWS using
            Set-AWSCredential or Set-AWSRole (discussed below)            
        .EXAMPLE
            PS> New-ABAWSInstance

            ...          
        .NOTES
            Author: Anthony Brown
            https://github.com/anthonyjamesbrown 
    #>

    [CmdletBinding()]
    param()

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
} # end function New-ABAWSInstance

function Set-AWSRole
{
        <#
        .SYNOPSIS
            Prompts a user from a list of available AWS Profiles as confiuged in SSO (PingFederate)
        .DESCRIPTION
            This client used PingFederate for SSO authentication to AWS.  AD groups were used to control
            AWS account access and role mapping.  This version works with PowerShell 5.1.
        .EXAMPLE
            PS> Set-AWSRole

            ...
        .PARAMETER UserName
            This is the name of the user to query VDS for.
        .PARAMETER Domain
            This is the domain to search for the user in.            
        .NOTES
            Author: Anthony Brown
            https://github.com/anthonyjamesbrown 
    #>

    [CmdletBinding()]
    param()
    
    Import-Module AWSPowershell
    Import-Module ActiveDirectory
 
    $PFedSigninURL = "https://sso.<some company>.com:9031/idp/startSSO.ping?PartnerSpId=urn:amazon:webservices"

    # This section does an AD lookup for the AD groups for a particular role.  I am assuming that an AD
    # group for the SuperAdmin role exists in every AWS account.
    # This is only used as a convenient way to map the ARN reference numbers to friendly account names.

    $ADRoleGroup = 'SuperAdmin'
    $ADGroups = get-ADGroup -LDAPFilter "(&(objectClass=group)(sAMAccountName=US.AWS*$ADRoleGroup*))"
    $AccountHash = [ordered]@{}
    $ADGroups | ForEach-Object {
        $GroupName = $_.Name
        $Name = $GroupName.Split(".")[2]
        $Env = $GroupName.Split(".")[3]
        $ID = $GroupName.Split(".")[4]

        if(-not $AccountHash.contains($ID))
        {
            $AccountHash.Add($ID,$("$Name - $Env"))    
        } # end if
    } # end foreach

    try
    {
        # Get the SAML Response from PingFed with Windows integrated authentication 
        $Response = Invoke-WebRequest $PFedSigninURL -UseDefaultCredentials -UseBasicParsing
        $SamlResponse = ($Response.InputFields.value.Split())[0]

        # Decode the SAML Response to find the role and SAML provider ARNs 
        $DecodedSAMLResponse = [xml]@([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($SamlResponse)))
 
        $Roles = ($DecodedSAMLResponse.Response.Assertion.AttributeStatement.Attribute | Where-Object {$_.Name -like "*Role"}).AttributeValue
 
        $Count = 0

        foreach($Role in $Roles.'#text')
        {
            #$role | write-output
            $RoleID = $Role.Split(":")[4]
            $RoleName = $AccountHash[$RoleID]
            if($Count -lt 10)
            {
                $CountString = "[ " + $Count + "  ]"
            } 
            else
            {
                $CountString = "[ " + $Count + " ]"
            } # end if
            $RoleString = ($Role.Split(",")) | Where-Object {$_ -like "*:role/*"}
            Write-Host $CountString $RoleName.PadRight(25) : ($RoleString.Split("/")[1])
            $Count++ 
        } # end foreach
 
        $Index = 0
 
        if($Count -gt 1)
        {
            Write-Host 'Which role do you want to assume? ' -NoNewLine -ForegroundColor Yellow 
            $Index = Read-Host 
        } # end if
 
        # Retrieving the role and SAML provider ARNs of your choice 
        $RoleArn = $Roles[$Index].'#text'.Split(",") | Where-Object {$_ -like "*:role/*"} 
        $PrincipalArn = $Roles[$index].'#text'.Split(",") | Where-Object {$_ -like "*:saml-provider/*"}
 
        # Assuming the specified role to get temporary credentials 
        $TemporaryCredentials = Use-STSRoleWithSAML -SAMLassertion $SamlResponse -RoleArn $RoleArn -PrincipalArn $PrincipalArn
 
        # Set the credentials - This is good for an hour
        Set-AWSCredentials -AccessKey $TemporaryCredentials.credentials.AccessKeyId -SecretKey $TemporaryCredentials.credentials.SecretAccessKey -SessionToken $TemporaryCredentials.credentials.SessionToken
        Set-DefaultAWSRegion -Region us-east-1
        get-IamAccountAlias
    } # end try section
    catch 
    {
      Write-Error $_.Exception.Message
    } # end try catch
    
    # Wrtie the credential profile and default AWS Region as global session variables.  
    # Other AWS cmdlets will automatically use these values if the exist
    $Global:StoredAWSCredentials = $StoredAWSCredentials
    $Global:StoredAWSRegion = $StoredAWSRegion
} # end function Set-AWSRole
