#-------------------------
# AUTHOR: Bastiaan Groen
# Date  : 26-9-2019
$versie = "1.0"
#-------------------------

# BESCHRIJVING
#   Verwijderd bestanden en folders uit een opggegeven path.
#   Verwijderd ook lege mappen
#   verwijderd geen 'hidden', 'read only' en 'system' files


function SchrijfOutput
{
    param(
            [Parameter(Position=1)]
            [string]
            $text,
            [Parameter(Position=2)]
            [string]
            $level,
            [Parameter(Position=3)]
            [string]
            $max,
            [Parameter(Position=4)]
            [string]
            $updateNumber
          )
    $tijd = (get-date).ToString('T')

    switch($level)
    {
        "info" 
        {
            Write-Host -ForegroundColor "Yellow" -nonewline "[i] "
            Write-Host -ForegroundColor "Red" -nonewline "[$($tijd)] "
            Write-Host -ForegroundColor "Yellow" "$($text) "
        }
        "error" 
        {
            Write-Host -ForegroundColor "red" -nonewline "[!] "
            Write-Host -ForegroundColor "Red" -nonewline "[$($tijd)] "
            Write-Host -ForegroundColor "Yellow" "$($text) "
        }
        "done" 
        {
            Write-Host -ForegroundColor "green" -nonewline "[*] "
            Write-Host -ForegroundColor "Red" -nonewline "[$($tijd)] "
            Write-Host -ForegroundColor "Yellow" "$($text) "
        }
        "update"
        {
            Write-Host -ForegroundColor "DarkGray" -nonewline "              $($text)                                       `r"
            Write-Host -ForegroundColor "Gray" -nonewline "     [ $($updateNumber) / $($max)] `r"
            Write-Host -ForegroundColor "DarkGray" -nonewline "[i] `r"
        }
        default 
        {
            Write-Host -ForegroundColor "Yellow" -nonewline "[i] "
            Write-Host -ForegroundColor "Red" -nonewline "[$($tijd)] "
            Write-Host -ForegroundColor "Yellow" "$($text) "
        }
    }

}


Write-Host -ForegroundColor "Gray" "        ____  _     _   ______ _ _             "
Write-Host -ForegroundColor "Gray" "       / __ \| |   | | |  ____(_| |            "
Write-Host -ForegroundColor "Gray" "      | |  | | | __| | | |__   _| | ___ ___    "
Write-Host -ForegroundColor "Gray" "      | |  | | |/ _  | |  __| | | |/ _ / __|   "
Write-Host -ForegroundColor "Gray" "      | |__| | | (_| | | |    | | |  __\__ \   "
Write-Host -ForegroundColor "Gray" " ______\____/|_|\__,_| |_|    |_|_|\___|___/   "
Write-Host -ForegroundColor "Gray" "|_   __ \  ___ _ __ ___   _____   _____ _ __   "
Write-Host -ForegroundColor "Gray" "  | |__)  / _ | '_ ' _ \ / _ \ \ / / _ | '__|  "
Write-Host -ForegroundColor "Gray" "  |  __ /|  __| | | | | | (_) \ V |  __| |     "
Write-Host -ForegroundColor "Gray" " _| |  \  \___|_| |_| |_|\___/ \_/ \___|_|     "
Write-Host -ForegroundColor "Gray" -NoNewline "|____| |__|  "
Write-Host -ForegroundColor "DarkGray" "Verwijder oude bestanden en folders"
Write-Host -ForegroundColor "DarkGray" -NoNewline "Versie: "
Write-Host -ForegroundColor "red" "$($versie) "

Write-Host -ForegroundColor "Gray" ""


Write-Host -ForegroundColor "DarkGray" "   | [i] Gebruik backward slashes in de path: \"
Write-Host -ForegroundColor "DarkGray" -nonewline "                                                                                    C:\folderToDelete`r" 
Write-Host -ForegroundColor "Yellow" -nonewline "                                                                                 ]`r"  
Write-Host -ForegroundColor "Yellow" -nonewline "   | [>] vul het pad naar de folder of schijf in [ "
$path = Read-Host

Write-Host " "
Write-Host -ForegroundColor "DarkGray" "   | [i] Alles bestanden voor deze datum worden verwijderd"
Write-Host -ForegroundColor "DarkGray" -nonewline "                                                dd/mm/yyyy`r" 
Write-Host -ForegroundColor "Yellow" -nonewline "                                        ]`r"  
Write-Host -ForegroundColor "Yellow" -nonewline "   | [>] vul de datum in [  "
$datumString = Read-Host

try
{

  $limit = [datetime]::parseexact($datumString, 'dd/MM/yyyy', $null)

}
catch
{
  Write-Host -ForegroundColor "yellow" -nonewline "   | "
  Write-Host -ForegroundColor "red" -nonewline "[!] "
  Write-Host -ForegroundColor "yellow" -nonewline "Datum is verkeerd ingevuld! "
  exit
}

$TotalDelFiles = ( Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Measure-Object ).Count;
$TotalFiles= ( Get-ChildItem -Path $path -Recurse -Force | Measure-Object ).Count;
$LegeFolders = ( Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Measure-Object ).Count;

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Yellow "==============================================="
Write-Host -ForegroundColor Yellow "[i] Totaal Aantal Bestanden: " -NoNewline
Write-Host -ForegroundColor Gray  "$($TotalFiles) "
Write-Host -ForegroundColor Yellow "[i] Te Verwijdere Bestanden: " -NoNewline
Write-Host -ForegroundColor Gray  "$($TotalDelFiles) "                       
Write-Host -ForegroundColor Yellow "[i] Lege Folders:            " -NoNewline
Write-Host -ForegroundColor Gray  "$($LegeFolders)"
Write-Host -ForegroundColor Yellow "[i] bestanden log file:      " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFiles.log "
Write-Host -ForegroundColor Yellow "[i] folder log file:         " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFolders.log "
Write-Host -ForegroundColor Yellow "==============================================="


#---- bevestig verwijdering ------

   $title = "Bevestig permanente verwijdering van bestanden"
   $message = "Weet je zeker dat je $($TotalDelFiles) bestanden wilt verwijderen?"
   $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Ja", `
            "Bevestig verwijdering!"
   $no = New-Object System.Management.Automation.Host.ChoiceDescription "&Nee", `
            "Cancel verwijdering"
   $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
   $result = $host.ui.PromptForChoice($title, $message, $options, 0)


Write-Host " "
SchrijfOutput -level "info" -text "Start verwijderen van bestanden..."


$hiddenReadOnlyItemes = 0
$verwijderdeBestanden = 0
$verwijderdeFolders = 0

#---- bestanden verwijderen ------

$bestanden = Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit }
foreach ($bestand in $bestanden)
{
    try
    {
       $bestand | Remove-Item -ErrorAction Stop -Verbose 4>&1 | Add-Content "$($path)/deletedFiles.log"
       $verwijderdeBestanden += 1

       SchrijfOutput -level "update" -text "$($bestand.Name)" -max $TotalDelFiles -updateNumber $verwijderdeBestanden

    } Catch [System.IO.IOException]
    {
       SchrijfOutput -level "error" -text "$($bestand.Name) kon niet verwijderd worden!                                 "

       $hiddenReadOnlyItemes += 1

    } Catch {
       SchrijfOutput -level "error" -text "Er is een fout opgetreden met het verwijderen van een bestand "
    }

}

Write-Host "                                                                                      "                                                          
SchrijfOutput -level "done" -text "Klaar met verwijderen van bestanden!"
SchrijfOutput -level "done" -text "Nieuw log betand aangemaakt: deletedFiles.log"




#---- folders verwijderen ------

Write-Host " "
SchrijfOutput -level "info" -text "Start verwijderen van lege folders..."


$totalDelFolders = ( Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Measure-Object ).Count;
$folders = Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null }
foreach($folder in $folders)
{
   try{

     if($folder)
     {
        $folder | Remove-Item -Force -Recurse -ErrorAction Stop -Verbose 4>&1 | Add-Content "$($path)/deletedFolders.log"
        $verwijderdeFolders += 1
       
        SchrijfOutput -level "update" -text "$($folder.Name)" -max $totalDelFolders -updateNumber $verwijderdeFolders

     }else
     {
        SchrijfOutput -level "update" -text "[BESTAAT NIET MEER]$($folder.Name)" -max $totalDelFolders -updateNumber $verwijderdeFolders

     }

   } Catch{
        SchrijfOutput -level "update" -text "[BESTAAT NIET MEER]$($folder.Name)" -max $totalDelFolders -updateNumber $verwijderdeFolders
   }
}



Write-Host "                                                                                                      "
SchrijfOutput -level "done" -text "Klaar met verwijderen van folders!"
SchrijfOutput -level "done" -text "Nieuw log betand aangemaakt: deletedFolders.log"

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Yellow "==============================================="
Write-Host -ForegroundColor Yellow "[i] Totaal Aantal Bestanden: " -NoNewline
Write-Host -ForegroundColor Gray  "$($TotalFiles) "
Write-Host -ForegroundColor Yellow "[i] Verwijderede bestanden:  " -NoNewline
Write-Host -ForegroundColor Green  "$($verwijderdeBestanden) " 
Write-Host -ForegroundColor Yellow "[i] Verwijderede folders:    " -NoNewline
Write-Host -ForegroundColor Green  "$($verwijderdeFolders)"                      
Write-Host -ForegroundColor Yellow "[i] Niet kunnen verwijderen: " -NoNewline
Write-Host -ForegroundColor Red  "$($hiddenReadOnlyItemes) "                       
Write-Host -ForegroundColor Yellow "[i] bestanden log file:      " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFiles.log "
Write-Host -ForegroundColor Yellow "[i] folder log file:         " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFolders.log "
Write-Host -ForegroundColor Yellow "==============================================="
Write-Host " "
Write-Host " "


SchrijfOutput -level "done" -text "KLaar, Druk op enter om af te sluiten..."
$einde = Read-Host


