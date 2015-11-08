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
$DCName,
$Domain,
$IPv4Subnet = "192.168.2",
$IPv6Prefix = "",
[Validateset('IPv4','IPv6','IPv4IPv6')]$AddressFamily, 
[ValidateSet('24')]$IPv4PrefixLength = '24',
[ValidateSet('8','24','32','48','64')]$IPv6PrefixLength = '8',
[ipaddress]$DefaultGateway
)
$ScriptName = $MyInvocation.MyCommand.Name
$Host.UI.RawUI.WindowTitle = "$ScriptName"
$Builddir = $PSScriptRoot
$Logtime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
$Logfile = New-Item -ItemType file  "$Builddir\$ScriptName$Logtime.log"
write-output $PSCmdlet.MyInvocation.BoundParameters | Set-Content -Path $Logfile 
############
if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    Write-Output $PSCmdlet.MyInvocation.BoundParameters
    }

$nics = @()
$Nics = Get-NetAdapter | Sort-Object -Property ifIndex
$eth0 = $nics[0]
Rename-NetAdapter $eth0.Name -NewName $Domain

If ($AddressFamily -match 'IPv4')
{

    if ($DefaultGateway)
            {
        # New-NetIPAddress –InterfaceIndex $eth0.ifIndex –IPAddress "$Subnet.10" –PrefixLength 24 -DefaultGateway "$subnet.103"
        # $NewIP = 
        New-NetIPAddress -InterfaceIndex $eth0.ifIndex -AddressFamily IPv4 –IPAddress "$IPv4Subnet.10" –PrefixLength $IPv4PrefixLength -DefaultGateway $DefaultGateway
        }
    else
        {
        # New-NetIPAddress –InterfaceIndex $eth0.ifIndex –IPAddress "$Subnet.10" –PrefixLength 24
        New-NetIPAddress -InterfaceIndex $eth0.ifIndex -AddressFamily IPv4 –IPAddress "$IPv4Subnet.10" –PrefixLength $IPv4PrefixLength 
        }
Set-DnsClientServerAddress –InterfaceIndex $eth0.ifIndex -ServerAddresses "$IPv4Subnet.10"
}

If ($AddressFamily -match 'IPv6')
{

    if ($DefaultGateway)
            {
        # New-NetIPAddress –InterfaceIndex $eth0.ifIndex –IPAddress "$Subnet.10" –PrefixLength 24 -DefaultGateway "$subnet.103"
        # $NewIP = 
        New-NetIPAddress -InterfaceIndex $eth0.ifIndex -AddressFamily IPv6 –IPAddress "$IPv6subnet.10" –PrefixLength $IPv6PrefixLength -DefaultGateway "$IPv6subnet.$(([System.Version]$DefaultGateway.ToString()).revision)"
        }
    else
        {
        # New-NetIPAddress –InterfaceIndex $eth0.ifIndex –IPAddress "$Subnet.10" –PrefixLength 24
        New-NetIPAddress -InterfaceIndex $eth0.ifIndex -AddressFamily IPv6 –IPAddress "$IPv6subnet.10" –PrefixLength $IPv6PrefixLength
        }
Set-DnsClientServerAddress –InterfaceIndex $eth0.ifIndex -ServerAddresses "$IPv6subnet.10"

}


if ( $AddressFamily -notmatch 'IPv4')
    {
    Get-NetAdapter | Disable-NetAdapterBinding -ComponentID ms_tcpip
    }

if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    Pause
    }

Rename-Computer -NewName $DCName
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -Value 0
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name UserAuthentication -Value 1
Set-NetFirewallRule -DisplayGroup 'Remote Desktop' -Enabled True
Install-WindowsFeature –Name AD-Domain-Services,RSAT-ADDS –IncludeManagementTools
New-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name "Pass2" -Value "$PSHOME\powershell.exe -Command `"New-Item -ItemType File -Path c:\scripts\2.pass`""
restart-computer -force
