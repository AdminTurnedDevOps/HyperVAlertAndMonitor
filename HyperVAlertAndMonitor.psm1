Function Test-ServerConnection {
    <#
   .SYNOPSIS
   Test connection to servers
   .DESCRIPTION
   Allows you to do a Test-Connection to all servers. If the hostname fails, it will ask you to test by IP to confirm no DNS issues.
   .INPUTS
   You can pipe hostnames in by value or by property name
   .EXAMPLE
   C:\PS> Test-ServerConnection -Hostname 'HYPERV01','HYPERV02'
   .EXAMPLE
   C:\PS> 'HYPERV01 | Test-ServerConnection
   #>
    [cmdletbinding(DefaultParameterSetName = 'ServConnection', ConfirmImpact = 'low')]
    Param (
        [Parameter(Position = 0,
            ParameterSetName = 'ServConnection',
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Please input the hostnames of your Hyper-V server or servers you want to test the connection to")]
        [Alias('ComputerName', 'Node')]
        [psobject[]]$Hostname
    )
    Begin {
        if ($Hostname -notmatch '\w+') {
            $Hostname = $env:COMPUTERNAME
        }#if
        Write-Output "Starting: $MyInvocation.MyCommand"
    }
   
    Process {
        Try {
            if ($PSBoundParameters.ContainsKey('Hostname') -or $PSBoundParameters.ContainsKey('Computername')) {
                Write-Verbose 'Testing host connection...'
                if ($Hostname -match '\w+') {
                    $TestConnection = Test-Connection $Hostname
   
                    Write-Verbose 'Test host connection results below...'
                }#if2
               
                if (-not ($TestConnection.IPV4Address.IPV4AddressToString)) {
                    Write-Verbose 'Catching any errors'
                    $ServerIPAddress = Read-Host 'Please enter server IP address'
                    $TestConnection2 = Test-Connection $ServerIPAddress
                    If ($TestConnection2.IPV4Address) {
                        Write-Output 'Below is your IP address'
               
                        $ServerIPAddressOBJECT = [pscustomobject] @{
                            'ResolvedIPAddress' = $TestConnection2.IPV4Address[0]
                        }
   
                        Write-Verbose 'Producing output for IP address'
                        $ServerIPAddressOBJECT
                        Write-Host -ForegroundColor Green 'Connection worked with IP'
                    }#IF
                }#if3
            }#if1
        }#Try
   
        Catch {
            Write-Warning 'No connection was established with either an IP address or a hostname. Please confirm the server is on and try again.'
            $_
            Throw
        }#Catch    
    }#Process
    End {}
}#Function

###############################################################################################################################################a####################################################
Function Get-HyperVLogs {
    <#
.SYNOPSIS
Gets logs for HyperV in a menu-based console.
.DESCRIPTION
Allows you to pick from any of the 11 Hyper-V logs within Event Viewer to see all logs within the category.
.INPUTS
No inputs.
.EXAMPLE
C:\PS> Get-HyperVLogs
#>
    [cmdletbinding(DefaultParameterSetName = 'HyperVLogs', ConfirmImpact = 'Low')]
    Param (
        [Parameter(ParameterSetName = 'HyperVLogs')]
        [string]$Title = "Hyper-V Log Menu",

        [Parameter(ParameterSetName = 'HyperVLogs', 
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = (Read-Host 'Please enter a hostname')
    )

    Clear-Host

    Write-Host -ForegroundColor Green "============================================= $Title ============================================="
    Write-Output "1. Hyper-V-Compute`n2. Hyper-V-Config`n3. Hyper-V-Guest-Drivers`n4. Hyper-V-High-Availability`n5. Hyper-V-Hypervisor`n6. Hyper-V-Shared-VHDX `n7. Hyper-V-StorageVSP`n8. Hyper-V-VID`n9. Hyper-V-VMMS`n10. Hyper-V-VmSwitch`n11. Hyper-V-Worker`n12. QUIT"
    Do {
        $HyperVLog = Read-Host 'Please make a selection from above'
        If (1..12 -notcontains $HyperVLog) {
            Write-Warning 'WRONG CHOICE: Please choose between 1-12'
        }

        If ($ComputerName -notmatch '\w+') {
            $ComputerName += $env:COMPUTERNAME
        }
        
        switch ($HyperVLog) {
            '1' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-Compute*"   
            }
            '2' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-Config*"
            }
            '3' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-Guest-Drivers*"
            }
            '4' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-High-Availability*"
            }
            '5' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-Hypervisor*"
            }
            '6' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-Shared-VHDX*"
            }
            '7' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-StorageVSP*"
            }
            '8' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-VID*"
            }
            '9' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-VMMS*"
            }
            '10' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-VmSwitch*"
            }
            '11' {
                Get-WinEvent -ComputerName $ComputerName -ListLog "*Microsoft-Windows-Hyper-V-Worker*"
            }
            '12' {
                Write-Output 'Quitting...Goodbye'
                Pause
                Break
            }
        }#Switch
    }#Do
    Until($HyperVLog -eq [int]'12')

}#Function

###########################################################################################################################################################################################################
Function Get-iSCSIResults {
    <#
.SYNOPSIS
Get iSCSI connections
.DESCRIPTION
Get all iSCSI connects including target servers.
.INPUTS
No input.
.EXAMPLE
C:\PS> Get-iSCSIResults
#>
    [cmdletbinding(ConfirmImpact = 'low')]
    Param()

    Begin {
        Write-Verbose 'Collecting iSCSI connect results'
        $TestiSCSIConnection = Get-iscsiconnection
        $TestiSCSISession = Get-IscsiSession
        $FINAL = $TestiSCSIConnection + $TestiSCSISession
    }
    
    Process {
        Try {
            Foreach ($Test in $FINAL) {
                Write-Verbose 'Putting iSCSI connects into a custom object'
                $iSCSIOBJECTS = [pscustomobject] @{
                    'ConnectionID'          = $Test.ConnectionIdentifier
                    'iSCSITargetAddress'    = $Test.TargetAddress
                    'iSCSITargetPortNumber' = $Test.TargetPortNumber
                    'InitiatorNodeAddress'  = $Test.InitiatorNodeAddress
                    'TargetNodeAddress'     = $Test.TargetNodeAddress
                }
                Write-Host -ForegroundColor 'Below are the test results...'
                Write-Verbose 'Showing results of test'
                $iSCSIOBJECTS
            }#Foreach
        
            If ($iSCSIOBJECTS -like $null) {
                Write-Verbose 'Showing if no connections were found'
                Write-Warning 'WARNING: No connects were found. The following connections were tested;'
                Write-Output "1) iSCSI Target Address`n2) iSCSI Target Port`n3) Node address via iSCSI initiator`n4) Target node address"
            }

        }
        Catch {
            Write-Warning 'An error has occured'
            $_
            Throw
        }
    }
    End {}
}#function

##########################################################################################################################################################################################

Function Get-HyperVRAMUsage {
    <#
.SYNOPSIS
Gets current Hyper-V server RAM usage
.DESCRIPTION
Shows the free RAM that your Hyper-V server has. Alerts you if you're at 4GB or 2GB free.
.INPUTS
No input.
.EXAMPLE
C:\PS> Get-HyperVRAMUsage
#>
    [cmdletbinding()]
    Param()

    Begin {Write-Verbose 'Collecting: Free RAM'}

    Process {
        $Mem = Get-Ciminstance Win32_OperatingSystem | 
            Select-Object @{Name = 'FreeRAM_in_GB' ; expression = {[math]::Round($_.FreePhysicalMemory / 1MB)}}
        Write-Verbose 'Showing free RAM'
        Write-Output "Free RAM below"
        $Mem

        If ($Mem.FreeRAM_in_GB -like '4') {
            Write-Verbose 'Showing warning of RAM'
            Write-Warning "WARNING: The RAM on your Hyper-V host is less then 4GB"
        }

        If ($Mem.FreeRAM_in_GB -like '2') {
            Write-Host -ForegroundColor Red "WARNING: YOUR HYPER-V SERVER ONLY HAS 2GB OF RAM FREE! "
        }
    }
    End {}
}#Function

##############################################################################################################################################

Function Get-HyperVCPU {
    <#
.SYNOPSIS
Gets Hyper-V CPU usage
.DESCRIPTION
Gets current load percetnage of Hyper-V server, max clock speed, and name of CPU.
.INPUTS
No inputs
.EXAMPLE
C:\PS> Get-HyperVCPU
#>
    [cmdletbinding()]
    Param()

    Begin {Write-Verbose 'Collecting WMI class for CPU'}
    
    Process {
        Write-Host -ForegroundColor Green 'Below are your CPU results'
        $CPULOAD = Get-CimInstance -class Win32_Processor
        Foreach ($CPU in $CPULOAD) {
            $CPULOADobject = [pscustomobject] @{
                'CPUName'           = $CPU.Name
                'MaxClockSpeed'     = $CPU.MaxClockSpeed
                'CPULoadPercentage' = $CPU.LoadPercentage
            }
            $CPULOADobject

            If ($CPULOAD.LoadPercentage -gt '80') {
                Write-Warning 'WARNING: Your Hyper-V host is at 80% load'
            }

            If ($CPULOAD.LoadPercentage -gt '90') {
                Write-Host -ForegroundColor Red 'WARNING: YOUR HYPER-V SERVER IS AT 90% LOAD'
            }
        }#Foreach
    }
    End {}
}#Function