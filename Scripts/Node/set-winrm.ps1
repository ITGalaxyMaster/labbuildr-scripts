﻿<#
.Synopsis
   Short description
.DESCRIPTION
   labbuildr is a Self Installing Windows/Networker/NMM Environemnt Supporting Exchange 2013 and NMM 3.0
.LINK
   https://community.emc.com/blogs/bottk/2015/03/30/labbuildrbeta
#>
#requires -version 3
$ScriptName = $MyInvocation.MyCommand.Name
$Host.UI.RawUI.WindowTitle = "$ScriptName"
$Builddir = $PSScriptRoot
$Logtime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
New-Item -ItemType file  "$Builddir\$ScriptName$Logtime.log"
##### Configure WINRM
Enable-PSRemoting -Confirm:$false -Force
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value True
Set-Item -Path WSMan:\localhost\Service\AllowRemoteAccess True
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted True
Set-Item -Path WSMan:\localhost\Service\Auth\Kerberos True
.\Add-DomainUserToLocalGroup.ps1 -computer $env:COMPUTERNAME -group Administrators -domain labbuildr.local -user SVC_WINRM
.\Add-DomainUserToLocalGroup.ps1 -computer $env:COMPUTERNAME -group "Remote Desktop Users" -domain labbuildr.local -user SVC_WINRM
