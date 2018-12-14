---
external help file: ab-aws-help.xml
Module Name: ab-aws
online version:
schema: 2.0.0
---

# New-ABAWSEC2SecurityGroup

## SYNOPSIS
Create a new EC2 Security Group with a preset list of rules.

## SYNTAX

```
New-ABAWSEC2SecurityGroup [-VPCID] <String> [-GroupName] <String> [-Description] <String> [<CommonParameters>]
```

## DESCRIPTION
This script will create a new EC2 Security Group with a preset list of inbound rules.
The rules here are used as an example and would probably be overly permissive for use
on non lab instances.

This script assumes that you have already authenticated with AWS using
Set-AWSCredential or Set-AWSRole (discussed below)

## EXAMPLES

### EXAMPLE 1
```
$props = @{
```

'GroupName' = 'AD Member Server SG'
    'Description' = 'Common com ports for Windows servers.'
    'VpcID' = 'vpc-06233a13830bc67a3'
}
New-EC2SecurityGroup @props

sg-0737830ddb3ced801
...

## PARAMETERS

### -VPCID
This is the VPCID to create the new Security group in.

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

### -GroupName
This is the name of the new Security Group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
This is the description of the new Security Group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
