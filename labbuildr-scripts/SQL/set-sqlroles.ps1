﻿<#
.Synopsis
   Short description
.DESCRIPTION
   labbuildr builds your on-demand labs
.LINK
   https://github.com/bottkars/labbuildr/wiki
#>
#requires -version 3
[CmdletBinding()]
param(
$Servername = $env:COMPUTERNAME,
$Instancename = "MSSQL$env:USERDOMAIN",
$Loginnames = ("NT AUTHORITY\SYSTEM","$env:USERDOMAIN\$env:USERNAME","$env:USERDOMAIN\$env:COMPUTERNAME$","$env:USERDOMAIN\SQL_ADMINS","$env:USERDOMAIN\svc_sqladm"),
$Serverroles = ("dbcreator","sysadmin")
)
$ScriptName = $MyInvocation.MyCommand.Name
$Host.UI.RawUI.WindowTitle = "$ScriptName"
$Builddir = $PSScriptRoot
$Logtime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
New-Item -ItemType file  "$Builddir\$ScriptName$Logtime.log"
############
[System.Reflection.Assembly]::loadwithPartialName("Microsoft.SQLServer.SMO")
$Server = "$Servername\$Instancename"
$serverObject = New-Object Microsoft.SQLServer.Management.SMO.Server($server) 
foreach ($rolename in $Serverroles)
    {
        $role = $serverObject.Roles | where {$_.Name -eq $rolename}
        foreach ($Login in $loginnames)
            {
            Write-verbose "adding $($role.Name) for $login on $Server"
            $role.AddMember($login)
         }
    }
