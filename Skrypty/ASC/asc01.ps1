##############
#zmienne
##############

$file_exists
$source_file = 'C:\ASC\services.txt'
$report_file = 'C:\ASC\report.html'
$services_list
$s_list
$s_get
$tab = @()
$user
$date

##############
#funkcje
##############


##############
#Blok skryptu
##############

#sprawdzamy czy plik zrodlowy istnieje
$file_exists = Test-Path $source_file

if($file_exists -eq 'TRUE')
    {
        #pobieramy liste uslug z pliku zrodlowego
        $services_list = Get-Content -Path $source_file

        #sprawdzamy kazda usluge z listy
        $services_list | ForEach-Object {
            
            #pobieramy z systemu dane uslugi o nazwie pobranej z pliku zrodlowego
            $s_list = $PSItem
            $s_get = Get-service -Name $s_list -ErrorAction SilentlyContinue
            
            #jezeli zmienna przechowujaca dane o usludze nie jest pusta dodajemy dane uslugi do tablicy
            if($s_get.length -gt 0)
            {
                $tab += @([pscustomobject]@{DisplayName=$s_get.displayname;Status=$s_get.status})
            }
            #jezeli zmienna przechowujaca dane o usludze jest pusta dodajemy do tablicy informacje o braku uslugi
            else
            {
                $tab += @([pscustomobject]@{DisplayName=$s_list;Status='Service does not exist'})
            }
        }
        
        #pobieramy uzytkownika i date
        $user = "User: $($env:USERNAME)"
        $date = "Date: $(Get-Date)"

        #konwertujemy tablice z uslugami na HTML i oznaczamy statusy odpowiednim kolorem
        $tab | ConvertTo-Html -Body "$($user)<br>$($date)" | ForEach-Object {
            if($PSItem -like '*<td>Running</td>*')
            {
                $PSItem -replace '<td>Running</td>', '<td style="color:green">Running</td>'
            }
            elseif($PSItem -like '*<td>Stopped</td>*')
            {
                $PSItem -replace '<td>Stopped</td>', '<td style="color:red">Stopped</td>'
            }
            else{
                $PSItem
            }
        } | Out-File -FilePath $report_file #zapisujemy wynik do pliku html
        Invoke-Item $report_file #otwieramy plik raportu
    }
#jezeli plik zrodlowy nie istnieje wypisujemy informacje
else
    {
        Write-Host "Plik zrodlowy $($source_file) nie istnieje. Raport nie zostal wygenerowany."
    }

############## 
#skrypt end 
##############