---
external help file: ab-aws-help.xml
Module Name: ab-aws
online version:
schema: 2.0.0
---

# Get-ABAWSEC2vpc

## SYNOPSIS
Returns brief information about the configured VPCs for a connected aws account.

## SYNTAX

```
Get-ABAWSEC2vpc [<CommonParameters>]
```

## DESCRIPTION
This script is a wrapper for Get-EC2VPC that includes the Name tag value.

This script assumes that you have already authenticated with AWS using
Set-AWSCredential or Set-AWSRole (discussed below)

## EXAMPLES

### EXAMPLE 1
```
Get-ABAWSEC2Vpc
```

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
