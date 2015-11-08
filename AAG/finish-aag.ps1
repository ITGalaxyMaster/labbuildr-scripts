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
############
$Domain = $env:USERDOMAIN
Start-Process C:\scripts\Autologon.exe -ArgumentList "SVC_SQLADM $Domain Password123! /accepteula"
New-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name "FINISHAAG" -Value "$PSHOME\powershell.exe -Command `"New-Item -ItemType File -Path c:\scripts\finishaag.pass`""
Restart-Computer
