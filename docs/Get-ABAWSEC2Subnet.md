---
external help file: ab-aws-help.xml
Module Name: ab-aws
online version:
schema: 2.0.0
---

# Get-ABAWSEC2Subnet

## SYNOPSIS
Returns brief information about the configured subnets for a connected aws account.

## SYNTAX

```
Get-ABAWSEC2Subnet [<CommonParameters>]
```

## DESCRIPTION
This script is a wrapper for Get-EC2Subnet that includes the Name tag value.

This script assumes that you have already authenticated with AWS using
Set-AWSCredential or Set-AWSRole (discussed below)

## EXAMPLES

### EXAMPLE 1
```
Get-ABAWSec2Subnet
```

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

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Anthony Brown
https://github.com/anthonyjamesbrown

## RELATED LINKS
