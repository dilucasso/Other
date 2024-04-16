##############
#zmienne
##############

$DirectoryRoot = 'C:\ASC\22061'
$DirectoryConf = $DirectoryRoot + '\conf'
$DirectoryLog = $DirectoryRoot + '\LOG'
$LogFile = $DirectoryLog + '\log.txt'
$SourceFileAppNameConf = $PSScriptRoot + '\app-name-conf.csv'
$SourceFileDevAppSrv = $PSScriptRoot + '\dev-app-srv.csv'
$DirectoryRaport = $DirectoryRoot + '\RAPORT'
$RaportVMFile = $DirectoryRaport + '\RaportVM.txt'
$RaportObiektyFile = $DirectoryRaport + '\RaportObiekty.txt'

$ModuleInstalled
$LogMessage
$LogDate
$LogUser
$LogMessage

$ReadHost
$FileAppNameConf = $DirectoryConf + '\app-name-conf.csv'
$FileDevAppSrv = $DirectoryConf + '\dev-app-srv.csv'
$Script:ImportedFileAppNameConf | Out-Null
$Script:ImportedFileDevAppSrv | Out-Null
$Tag
$Exists

$SRV
$PIP
$PIPAddress
$OBJ
$Object

$index
$tabRG
$tabRGCount
$Choice
$RGName
$locations
$RGLocation
$Locations
$RGNam
$CreatedResource
$Script:ChoosenRG
$Global:tabCreatedResources | Out-Null

$Script:ChoiceMenu
$Script:ChoiceProject
$Deleting
$Script:ChoosenProject
$Script:VNet
$ProjectVMs
$VM
$Script:AppVMname
$Script:AppVMsize
$Script:DBVMname
$Script:DBVMsize
$ProjectTag
$Tag
$Script:TagName
$Script:TagValue
$Script:TagTable = @{}

$VMname
$VMSize
$TagTab
$AppSrvName
$AppSrvSize
$AppSrvVNet
$AppSrvSubnet
$AppSrvNSG
$AppSrvPIP
$DBSrvName
$DBSrvSize
$DBSrvVNet
$DBSrvSubnet
$DBSrvNSG
$DBSrvPIP
$ProjectName
$VNetPrefix
$VNetName
$VNet
$ProjectName
$NSGName
$NSG

##############
#funkcje
##############
#funkcja tworzaca katalog root
function CreateDirectoryRoot{
    New-Item -Path $DirectoryRoot -ItemType Directory -Force | Out-Null
    }

#funkcja tworzaca katalog Conf
function CreateDirectoryConf{
    New-Item -Path $DirectoryConf -ItemType Directory -Force | Out-Null
    }

#funkcja tworzaca katalog LOG
function CreateDirectoryLog{
    New-Item -Path $DirectoryLog -ItemType Directory -Force | Out-Null
    }
    
#funkcja tworzaca plik logu
function CreateLogFile{
    New-Item -Path $LogFile -ItemType File -Force | Out-Null
    }

#funkcja tworzaca katalog RAPORT
function CreateDirectoryRaport{
    New-Item -Path $DirectoryRaport -ItemType Directory -Force | Out-Null
    }

#funkcja tworzaca plik RaportVM
function CreateFileRaportVM{
    New-Item -Path $RaportVMFile -ItemType File -Force | Out-Null
}

#funkcja tworzaca plik RaportObiekty
function CreateFileRaportObiekty{
    New-Item -Path $RaportObiektyFile -ItemType File -Force | Out-Null
}

#funkcja kopiujaca plik app-name-conf do katalogu Conf
function CopyFileAppNameConf{
    Copy-Item -Path $SourceFileAppNameConf -Destination $DirectoryConf -ErrorAction SilentlyContinue
}

#funkcja kopiujaca plik dev-app-srv do katalogu Conf
function CopyFileDevAppSrv{
    Copy-Item -Path $SourceFileDevAppSrv -Destination $DirectoryConf -ErrorAction SilentlyContinue
}

#funcja tworzaca strukture plikow
function CreateFiles{
    if(!(Test-Path $DirectoryRoot)){
        CreateDirectoryRoot
    }

    if(!(Test-Path $DirectoryLog)){
        CreateDirectoryLog
        CreateLogFile
        SaveToLog -LogMessage "Utworzono katalog $($DirectoryLog) i plik $($LogFile)" | Out-Null
    }
    elseif(!(Test-Path $LogFile)){
        CreateLogFile
        SaveToLog -LogMessage "Utworzono plik $($LogFile)" | Out-Null
    }
    
    if(!(Test-Path $DirectoryConf)){
        CreateDirectoryConf
        CopyFileAppNameConf
        CopyFileDevAppSrv
        SaveToLog -LogMessage "Utworzono katalog $($DirectoryConf) oraz pliki $($FileAppNameConf), $($FileDevAppSrv)" | Out-Null
    }

    if(!(Test-Path $FileAppNameConf)){
        CopyFileAppNameConf
        SaveToLog -LogMessage "Utworzono plik $($FileAppNameConf)" | Out-Null
    }

    if(!(Test-Path $FileDevAppSrv)){
        CopyFileDevAppSrv
        SaveToLog -LogMessage "Utworzono plik $($FileDevAppSrv)" | Out-Null
    }

    if(!(Test-Path $DirectoryRaport)){
        CreateDirectoryRaport
        SaveToLog -LogMessage "Utworzono katalog $($DirectoryRaport)" | Out-Null
    }

    if(!(Test-Path $RaportVMFile)){
        CreateFileRaportVM
        SaveToLog -LogMessage "Utworzono plik $($RaportVMFile)" | Out-Null
    }

    if(!(Test-Path $RaportObiektyFile)){
        CreateFileRaportObiekty
        SaveToLog -LogMessage "Utworzono plik $($RaportObiektyFile)" | Out-Null
    }
}

#funkcja instalujaca modul Powershell AZ
function InstallModulaAZ{
    $ModuleInstalled = Get-InstalledModule -Name Az -ErrorAction SilentlyContinue

    if($ModuleInstalled.length -eq 0){
        Write-Host "### Za chwile nastapi instalacja modulu Powershell Az - prosze czekac ###`n"
        Install-Module -Name Az -Repository PSGallery -Force -WarningAction SilentlyContinue
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

#funkcja sprawdzajaca istnienia pliku app-name-conf.csv
function CheckAppNameConf{
    if(!(Test-Path $FileAppNameConf)){
        do{
            Write-Host "Plik konfiguracyjny app-name-conf.csv nie istnieje!"
            Write-Host "Umiesc plik w katalogu $DirectoryConf i nacisnij ENTER."
            Write-Host "Aby zamknac probram wpisz 'Q' i nacisnij ENTER."
            $ReadHost = Read-Host
            if($ReadHost -eq "Q"){
                SaveToLog -LogMessage "Wykonywanie skryptu przerwane. Brak pliku $FileAppNameConf" | Out-Null
                exit
            }
        } while((Test-Path $FileAppNameConf) -eq $false)
    }

    #import danych z pliku CSV do zmiennej
    $Script:ImportedFileAppNameConf = Import-Csv -Path $FileAppNameConf -Delimiter ';'
    SaveToLog -LogMessage "Zaimportowano dane z pliku $($FileAppNameConf)" | Out-Null
}

#funkcja sprawdzajaca istnienie pliku dev-app-srv.csv
function CheckDevAppSrv{
    if(!(Test-Path $FileDevAppSrv)){
        do{
            Write-Host "Plik konfiguracyjny dev-app-srv.csv nie istnieje!"
            Write-Host "Umiesc plik w katalogu $DirectoryConf i nacisnij ENTER"
            Write-Host "Aby zamknac probram wpisz 'Q' i nacisnij ENTER"
            $ReadHost = Read-Host
                if($ReadHost -eq "Q"){
                SaveToLog -LogMessage "Wykonywanie skryptu przerwane. Brak pliku $FileDevAppSrv" | Out-Null
                exit
            }
        } while((Test-Path $FileDevAppSrv) -eq $false)
    }
    #import danych z pliku CSV do zmiennej
    $Script:ImportedFileDevAppSrv = Import-Csv -Path $FileDevAppSrv -Delimiter ';'
    SaveToLog -LogMessage "Zaimportowano dane z pliku $($FileDevAppSrv)" | Out-Null
}

#funkcja dodajaca wpis do raportu VM
function AddToRaportVM($SRV, $PIP)
{
    $PIPAddress = Get-AzPublicIpAddress -Name $PIP
    Add-Content -Path $RaportVMFile -Value "Name:$SRV; Public IP:$($PIPAddress.IpAddress)"
}

#funkcja dodajaca wpis do raportu obiektow
function AddToRaportObiekty($OBJ)
{
    $Object = ((Get-AzResource -Name $OBJ).Tags)
    Add-Content -Path $RaportObiektyFile -Value "Name:$($OBJ); Tagi:$($Object.Keys) - $($Object.Values)"
}

#funkcja pozwalajaca wybrac lub utworzyc grupe zasobow
function SetRG{
    Clear-Host

    Get-AzResourceGroup | ForEach-Object {
        $index+=1
        $tabRG += @([pscustomobject]@{Index=$index; ResourceGroupName=$PSItem.ResourceGroupName; `
            Location=$PSItem.Location; ResourceID=$PSItem.ResourceId})
    }

    Write-Host "==========  Grupy zasobow  ========="
    Write-Host "Wybierz jedna z istniejacych grup zasobow, podajac jej index."
    Write-Host "Jezeli chcesz dodac nowa grupe zasobow wybierz '0'."
    $tabRG | select -Property Index, ResourceGroupName, Location | Out-Host

    $tabRGCount = $tabRG.Count
        
    #weryfikacja poprawnosci wyboru opcji
    do{
        $Choice = Read-Host "Wybierz jedna z dostepnych opcji"
    } while($Choice -lt 0 -or $Choice -gt $tabRGCount)

    if($Choice -eq 0){
        Clear-Host
        $RGName = Read-Host "Podaj nazwe nowej grupy zasobow"
        Write-Host "Pobieranie listy lokalizacji..."
        $locations = Get-AzLocation | select -Property Location
        Clear-Host
        $locations | Out-Host
                    
        do{
            $RGLocation = Read-Host "Podaj lokalizacje nowej grupy zasobow z listy dostepnych"
            $Locations | foreach{
                if($RGLocation -eq $PSItem.Location){
                    New-AzResourceGroup -name $RGName -Location $RGLocation
                    $CreatedResource = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $RGName}
                    $Script:ChoosenRG = $CreatedResource
                    $Global:tabCreatedResources += @($CreatedResource.ResourceId)
                    break
                }
            }
        }while(1)
        SaveToLog -LogMessage "Utworzono grupe zasobow $($CreatedResource.ResourceGroupName)" | Out-Null
        pause
    }
    else{
        $Script:ChoosenRG = $tabRG[$Choice-1]
        $Script:ChoosenRG.ResourceGroupName
        SaveToLog -LogMessage "Wybrano grupe zasobow $($Script:ChoosenRG.ResourceGroupName)" | Out-Null
    }
}

#funkcja generujaca menu glowne
function ShowMainMenu {
    Clear-Host
    Write-Host "==========  Menu glowne  ========="
    Write-Host "1: Projekt Kopernik"
    Write-Host "2: Projekt Apollo"
    Write-Host "3: Projekt Sojuz"
    Write-Host "4: Usun stworzone zasoby"
    Write-Host "0: Zamknij program"

    #weryfikacja poprawnosci wyboru opcji
    do{
        $Script:ChoiceMenu = Read-Host "Wybierz jedna z dostepnych opcji"
    } while($Script:ChoiceMenu -lt 0 -or $Script:ChoiceMenu -gt 4)
    
    #wywolanie akcji zwiazanej z wyborem w menu
    switch ($Script:ChoiceMenu) {
        1 { ShowProjectMenu }
        2 { ShowProjectMenu }
        3 { ShowProjectMenu }
        4 { DeleteResources }
        0 { ProgramClose }
    }
}

#funkcja generujaca menu projektu
function ShowProjectMenu{
    Clear-Host
    Write-Host "==========  Projekt Kopernik  =========="
    Write-Host "1: Uruchom projekt"
    Write-Host "2: Uruchom serwer aplikacyjny"
    Write-Host "3: Uruchom serwer bazodanowy"
    Write-Host "4: Utworz siec"
    Write-Host "5: Utworz Network Security Group"
    Write-Host "6: Wroc do menu glownego"
    Write-Host "0: Zamknij program"

    #weryfikacja poprawnosci wyboru opcji
    do{
        $Script:ChoiceProject = Read-Host "Wybierz jedna z dostepnych opcji: "
    } while($Script:ChoiceProject -lt 0 -or $Script:ChoiceProject -gt 6)

    #wywolanie akcji zwiazanej z wyborem opcji projektu
    switch ($Script:ChoiceProject) {
        1 { CreateResource }
        2 { CreateResource }
        3 { CreateResource }
        4 { CreateResource }
        5 { CreateResource }
        6 { ShowMainMenu }
        0 { ProgramClose }
    }
}

#funkcja usuwajaca zasoby
function DeleteResources{
    Clear-Host
    Write-Host "Lista utworzonych zasobów:"
    $Global:tabCreatedResources | Out-Host
    
    Write-Host "`nUWAGA!!! OPERACJA JEST NIEODWRACALNA!!!"
    $Deleting = Read-Host "Aby usunac wszystkie zasoby wybierz 'Y'. Wybor innego klawisza anuluje operacje"

    if($Deleting -eq 'Y'){
        $Global:tabCreatedResources | foreach{
            Remove-AzResource -ResourceId $PSItem -Force -AsJob
            SaveToLog -LogMessage "Usunieto zasob $($PSItem)" | Out-Null
        }
        Clear-Variable tabCreatedResources -Scope Global
        pause
        ShowMainMenu
    }
    else{
        ShowMainMenu
    }
}

#funkcja zamykajaca program
function ProgramClose{
    Clear-Host
    Write-Host "`n=== Zamykanie programu. Do widzenia! ===`n"
    SaveToLog -LogMessage "Program zostal zamkniety" | Out-Null
    exit
}

#funkcja sterujaca tworzeniem zasobow
function CreateResource{
    if($Script:ChoiceMenu -eq 1){
        $Script:ChoosenProject = 'Kopernik'
        $Script:VNet = '10.10.1.0/24'
    }
    elseif($Script:ChoiceMenu -eq 2){
        $Script:ChoosenProject = 'Apollo'
        $Script:VNet = '10.10.2.0/24'
    }
    elseif($Script:ChoiceMenu -eq 3){
        $Script:ChoosenProject = 'Sojuz'
        $Script:VNet = '10.10.3.0/24'
    }
    
    #zbieranie danych na potrzeby tworzenia VM
    $ProjectVMs = $Script:ImportedFileDevAppSrv | Where-Object {$PSItem.Projekt -eq $Script:ChoosenProject}
    
    $ProjectVMs | ForEach-Object{
        foreach($VM in $PSItem){
            if($VM.VMname -match 'app'){
                $Script:AppVMname = $VM.VMname
                $Script:AppVMsize = $VM.VMsize
            }
            if($VM.VMname -match 'db'){
                $Script:DBVMname = $VM.VMname
                $Script:DBVMsize = $VM.VMsize
            }
        }
    }

    #zbieranie danych o tagach
    Clear-Variable TagTable -Scope Script
    $Script:TagTable = @{}
    $ProjectTag = $Script:ImportedFileAppNameConf | Where-Object {$PSItem.Projekt -eq $Script:ChoosenProject}

    $ProjectTag | ForEach-Object{
        foreach($Tag in $PSItem){
            $Script:TagName = $Tag.'tag-name'
            $Script:TagValue = $Tag.'tag-val'
            $Script:TagTable.Add($Script:TagName, $Script:TagValue)
        }
    }

    #wywolywanie funkcji tworzacych zasoby          
    if($Script:ChoiceProject -eq 1){
        SaveToLog -LogMessage "Utworzono srodowisko projektu $($Script:ChoosenProject)" | Out-Null
        CreateAppSrv $Script:AppVMname $Script:AppVMsize $Script:TagTable
        CreateDBSrv $Script:DBVMname $Script:DBVMsize $Script:TagTable
    }
    elseif($Script:ChoiceProject -eq 2){
        SaveToLog -LogMessage "Utworzono serwer aplikacyjny projektu $($Script:ChoosenProject)" | Out-Null
        CreateAppSrv $Script:AppVMname $Script:AppVMsize $Script:TagTable
    }
    elseif($Script:ChoiceProject -eq 3){
        SaveToLog -LogMessage "Utworzono serwer bazodanowy projektu $($Script:ChoosenProject)" | Out-Null
        CreateDBSrv $Script:DBVMname $Script:DBVMsize $Script:TagTable        
    }
    elseif($Script:ChoiceProject -eq 4){
        SaveToLog -LogMessage "Utworzono siec projektu $($Script:ChoosenProject)" | Out-Null
        CreateNetwork $Script:ChoosenProject $Script:VNet $Script:TagTable
    }
    elseif($Script:ChoiceProject -eq 5){
        SaveToLog -LogMessage "Utworzono NSG projektu $($Script:ChoosenProject)" | Out-Null
        CreateNSG $Script:ChoosenProject $Script:TagTable
    }
}

#funkcja uruchamiajaca serwer aplikacji
function CreateAppSrv($VMname, $VMSize, $TagTab){
    $AppSrvName = $VMname
    $AppSrvSize = $VMSize
    $AppSrvVNet = $VMname + "-vnet"
    $AppSrvSubnet = $VMname + "-subnet"
    $AppSrvNSG = $VMname + "-NSG"
    $AppSrvPIP = $VMname + "-PIP"

    #tworzenie VM
    New-AzVm `
        -ResourceGroupName $Script:ChoosenRG.ResourceGroupName `
        -Name $AppSrvName `
        -Location $Script:ChoosenRG.Location `
        -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
        -Size $AppSrvSize `
        -VirtualNetworkName $AppSrvVNet `
        -SubnetName $AppSrvSubnet `
        -SecurityGroupName $AppSrvNSG `
        -PublicIpAddressName $AppSrvPIP `
        -OpenPorts 80,3389

    #instalacja IIS
    Set-AzVMExtension `
        -ResourceGroupName $Script:ChoosenRG.ResourceGroupName `
        -ExtensionName "IIS" `
        -VMName $AppSrvName `
        -Location $Script:ChoosenRG.Location `
        -Publisher Microsoft.Compute `
        -ExtensionType CustomScriptExtension `
        -TypeHandlerVersion 1.8 `
        -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Set-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value \"Lukasz_Pajak_22061_Praca_zaliczeniowa_z_ASC\""}'

    #przypisywanie TAGow
    $VM = Get-AzVM -Name $AppSrvName
    Update-AzTag -ResourceId $VM.Id -Tag $TagTab -Operation Merge

    AddToRaportVM $AppSrvName $AppSrvPIP
    AddToRaportObiekty $AppSrvName
}

#funkcja tworzaca serwer bazodanowy
function CreateDBSrv($VMname, $VMSize, $TagTab){
    $DBSrvName = $VMname
    $DBSrvSize = $VMSize
    $DBSrvVNet = $VMname + "-vnet"
    $DBSrvSubnet = $VMname + "-subnet"
    $DBSrvNSG = $VMname + "-NSG"
    $DBSrvPIP = $VMname + "-PIP"

    #tworzenie VM
    New-AzVm `
        -ResourceGroupName $Script:ChoosenRG.ResourceGroupName `
        -Name $DBSrvName `
        -Location $Script:ChoosenRG.Location `
        -Image 'MicrosoftSQLServer:sql2019-ws2019:standard:latest' `
        -Size $DBSrvSize `
        -VirtualNetworkName $DBSrvVNet `
        -SubnetName $DBSrvSubnet `
        -SecurityGroupName $DBSrvNSG `
        -PublicIpAddressName $DBSrvPIP `
        -OpenPorts 80,3389
    
    #przypisywanie TAGow
    $VM = Get-AzVM -Name $DBSrvName
    Update-AzTag -ResourceId $VM.Id -Tag $TagTab -Operation Merge

    #zapisywanie raportu
    AddToRaportVM $DBSrvName $DBSrvPIP
    AddToRaportObiekty $DBSrvName
}

#funkcja tworzaca siec
function CreateNetwork($ProjectName, $VNetPrefix, $TagTab){
    $VNetName = $ProjectName + "-vnet"

    #tworzenie sieci
    New-AzVirtualNetwork `
        -name $VNetName `
        -ResourceGroupName $Script:ChoosenRG.ResourceGroupName `
        -Location $Script:ChoosenRG.Location `
        -AddressPrefix $VNetPrefix

    #przypisywanie TAGow
    $VNet = Get-AzVirtualNetwork -Name $VNetName
    Update-AzTag -ResourceId $VNet.Id -Tag $TagTab -Operation Merge

    #zapisywanie raportu
    AddToRaportObiekty $VNetName
    ShowMainMenu
}

#funkcja tworzaca Network Security Group
function CreateNSG($ProjectName, $TagTab){
    $NSGName = $ProjectName + "-NSG"

    #tworzenie NSG
    New-AzNetworkSecurityGroup `
        -Name $NSGName `
        -ResourceGroupName $Script:ChoosenRG.ResourceGroupName `
        -Location $Script:ChoosenRG.Location

    #przypisywanie TAGow
    $NSG = Get-AzNetworkSecurityGroup -Name $NSGName
    Update-AzTag -ResourceId $NSG.Id -Tag $TagTab -Operation Merge

    #zapisywanie raportu
    AddToRaportObiekty $NSGName
    ShowMainMenu
}

##############
#Blok skryptu
##############
#tworzenie struktury plikow
CreateFiles
SaveToLog -LogMessage "Program zostal uruchomiony" | Out-Null

#sprawdzanie istnienia plikow konfiguracyjnych
CheckAppNameConf
CheckDevAppSrv

#instalacja modulu powershell do obslugi Azure
InstallModulaAZ

#podlaczenie do Azure
Write-Host "### Za chwile nastapi logowanie do Azure ###`n"
Connect-AzAccount
Write-Host "### Zalogowano sie do Azure ###`n"
SaveToLog -LogMessage "Zalogowano sie do Azure" | Out-Null

#import modulu powershell do obslugi Azure
Write-Host "### Za chwile nastapi import modulu Powershell Az - prosze czekac ###`n"
Import-Module -Name Az
Write-Host "### Modul Powershell Az zostal zaimportowany ###`n"
SaveToLog -LogMessage "Modul Powershell Az zostal zaimportowany" | Out-Null

#wywolanie funkcji wyboru grupy zasobow
SetRG

#wywoalenie menu glownego
ShowMainMenu

##############
#skrypt end
##############