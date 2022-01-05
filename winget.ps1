# Set language temorarely to en-US
Set-WinUserLanguageList en-US -Force

class Software {
    [string]$Name
    [string]$Id
    [string]$Version
    [string]$AvailableVersion
}

$upgradeResult = winget upgrade | Out-String

# Set language back to de-DE
Set-WinUserLanguageList de-DE -Force

if (!($upgradeResult -match "No installed package found matching input criteria."))
{


$lines = $upgradeResult.Split([Environment]::NewLine)

# Find the line that starts with Name, it contains the header
$fl = 0
while (-not $lines[$fl].StartsWith("Name"))
{
    $fl++
}

# Line $i has the header, we can find char where we find ID and Version
$idStart = $lines[$fl].IndexOf("Id")
$versionStart = $lines[$fl].IndexOf("Version")
$availableStart = $lines[$fl].IndexOf("Available")
$sourceStart = $lines[$fl].IndexOf("Source")

# Now cycle in real package and split accordingly
$upgradeList = @()
For ($i = $fl + 1; $i -le $lines.Length; $i++) 
{
    $line = $lines[$i]
    if ($line.Length -gt ($availableStart + 1) -and -not $line.StartsWith('-'))
    {
        $name = $line.Substring(0, $idStart).TrimEnd()
        $id = $line.Substring($idStart, $versionStart - $idStart).TrimEnd()
        $version = $line.Substring($versionStart, $availableStart - $versionStart).TrimEnd()
        $available = $line.Substring($availableStart, $sourceStart - $availableStart).TrimEnd()
        $software = [Software]::new()
        $software.Name = $name;
        $software.Id = $id;
        $software.Version = $version
        $software.AvailableVersion = $available;

        $upgradeList += $software
    }
}

$upgradeList | Format-Table
}

# Skip list
$toSkip = @(
'Citrix.Workspace',
'GnuPG.GnuPG',
'Oracle.VirtualBox',
'Mozilla.Firefox.ESR',
'Microsoft.VC++2008Redist-x86',
'Microsoft.VC++2008Redist-x64',
'Microsoft.Office',
'Microsoft.Teams',
'Ubisoft.Connect',
'EpicGames.EpicGamesLauncher')

foreach ($package in $upgradeList) 
{
    if (-not ($toSkip -contains $package.Id)) 
    {
        Write-Host "Going to upgrade package $($package.id)"
        & winget upgrade $package.id
    }
    else 
    {    
        Write-Host "Skipped upgrade to package $($package.id)"
    }
}
