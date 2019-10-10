
Function Get-LocalMappedDrives {
	[CmdletBinding()]
	Param (
	[switch]$AsObject
	)
	begin {
		Write-Verbose "Calling Begin Block"
		$ProfileList = @()
		$UnloadedHives = @()
		$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
		Function Get-ProfileList{
			Try {
				Write-Verbose "Trying to generate array of all system user information"
				$ProfileList += $(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" `
					| Where-Object {$_.PSChildName -match $PatternSID} `
					| Select @{name="SID";expression={$_.PSChildName}},
							 @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}},
							 @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}})
							 
				#Add Default User to profile list manually so that changes affect new users on this system
				$ProfileList += $([pscustomobject]@{'SID'="DefUser";'UserHive'="C:\Users\Default\NTUSER.DAT";'Username'="Default"})
			} Catch {
				Write-Error -Message "Something went wrong while collecting system user information"
			}
			Write-Verbose "Successfully found user info.."
			# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
			$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} `
				| Select @{name="SID";expression={$_.PSChildName}} | % {$_.SID}
			# Get all users that are not currently logged in
			$ProfileList | % {if (-not ($LoadedHives -contains $_.SID)){$UnloadedHives += $($_ | % {$_.SID})}}
			Return $ProfileList,$UnloadedHives
		}
		Function Get-UserMappingTable([Object] $ProfileList,[Object] $UnloadedHives){
			Write-Verbose "$ProfileList"
			$UserMappingTable = @{}
			foreach ($Profile in $ProfileList) {
				$RegPath = "Registry::\HKEY_USERS\$($Profile.SID)"
				Write-Verbose "-----------Start Pass-----------"
				Write-Verbose "The Current User is : $($Profile.Username)"
				# Load User ntuser.dat if it's not already loaded
				IF ($UnloadedHives -contains $Profile.SID) {
					Write-Verbose "The registry hive for Current User: $($Profile.Username) is not loaded. Attempting to load..."
					Write-Verbose "...."
					Try {
						reg load HKU\$($Profile.SID) $($Profile.UserHive) | Out-Null
						Write-Verbose "Hive loaded succesfully"
					} Catch {
						Write-Error "An unexpected error has occured while attempting to load the registry hive."
						Write-Error "No changes will be made for this user"
					}	
				}
				Write-Verbose "Retrieving drive mappings for: $($Profile.Username) ..."
				Try {
					$MapObjects = Get-ChildItem $RegPath\Network\ | Get-ItemProperty | Where-Object {$_.ProviderName -eq 'Microsoft Windows Network'}
					$MapObjectArray = @()
					$MapObjects | % {
						$MapObjectArray += $([PSCustomObject]@{"Drive Letter"=$($_.PSChildName);
															   "Path"=$($_.RemotePath)}
						)
					}
					$UserMappingTable.Add($($Profile.Username),$MapObjectArray)
				} Catch {
					Write-Error "An error was encountered while creating registry settings for the current user."
					Write-Error "$Error"
				}
				IF ($UnloadedHives -contains $Profile.SID) {
					Write-Verbose "Trying to unload hive for current user"
					[gc]::collect()
					reg unload HKU\$($Profile.SID) | Out-Null
				}
				Write-Verbose "-----------End Pass-----------"
			}
			Return $UserMappingTable
		}
    }
	process {
		$ProfileList,$UnloadedHives = Get-ProfileList
		$UserMappingTable = Get-UserMappingTable $ProfileList $UnloadedHives
		if ($AsObject){
			Return $UserMappingTable
		} else {
			foreach ($key in $UserMappingTable.Keys){
				Write-Host $key 
				$UserMappingTable[$key] | Format-Table
			}
		}
	}
}