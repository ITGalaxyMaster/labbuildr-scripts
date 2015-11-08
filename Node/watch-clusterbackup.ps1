﻿<#
.Synopsis
   Short description
.DESCRIPTION
   labbuildr is a Self Installing Windows/Networker/NMM Environemnt Supporting Exchange 2013 and NMM 3.0
.LINK
   https://community.emc.com/blogs/bottk/2015/03/30/labbuildrbeta
#>


$Nodes = Get-ClusterNode
foreach ($node in $nodes)
{

Start-Process powershell.exe -ArgumentList ".\watch-backupevents.ps1 -Computername $($Node.Name)" -WindowStyle Normal
}
