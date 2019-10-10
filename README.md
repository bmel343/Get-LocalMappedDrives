# Get-LocalMappedDrives
Retrieves mapped drives for all users on a system
This function iterates over all local profiles and retrieves any drive map configurations for those user. By default it will print results to shell, but if you call it with the -AsObject switch it will return results as a hash table. 
The accompanying .EXE is a portable front end for the function. 
