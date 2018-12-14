---
external help file: ab-aws-help.xml
Module Name: ab-aws
online version:
schema: 2.0.0
---

# Get-ABAWSNameTag

## SYNOPSIS
Returns the Name tag value for a given AWS resource-id

## SYNTAX

```
Get-ABAWSNameTag [-ResourceID] <String> [<CommonParameters>]
```

## DESCRIPTION
This script will get the Name tag value for a given AWS resource-id

This script assumes that you have already authenticated with AWS using
Set-AWSCredential or Set-AWSRole (discussed below)

## EXAMPLES

### EXAMPLE 1
```
This example gets the VPC Name tag value for the VPC object with a
```

vpcid of vpc-06233a13830bc67a3

PS\> Get-ABAWSNameTag -ResourceID vpc-06233a13830bc67a3
myAWSVPC

## PARAMETERS

### -ResourceID
This is the name of the resource id to return the Name tag value for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Anthony Brown
https://github.com/anthonyjamesbrown

## RELATED LINKS
