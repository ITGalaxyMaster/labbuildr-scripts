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
param(
    $Scriptdir = "\\vmware-host\Shared Folders\Scripts",
    $SourcePath = "\\vmware-host\Shared Folders\Sources",
    $logpath = "c:\Scripts",
    [ValidateSet(
    '3.0.0'
    )]
    $APPSYNC_VER='3.0.0'
    )
$Nodescriptdir = "$Scriptdir\Node"
$ScriptName = $MyInvocation.MyCommand.Name
$Host.UI.RawUI.WindowTitle = "$ScriptName"
$Builddir = $PSScriptRoot
$Logtime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
if (!(Test-Path $logpath))
    {
    New-Item -ItemType Directory -Path $logpath -Force
    }
$Logfile = New-Item -ItemType file  "$logpath\$ScriptName$Logtime.log"
Set-Content -Path $Logfile $MyInvocation.BoundParameters
############
.$Nodescriptdir\test-sharedfolders.ps1 -Folder $Sourcepath
############
$Setuppath = "$SourcePath\APPSYNC*\APPSYNC-$($APPSYNC_VER)-win-x64.exe"
Write-Warning "Installing APPSYNC $APPSYNC_VER, this could take up to 10 Minutes"
.$Nodescriptdir\test-setup.ps1 -setup APPSYNC -setuppath $Setuppath
Write-Warning "Installing APPSYNC $APPSYNC_VER"


$Arguments = "/S" 
Start-Process -FilePath $Setuppath -ArgumentList $Arguments -PassThru -Wait
#Start-Process "http://$($Env:COMPUTERNAME):58080/APG/"
if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    Pause
    }
