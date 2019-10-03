#-------------------------
#          INFO                
#-------------------------
# AUTHOR: Bastiaan Groen
# Date  : 03-10-2019
$version = "2.0"
#-------------------------


# --- DISCRIPTION --------
# A Powershell script deletes files older than a certain date in a predefined folder.
# It checks the last-used date property of a file, when its older than the specified date, it will be deleted.
# It also deletes all empty folders that it can find in its predefined folder
# ------------------------

# --- CAUTION ------------
# This powershell is NOT extensively tested.
# There is NO undo!
# ------------------------


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
Write-Host -ForegroundColor "DarkGray" "~ Bastiaan Groen ~"
Write-Host -ForegroundColor "DarkGray" -NoNewline "Version: "
Write-Host -ForegroundColor "red" "$($version) "

Write-Host -ForegroundColor "Gray" ""


Write-Host -ForegroundColor "DarkGray" "   | [i] Use backward slashes: \"
Write-Host -ForegroundColor "DarkGray" -nonewline "                                                                                    C:\folderToDelete`r" 
Write-Host -ForegroundColor "Yellow" -nonewline "                                                                                 ]`r"  
Write-Host -ForegroundColor "Yellow" -nonewline "   | [>] Fill in a folder path [ "
$path = Read-Host

Write-Host " "
Write-Host -ForegroundColor "DarkGray" "   | [i] All files BEFORE this date will be deleted"
Write-Host -ForegroundColor "DarkGray" -nonewline "                                                dd/mm/yyyy`r" 
Write-Host -ForegroundColor "Yellow" -nonewline "                                        ]`r"  
Write-Host -ForegroundColor "Yellow" -nonewline "   | [>] Fill in a date [  "
$datumString = Read-Host

try
{

  $limit = [datetime]::parseexact($datumString, 'dd/MM/yyyy', $null)

}
catch
{
  SchrijfOutput -level "error" -text "Date was incorrect!"
  exit
}

$TotalDelFiles = ( Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Measure-Object ).Count;
$TotalFiles= ( Get-ChildItem -Path $path -Recurse -Force | Measure-Object ).Count;
$LegeFolders = ( Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Measure-Object ).Count;

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Yellow "==============================================="
Write-Host -ForegroundColor Yellow "[i] Total files:             " -NoNewline
Write-Host -ForegroundColor Gray  "$($TotalFiles) "
Write-Host -ForegroundColor Yellow "[i] To be deleted:           " -NoNewline
Write-Host -ForegroundColor Gray  "$($TotalDelFiles) "                       
Write-Host -ForegroundColor Yellow "[i] Empty folders:           " -NoNewline
Write-Host -ForegroundColor Gray  "$($LegeFolders)"
Write-Host -ForegroundColor Yellow "[i] log file:                " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFiles.log "
Write-Host -ForegroundColor Yellow "[i] log file:                " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFolders.log "
Write-Host -ForegroundColor Yellow "==============================================="


#---- bevestig verwijdering ------

   $title = "Confirm non reversible removal of files"
   $message = "Are you sure you want to delete $($TotalDelFiles) files?"
   $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
            "Confirm!"
   $no = New-Object System.Management.Automation.Host.ChoiceDescription "&NO", `
            "Cancel!"
   $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
   $result = $host.ui.PromptForChoice($title, $message, $options, 0)


Write-Host " "
SchrijfOutput -level "info" -text "Start deleting files..."


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
       SchrijfOutput -level "error" -text "$($bestand.Name) couldn't be deleted                                "

       $hiddenReadOnlyItemes += 1

    } Catch {
       SchrijfOutput -level "error" -text "There was an error with deleting a file"
    }

}

Write-Host "                                                                                      "                                                          
SchrijfOutput -level "done" -text "Done with delting files"
SchrijfOutput -level "done" -text "New log file made: deletedFiles.log"




#---- folders verwijderen ------

Write-Host " "
SchrijfOutput -level "info" -text "Start deleting empty folders..."


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
SchrijfOutput -level "done" -text "Done with deleting folders"
SchrijfOutput -level "done" -text "New log file made: deletedFolders.log"

Write-Host " "
Write-Host " "
Write-Host -ForegroundColor Yellow "==============================================="
Write-Host -ForegroundColor Yellow "[i] Total files:             " -NoNewline
Write-Host -ForegroundColor Gray  "$($TotalFiles) "
Write-Host -ForegroundColor Yellow "[i] deleted files:           " -NoNewline
Write-Host -ForegroundColor Green  "$($verwijderdeBestanden) " 
Write-Host -ForegroundColor Yellow "[i] deleted folders:         " -NoNewline
Write-Host -ForegroundColor Green  "$($verwijderdeFolders)"                      
Write-Host -ForegroundColor Yellow "[i] Couldn't delete files:   " -NoNewline
Write-Host -ForegroundColor Red  "$($hiddenReadOnlyItemes) "                       
Write-Host -ForegroundColor Yellow "[i] log file:                " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFiles.log "
Write-Host -ForegroundColor Yellow "[i] log file:                " -NoNewline
Write-Host -ForegroundColor Gray  "deletedFolders.log "
Write-Host -ForegroundColor Yellow "==============================================="
Write-Host " "
Write-Host " "


SchrijfOutput -level "done" -text "Done... press enter to exit"
$einde = Read-Host


