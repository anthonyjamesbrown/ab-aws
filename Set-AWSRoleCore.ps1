function Set-AWSRole
{    
    Import-Module AWSPowerShell.NetCore
 
    $PFedSigninURL = "https://sso.somecompany.com:9031/idp/startSSO.ping?PartnerSpId=urn:amazon:webservices"

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
        }
    }

    try
    {
        [System.Net.CredentialCache]$credentialCache = New-Object System.Net.CredentialCache
        $credential = [System.Net.CredentialCache]::DefaultNetworkCredentials
        $credentialCache.Add("https://sso.somecompany.com:9031", "NTLM", $credential)
        
        $handler = New-Object System.Net.Http.HttpClientHandler
        $handler.Credentials = $credentialCache
        $client = New-Object System.Net.Http.HttpClient -ArgumentList $handler
        $client.GetStringAsync($PFedSigninURL).GetAwaiter().GetResult()

        $response = $client.GetStringAsync($PFedSigninURL).GetAwaiter().GetResult()
        $samlResponse = [System.Xml.XPath.Extensions]::XPathSelectElement([System.Xml.Linq.XDocument]::Parse($response), '//input[@name="SAMLResponse"]').Attribute("value").Value

        $decodedSAMLResponse = [xml]@([System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($samlResponse)))
 
        $roles = ($decodedSAMLResponse.Response.Assertion.AttributeStatement.Attribute | Where-Object {$_.Name -like "*Role"}).AttributeValue
 
        $count = 0

        foreach($role in $roles.'#text')
        {
            #$role | write-output
            $RoleID = $role.Split(":")[4]
            $RoleName = $AccountHash[$RoleID]
            if($count -lt 10)
            {
                $CountString = "[ " + $count + "  ]"
            } 
            else
            {
                $CountString = "[ " + $count + " ]"
            }
            $RoleString = ($role.Split(",")) | Where-Object {$_ -like "*:role/*"}
            Write-Host $CountString $RoleName.PadRight(25) : ($RoleString.Split("/")[1])
            $count++ 
        }
 
        $index = 0
 
        if($count -gt 1)
        {
            Write-Host 'Which role do you want to assume? ' -NoNewLine -ForegroundColor Yellow 
            $index = Read-Host 
        }
 
        # Retrieving the role and SAML provider ARNs of your choice 
        $roleArn = $roles[$index].'#text'.Split(",") | Where-Object {$_ -like "*:role/*"} 
        $principalArn = $roles[$index].'#text'.Split(",") | Where-Object {$_ -like "*:saml-provider/*"}
 
        # Assuming the specified role to get temporary credentials 
        $temporaryCredentials = Use-STSRoleWithSAML -SAMLassertion $samlResponse -RoleArn $roleArn -PrincipalArn $principalArn
 
        # Set the credentials - This is good for an hour
        Set-AWSCredentials -AccessKey $temporaryCredentials.credentials.AccessKeyId -SecretKey $temporaryCredentials.credentials.SecretAccessKey -SessionToken $temporaryCredentials.credentials.SessionToken
        Set-DefaultAWSRegion -Region us-east-1
        get-IamAccountAlias
    }
    catch {
      Write-Error $_.Exception.Message
    }
    # Wrtie the credential profile and default AWS Region as global session variables.  
    # Other AWS cmdlets will automatically use these values if the exist
    $Global:StoredAWSCredentials = $StoredAWSCredentials
    $Global:StoredAWSRegion = $StoredAWSRegion
}

Set-AWSRole


