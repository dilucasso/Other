##############
#zmienne
##############

$LogFile = 'C:\ASC\LOG\zadanie2.log'
$AllowedLocations = @('polandcentral', 'westeurope')
$ModuleInstalled
$LogMessage
$LogDate
$LogUser
$UserRG
$UserLocation
$TagTable = @{}
$TagName
$TagValue
$AllowedOptions = @('y', 'n')
$Continue

##############
#funkcje
##############

#funkcja tworzaca plik logu
function CreateLogFile{
    New-Item -Path $LogFile -ItemType File -Force | Out-Null
    }

#funkcja sprawdzajaca, czy modul Az jest zainstaowany, jezel nie, nastepuje instalacja
function InstallModulaAZ{
    $ModuleInstalled = Get-InstalledModule -Name Az -ErrorAction SilentlyContinue

    if($ModuleInstalled.length -eq 0){
        Write-Host "### Za chwile nastapi instalacja modulu Powershell Az - prosze czekac ###`n"
        Install-Module -Name Az -Repository PSGallery -Force
        SaveToLog -LogMessage "Modul Powershell Az zostal zainstalowany" | Out-Null
    }
    else{
        SaveToLog -LogMessage "Modul Powershell Az jest juz zainstalowany, nie ma potrzeby ponownej instalacji" | Out-Null
    }
}

#funkcja zapisujaca do logu
function SaveToLog{
    param(
        [string]$LogMessage
    )

    $LogDate = Get-Date
    $LogUser = $env:USERNAME
    $LogMessage

    "$($LogDate); $($LogUser); $($LogMessage)" | Out-File -FilePath $LogFile -Append
}

##############
#Blok skryptu
##############

#sprawdzamy czy plik logu istnieje i tworzymy go jezeli nie istnieje
if(!(Test-Path $LogFile)){
    CreateLogFile
    SaveToLog -LogMessage "Utworzono plik logu $($LogFile)" | Out-Null
}
else{
    SaveToLog -LogMessage "Plik logu istnieje" | Out-Null
}

#instalujemy oraz importujemy modul powershell do obslugi Azure
InstallModulaAZ
Write-Host "### Za chwile nastapi import modulu Powershell Az - prosze czekac ###`n"
Import-Module -Name Az
Write-Host "### Modul Powershell Az zostal zaimportowany ###`n"
SaveToLog -LogMessage "Modul Powershell Az zostal zaimportowany" | Out-Null

#podlaczamy sie do Azure
Write-Host "### Za chwile nastapi logowanie do Azure ###`n"
Connect-AzAccount
Write-Host "### Zalogowano sie do Azure ###`n"
SaveToLog -LogMessage "Zalogowano sie do Azure" | Out-Null

Write-Host "### Podaj potrzebne informacje w celu utworzenia grupy zasobow###`n"

#pobieramy od uzytkownika nazwe grupy zasobow
$UserRG = Read-Host "Podaj nazwe grupy zasobow"
SaveToLog -LogMessage "Uzytkownik podal nazwe Grupy zasobow: $($UserRG)" | Out-Null

#pobieramy od uzytkownika nazwe regionu, zezwalajac tylko na wczesniej zdefiniowane
do{
    $UserLocation = Read-Host "Podaj region dla tworzonego zasobu"
    
    if(!($UserLocation -in $AllowedLocations)){
        Write-Host "Nie mozna tworzyc zasobow w tym regionie! Dostepne regiony: $AllowedLocations"
        SaveToLog -LogMessage "UWAGA! Uzytkownik wybral niedostepny region: $($UserLocation)" | Out-Null
    }
}
while(!($UserLocation -in $AllowedLocations))
SaveToLog -LogMessage "Uzytkownik wybral region: $($UserLocation)" | Out-Null

#pobieramy od uzytkownika tagi
do{
    $TagName = Read-Host "Tag Name"
    $TagValue = Read-Host "Tag Value"
    $TagTable.Add($TagName, $TagValue)
    
    SaveToLog -LogMessage "Uzytkownik dodal TAG: $($TagName)=$($TagValue)" | Out-Null
    
    do{
        $Continue = Read-Host "Czy chcesz dodac kolejny TAG? (y/n)"
    }while(!($Continue -in $AllowedOptions))

}while(!($Continue -eq 'n'))

#tworzymy Resource group
Write-Host "`n### Tworzenie grupy zasobow ###`n"
New-AzResourceGroup -Name $UserRG -Location $UserLocation -Tag $TagTable
SaveToLog -LogMessage "Grupa zasobow $($UserRG) zostala utworzona" | Out-Null
Write-Host "`n### Grupa zasobow $($UserRG) zostala utworzona ###`n"

##############
#skrypt end
##############