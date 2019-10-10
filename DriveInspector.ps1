##[Ps1 To Exe]
##
##NcDBCIWOCzWE8pGP3wFk4Fn9fmk8b9eehZKox5Sx+uT4qBn+QI48XFZLsSzoSWeyWvMeePQFpNQVcQ8jOfcY3pXVD6qFSqELns5+e/WLopY7HEzd8N3kwEjy
##Kd3HDZOFADWE8uK1
##Nc3NCtDXThU=
##Kd3HFJGZHWLWoLaVvnQnhQ==
##LM/RF4eFHHGZ7/K1
##K8rLFtDXTiS5
##OsHQCZGeTiiZ4tI=
##OcrLFtDXTiS5
##LM/BD5WYTiiZ4tI=
##McvWDJ+OTiiZ4tI=
##OMvOC56PFnzN8u+VslQ=
##M9jHFoeYB2Hc8u+VslQ=
##PdrWFpmIG2HcofKIo2QX
##OMfRFJyLFzWE8uK1
##KsfMAp/KUzWJ0g==
##OsfOAYaPHGbQvbyVvnQX
##LNzNAIWJGmPcoKHc7Do3uAuO
##LNzNAIWJGnvYv7eVvnQX
##M9zLA5mED3nfu77Q7TV64AuzAgg=
##NcDWAYKED3nfu77Q7TV64AuzAgg=
##OMvRB4KDHmHQvbyVvnQX
##P8HPFJGEFzWE8tI=
##KNzDAJWHD2fS8u+Vgw==
##P8HSHYKDCX3N8u+Vgw==
##LNzLEpGeC3fMu77Ro2k3hQ==
##L97HB5mLAnfMu77Ro2k3hQ==
##P8HPCZWEGmaZ7/K1
##L8/UAdDXTlaDjofG5iZk2Ur5Q3ouUuGUuqOqwY+o7NbLsjHxXJgoblFj2wXzB0qxdPMCRfARkMMYQxg5E9YZ66TVMum6VacJhuxtJeCWo9I=
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    Drive Inspector
#>

. .\Get-LocalMappedDrives.ps1
Add-Type -AssemblyName System.Windows.Forms
# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Show-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

$ExecuteBlock = {
	$MyMappingTable = Get-LocalMappedDrives -AsObject
	ForEach ($Key in $MyMappingTable.Keys){
		$Name = "$Key : `r`n `r`n"
		$Table = $MyMappingTable[$key] | Format-Table | Out-String
		If (-Not $Table){
			$Table = "No drive mappings for this user `r`n`r`n"
		}
		$TextBox1.Text += $Name
		$TextBox1.Text += $Table
	}
}

$DisplayForm                     = New-Object system.Windows.Forms.Form
$DisplayForm.ClientSize          = '600,600'
$DisplayForm.text                = "Drive Inspector"
$DisplayForm.TopMost             = $false
$DisplayForm.FormBorderStyle     = "Fixed3D"
$DisplayForm.MaximizeBox         = $false

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $true
$TextBox1.ForeColor              = "#FFFFFF"
$TextBox1.BackColor              = "#012456"
$TextBox1.width                  = 564
$TextBox1.height                 = 520
$TextBox1.Scrollbars 			 = "Vertical"
$TextBox1.location               = New-Object System.Drawing.Point(18,65)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Show Drives"
$Button1.width                   = 102
$Button1.height                  = 31
$Button1.location                = New-Object System.Drawing.Point(18,18)
$Button1.Font                    = 'Microsoft Sans Serif,10'
$Button1.Add_Click($ExecuteBlock)

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Debug"
$Button2.width                   = 80
$Button2.height                  = 25
$Button2.location                = New-Object System.Drawing.Point(500,18)
$Button2.Font                    = 'Microsoft Sans Serif,10'
$Button2.Add_Click({Show-Console})

[System.Windows.Forms.Application]::EnableVisualStyles()
$DisplayForm.controls.AddRange(@($TextBox1,$Button1,$Button2))
Hide-Console



#Write your logic code here

[void]$DisplayForm.ShowDialog()