﻿<#
.Synopsis
   Short description
.DESCRIPTION
   labbuildr is a Self Installing Windows/Networker/NMM Environemnt Supporting Exchange 2013 and NMM 3.0
.LINK
   https://community.emc.com/blogs/bottk/2015/03/30/labbuildrbeta
#>
#requires -version 3
[CmdletBinding()]
param (
$sp_version= "SP2013sp1fndtn",
$SourcePath = "\\vmware-host\Shared Folders\Sources",
$Setupcmd = "PrerequisiteInstaller.exe"
)

$ScriptName = $MyInvocation.MyCommand.Name
$Host.UI.RawUI.WindowTitle = "$ScriptName"
$Builddir = $PSScriptRoot
$Logtime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
New-Item -ItemType file  "$Builddir\$ScriptName$Logtime.log"
.$Builddir\test-sharedfolders.ps1
$Prereqpath = "$Sourcepath\$sp_version"+"Prereq"
$Setuppath = "$SourcePath\$sp_version\$Setupcmd"
.$Builddir\test-setup.ps1 -setup "Sharepoint 2013" -setuppath $Setuppath

$arguments = "/SQLNCli:`"$Prereqpath\sqlncli.msi`" /IDFX:`"$Prereqpath\Windows6.1-KB974405-x64.msu`" /IDFX11:`"$Prereqpath\MicrosoftIdentityExtensions-64.msi`" /Sync:`"$Prereqpath\Synchronization.msi`" /AppFabric:`"$Prereqpath\WindowsServerAppFabricSetup_x64.exe`" /KB2671763:`"$Prereqpath\AppFabric1.1-RTM-KB2671763-x64-ENU.exe`" /MSIPCClient:`"$Prereqpath\setup_msipc_x64.msi`" /WCFDataServices:`"$Prereqpath\WcfDataServices.exe`" /WCFDataServices56:`"$Prereqpath\WcfDataServices56.exe`"" #>

Write-Verbose "Trying Prereq Install"

Start-Process $Setuppath -ArgumentList "/unattended $arguments" -Wait
