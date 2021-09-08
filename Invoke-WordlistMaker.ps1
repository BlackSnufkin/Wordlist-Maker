function Invoke-WordlistMaker () {

function Banner() {
Write-Host '

$$\      $$\                           $$\ $$\ $$\             $$\     
$$ | $\  $$ |                          $$ |$$ |\__|            $$ |    
$$ |$$$\ $$ | $$$$$$\   $$$$$$\   $$$$$$$ |$$ |$$\  $$$$$$$\ $$$$$$\   
$$ $$ $$\$$ |$$  __$$\ $$  __$$\ $$  __$$ |$$ |$$ |$$  _____|\_$$  _|  
$$$$  _$$$$ |$$ /  $$ |$$ |  \__|$$ /  $$ |$$ |$$ |\$$$$$$\    $$ |    
$$$  / \$$$ |$$ |  $$ |$$ |      $$ |  $$ |$$ |$$ | \____$$\   $$ |$$\ 
$$  /   \$$ |\$$$$$$  |$$ |      \$$$$$$$ |$$ |$$ |$$$$$$$  |  \$$$$  |
\__/     \__| \______/ \__|       \_______|\__|\__|\_______/    \____/
' -ForegroundColor Green -NoNewline;

Write-Host '
$$\      $$\           $$\                                             
$$$\    $$$ |          $$ |                                            
$$$$\  $$$$ | $$$$$$\  $$ |  $$\  $$$$$$\   $$$$$$\                    
$$\$$\$$ $$ | \____$$\ $$ | $$  |$$  __$$\ $$  __$$\                   
$$ \$$$  $$ | $$$$$$$ |$$$$$$  / $$$$$$$$ |$$ |  \__|                  
$$ |\$  /$$ |$$  __$$ |$$  _$$<  $$   ____|$$ |                        
$$ | \_/ $$ |\$$$$$$$ |$$ | \$$\ \$$$$$$$\ $$ |                        
\__|     \__| \_______|\__|  \__| \_______|\__|
' -ForegroundColor Magenta  -NoNewline

}
 
Function MenuMaker{
    param(
        [parameter(Mandatory=$true)][String[]]$Selections,
        [switch]$IncludeExit,
        [string]$Title = $null
        )

    $Width = if($Title){$Length = $Title.Length;$Length2 = $Selections|%{$_.length}|Sort -Descending|Select -First 1;$Length2,$Length|Sort -Descending|Select -First 1}else{$Selections|%{$_.length}|Sort -Descending|Select -First 1}
    $Buffer = if(($Width*1.5) -gt 78){[math]::floor((78-$width)/2)}else{[math]::floor($width/4)}
    if($Buffer -gt 6){$Buffer = 6}
    $MaxWidth = $Buffer*2+$Width+$($Selections.count).length+2
    $Menu = @()
    $Menu += "╔"+"═"*$maxwidth+"╗"
    if($Title){
        $Menu += "║"+" "*[Math]::Floor(($maxwidth-$title.Length)/2)+$Title+" "*[Math]::Ceiling(($maxwidth-$title.Length)/2)+"║"
        $Menu += "╟"+"─"*$maxwidth+"╢"
    }
    For($i=1;$i -le $Selections.count;$i++){
        $Item = "$(if ($Selections.count -gt 9 -and $i -lt 10){" "})$i`. "
        $Menu += "║"+" "*$Buffer+$Item+$Selections[$i-1]+" "*($MaxWidth-$Buffer-$Item.Length-$Selections[$i-1].Length)+"║"
    }
    If($IncludeExit){
        $Menu += "║"+" "*$MaxWidth+"║"
        $Menu += "║"+" "*$Buffer+"X - Exit"+" "*($MaxWidth-$Buffer-8)+"║"
    }
    $Menu += "╚"+"═"*$maxwidth+"╝"
    $menu
}

function WorkSpace ($Directory) {
    $Base_Folder = $Directory + "\WorkSpace"
    
    if (!(Test-Path -Path $Base_Folder)) {

        try {
            New-Item -Path $Directory -Name "WorkSpace" -ItemType Directory -ErrorAction Stop | Out-Null     
            Write-Host -ForegroundColor White "`n[*] Work Space as been Created at: " -NoNewline; Write-Host -BackgroundColor Red "$Base_Folder"
        } 
       
        catch {
            Write-Error -Message "`n[-] Unable To create: $Base_Folder`n[!] Error Was: $_ "
                 
        }
    } 
    else {
        Write-Host -ForegroundColor White "`n[!] " -NoNewline;Write-Host -BackgroundColor Magenta "Work Space For wordlist-Maker AllReady Exist"
        
    }
    $WorkSpace = Get-Item $Base_Folder 
    return $WorkSpace
    
}

function File-Selection ($Directory){
    $filelist = Get-ChildItem -Path $Directory  -Filter *.txt -Recurse | %{$_.FullName}
    $file_num = 0
    Write-Host "[!] " -NoNewline;Write-Host "All Files Are: `n" -ForegroundColor Magenta
    foreach ($file in $filelist) {
        $file_num ++;
        Write-Host $file_num': ' -NoNewline;Write-Host $file.Split("\\")[-1] -ForegroundColor Green 
    

    }
    Write-Host "`n[?] " -NoNewline;Write-Host "Select a file to perform operations (1-$file_num): "-ForegroundColor Cyan -NoNewline;$File_Selection = Read-Host
    $File_Selection = $filelist[($File_Selection - 1)]
    return $File_Selection
}

function Check-FileSize ($directory) {
    $fileList = Get-ChildItem -Path $directory\* -Include *.txt  -File

    foreach ($file in $filelist) {    
        If ((Get-Item $file).length -gt 1gb) {
            Write-Host -ForegroundColor White "`n[!] " -NoNewline;Write-Host -ForegroundColor Red ("The File {0} need to Split" -f $file.Name) 
            $choise = Read-Host -Prompt ("[?] Are you want to spilt The file {0}? (Y/n)" -f $file.Name)

            if ($choise -eq "Y".ToLower()) {

                Write-Host -ForegroundColor White "`n[!] " -NoNewline;Write-Host -BackgroundColor Red ("The File {0} Will be deleted at the end of the spliting process..." -f $file.Name)
                Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -BackgroundColor Magenta ("Spliting By size will breake some lines but fast")
                Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -BackgroundColor Magenta ("Spliting By line will take some time to run")
                $split_method = Read-Host -Prompt ("[?] Split The File $file By Size Or Line (S/L)")
                if ($split_method-eq "S".ToLower()){
                        Split-By-Size -file2split $file
                }
                if ($split_method -eq "L".ToLower()) {
                    Split-By-Line -file2split $file
                }
                else {
                    Write-Host -ForegroundColor White "`n[!] " -NoNewline;Write-Host -BackgroundColor Red ("Not a vaild Option")
                    Write-Host -ForegroundColor White "[!] " -NoNewline;Write-Host -BackgroundColor Red ("Exiting...")
                    break
                }

            }

            if ($choise -eq "n") {

                Write-Host -ForegroundColor White "`n[!] " -NoNewline;Write-Host -ForegroundColor Red "Exiting..."
                Write-Host -ForegroundColor White "[!] " -NoNewline;Write-Host -ForegroundColor Red "Bye Bye..." ;exit           

            }
    
        }
    }
}

function Split-By-Size ($file2split) {
    
    Write-Host "[+] " -NoNewline;Write-Host "Starting Split File By Size" -ForegroundColor Green
    $sw = [System.Diagnostics.Stopwatch]::StartNew();
    $from =  Get-Item $file2split
    $rootName =  join-path $file2split.DirectoryName  $file2split.BaseName
    $ext = "txt"
    $upperBound = 1024MB

    Write-Host -ForegroundColor White "`n[!] " -NoNewline;Write-Host -BackgroundColor Magenta "Spliting it to Chunks of 1024MB..."
    $fromFile = [io.file]::OpenRead($file2split)
    $buff = new-object byte[] $upperBound
    $count = $idx = 1
    
    
    try {
        do {
            
            $count = $fromFile.Read($buff, 0, $buff.Length)
            if ($count -gt 0) {
                $to = "{0}-{1}.{2}" -f ($rootName, $idx, $ext)
                $toFile = [io.file]::OpenWrite($to)
                try {
                    Write-Host -ForegroundColor White "[+] " -NoNewline;Write-Host -ForegroundColor DarkCyan ("Writing Chunk of {0}MB to $to" -f ($count/1mb).ToString(".00"))
                    $tofile.Write($buff, 0, $count)
                } finally {
                    $tofile.Close()
                }
            }
            $idx ++
        } while ($count -gt 0)
    }
    finally {
        $fromFile.Close()
    }

    $sw.Stop()
    Write-Host -ForegroundColor White "`n[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Spliting by Size completed in: {0}" -f $sw.Elapsed);
    Remove-Item $file2split

}

function Split-By-Line ($file2split) {
    
     Write-Host "[+] " -NoNewline;Write-Host "Starting Split File By Line" -ForegroundColor Green
    $sw = [System.Diagnostics.Stopwatch]::StartNew();
    $SourceFileName = Get-Item $file2split #Source File Name
    $rootName =  join-path $SourceFileName.DirectoryName  $SourceFileName.BaseName
    $ext = $SourceFileName.Extension 
    
    $linesperFile = 35000000 #Number of Line Records

    $filecount = 1
    $reader = $null
    if (Test-Path $file2split) {

        try {
            $reader = [io.file]::OpenText($file2split)
            Write-Host -ForegroundColor White "[!] Spliting The File: " -NoNewline;Write-Host -ForegroundColor Red ("$SourceFileName")
            try {
                $to = "{0}-{1}{2}" -f ($rootName, $filecount, $ext)
                Write-Host -ForegroundColor White "`n[+] Writing $linesperFile Lines To: " -NoNewline;Write-Host -ForegroundColor DarkCyan ("$to")
                $writer = [io.file]::CreateText($to)
                $filecount++
                $linecount = 0

                while($reader.EndOfStream -ne $true) {

                    
                    while( ($linecount -lt $linesperFile) -and ($reader.EndOfStream -ne $true)) {
                    $writer.WriteLine($reader.ReadLine());
                    $linecount++

                    }

                    if($reader.EndOfStream -ne $true) {

                    
                    $writer.Dispose();
                    $to = "{0}-{1}{2}" -f ($rootName, $filecount, $ext)
                    Write-Host -ForegroundColor White "[+] " -NoNewline;Write-Host -ForegroundColor DarkCyan ("Writing $linesperFile Lines To: $to")
                    $writer = [io.file]::CreateText($to)
                    $filecount++
                    $linecount = 0

                    }
                }
            }
             
            finally {

                $writer.Dispose();
            }
        }
         
        finally {

            $reader.Dispose();
        }

    }

    else {

        Write-Host "No File Found to Process " $filename 
    }

    $sw.Stop()
    Write-Host "Split File By Line completed in: " $sw.Elapsed
    Remove-Item $file2split

}

function WordLists-Merger ($directory) {
    
    
    Write-Host "[+] " -NoNewline;Write-Host "Starting To merge all files" -ForegroundColor Green
    $dir_name = Split-Path $directory -Leaf
    $outFile = Join-Path $Global:WorkSpace ("{0}_Merged.txt" -f $dir_name);
    $fileList = Get-ChildItem -Path $directory\* -Include *.txt  -File  
    $Writer = New-Object System.IO.StreamWriter $outFile 
    $sw = [System.Diagnostics.Stopwatch]::StartNew();
    $totalItems = $fileList.Length
    $cfile = 0

    foreach ($file in $filelist) {
        
        $corrent_file = (Get-Item $file).BaseName.ToString() + (Get-Item $file).Extension.ToString()
        Write-Progress -Activity "$cfile / $totalItems " -status "Now Adding: $corrent_file "   -percentComplete ($cfile / $totalItems * 100)
        #Write-Host -ForegroundColor White "[+] " -NoNewline;Write-Host -ForegroundColor Magenta "Now Adding $corrent_file "
        $reader = New-Object System.IO.StreamReader($file)
        $content = $reader.ReadToEnd()
        $Writer.Write($content)
        $cfile ++
    }
    Write-Progress -Activity "$cfile / $totalItems " -status "Now Adding: $corrent_file "   -percentComplete ($cfile / $totalItems * 100) -Completed 
    $Reader.close()
    $Writer.Close()
    $reader.Dispose()
    $Writer.Dispose()
    $sw.Stop();
    Write-Host -ForegroundColor White "`n[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Merging All files completed in: {0}" -f $sw.Elapsed);
    return $outFile
}

function Word-Filter($Input_File) {
    
    Write-Host "`n[+] " -NoNewline;Write-Host "Starting To Filter Words" -ForegroundColor Green     
    $sw = [System.Diagnostics.Stopwatch]::StartNew();   
    $total_lines = 0
    Write-Host "`n[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Getting Total Lines Number..." );
    if ($Input_File) {
    $reader = New-Object IO.StreamReader $Input_File
        if ($reader) {
            while(-not ($reader.EndOfStream)) { [void]$reader.ReadLine(); $total_lines++ }
            $reader.Close()
        }
    }

    $Source = Get-Item $Input_File
    $reader = New-Object IO.StreamReader $Input_File
    $root_dir =  $Source.Directory.FullName
    $Outfile = Join-Path $Global:WorkSpace ("{0}_Filterd.txt" -f $Source.Directory.Name);
    $Writer = New-Object System.IO.StreamWriter $outFile
    $nonASCII = "[^\x00-\x7F]"
    $word = 0
    $current_line = 0
    
    while(-not ($reader.EndOfStream)) {
            
        $line = $reader.ReadLine();
        $current_line ++

        if ($line.Length -lt 4 -or $line -cmatch $nonASCII -or $line -eq "" -or $line.Length -gt 65 ) {

            Write-Progress -Activity "Filtered words: $word / $total_lines" -status "Filtering The Word: $line" -percentComplete ($current_line / $total_lines * 100)
            $word ++               
            $Global:Total_Words ++
        }

        else {
                
            $Writer.WriteLine($line);           
        }
    }

    Write-Progress -Activity "Filtered words: $word / $total_lines" -status "Filtering The Word: $line" -percentComplete ($current_line / $total_lines * 100) -Completed               
    $Reader.close()
    $Writer.Close()
    $reader.Dispose()
    $Writer.Dispose()
    $sw.stop();
    Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Removed Total Words of: ${word}" );
    Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Yellow "Filtering All Words completed in: " $sw.Elapsed;
    [GC]::Collect()
    return $Outfile



}

function Sort-Dedup ($Input_File) {
    Write-Host "`n[+] " -NoNewline;Write-Host "Starting Remove Duplicates and Sorting" -ForegroundColor Green
    If ((Get-Item $Input_File).length -gt 1gb) {
        Write-Host "`n[!] " -NoNewline; Write-Warning -Message "in case of large files it Can Killed duo System.OutOfMemoryException"
        Write-Host "[*] " -NoNewline;pause
    }
    Write-Host "`n[*] " -NoNewline;Write-Host "Getting Total Lines count.." -ForegroundColor Yellow
    $total_lines = 0 
    if ($Input_File) {
    $reader = New-Object IO.StreamReader $Input_File
        if ($reader) {
            while(-not ($reader.EndOfStream)) { [void]$reader.ReadLine(); $total_lines++ }
            $reader.Close()
        }
    }


    
    $hs = new-object System.Collections.Generic.HashSet[string]
    $sw = [System.Diagnostics.Stopwatch]::StartNew();
    $reader = New-Object IO.StreamReader $Input_File

    try {

        while (($line = $reader.ReadLine()) -ne $null) {
            $t = $hs.Add($line)
        }
    }
    finally {

        $reader.Close()
    }

    $sw.Stop();
    Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Removing Duplicate completed in: {0}" -f $sw.Elapsed);

    $sw = [System.Diagnostics.Stopwatch]::StartNew();
    $ls = new-object system.collections.generic.List[string] $hs;
    
    Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Total Of Duplicates Passwrods that Removed is: {0} " -f ($total_lines - $hs.Count));
    $Global:Total_Duplicate = ($total_lines - $hs.Count)
    $ls.Sort();
    $sw.Stop();
    Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Sorting All Lines completed in: {0}" -f $sw.Elapsed);
    $source = Get-Item $Input_File
    $root_dir =  $source.Directory.FullName
    $sorted_file = Join-Path $Global:WorkSpace ("{0}_MSD.txt" -f $source.Directory.Name);

    $sw = [System.Diagnostics.Stopwatch]::StartNew();
    try {

        $f = New-Object System.IO.StreamWriter $sorted_file;
        foreach ($s in $ls) {
            $f.WriteLine($s);
            
        }
    }

    finally {

        $f.Close();
    }

    $sw.Stop();
    

    
    Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Yellow ("Writing Sorted File to disk completed in: {0}" -f $sw.Elapsed);
    Write-Host -ForegroundColor White "`n[+] " -NoNewline;Write-Host -ForegroundColor Green "New MSD file saved to:"
    Get-Item $sorted_file
    return $sorted_file

}

Banner
Write-Host -ForegroundColor White "`n[?] " -NoNewline; Write-Host -ForegroundColor Cyan "Enter Path to a Folder That Contains Wordlists: " -NoNewline;$Directory = Read-Host
 
if ($Directory -eq $null -or $Directory -eq "" -or (!(Test-Path $Directory))) {
        
        Write-Host -ForegroundColor White "`n[!] " -NoNewline; Write-Host -ForegroundColor Red "Couldent Find The Spesific Folder..."
        Write-Host -ForegroundColor White "[*] " -NoNewline;pause
        Write-Host -ForegroundColor White "[!] " -NoNewline; Write-Host -ForegroundColor Red "Exiting Bye Bye..."
        break

}

$Global:Total_Words = 0
$Global:Total_Duplicate = 0
$Global:WorkSpace = WorkSpace -Directory $Directory
Write-Host -ForegroundColor White "`n[*] " -NoNewline;pause
Set-Location $Directory

do {
     clear-host
     MenuMaker -Selections "Merge all Files In directory","Filter Words From Wordlist","Sort and remove duplicates","All" -Title "WordList Maker" -IncludeExit
     $selection = Read-Host "`n[?] Please make a selection"
     switch ($selection) {
        
         '1' {

            #Merge all Files In Directroy
            Clear-Host
            $split_time = [System.Diagnostics.Stopwatch]::StartNew();
            Check-FileSize -directory $Directory
            $split_time.stop();
            

            $merge_time = [System.Diagnostics.Stopwatch]::StartNew();
            $merge_file = WordLists-Merger -directory $Directory
            $merge_time.stop();
            
            
            Write-Host -ForegroundColor White "`n[$] " -NoNewline;Write-Host -ForegroundColor Magenta ("------------- RunTime Statistic For Wordliat Maker -------------`n");
            if ($split_time.Elapsed.TotalSeconds  -lt 1) {Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Spliting Run Time is: No Spliting was needed ");}
            else {Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Cyan ("Spliting RunTime is: {0}" -f $split_time.Elapsed );}
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Merging RunTime is: {0}" -f $merge_time.Elapsed );
            Write-Host -ForegroundColor White "`n[*] " -NoNewline;pause
            [GC]::Collect()
            }

         '2' {
            #Filter Words From Wordlist
            Clear-Host
            if ($merge_file -eq $null -or $merge_file -eq "" -or (!(Test-Path $merge_file))){
                $merge_file = File-Selection $Directory
            
            }
            
            $filter_time = [System.Diagnostics.Stopwatch]::StartNew();
            $filtered_file = Word-Filter -Input_File $merge_file
            $filter_time.stop();
            
            Write-Host -ForegroundColor White "`n[$] " -NoNewline;Write-Host -ForegroundColor Magenta ("------------- RunTime Statistic For Wordliat Maker -------------`n");
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Total filtered words are: {0}" -f $Global:Total_Words  );
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Filtering Words Completed in: {0}" -f $fiter_time.Elapsed );
            Write-Host -ForegroundColor White "`n[*] " -NoNewline;pause
            [GC]::Collect()
            }
         '3' {
            
            #Sort and remove duplicates
            Clear-Host
            if ($filtered_file -eq $null -or $filtered_file -eq "" -or (!(Test-Path $filtered_file))){
                $filtered_file = File-Selection -Directory $Directory
                $total_lines = 0
                
            }    
            $sort_time = [System.Diagnostics.Stopwatch]::StartNew();
            $sorted_file = Sort-Dedup -Input_File $filtered_file
            
            $sort_time.stop();
            Write-Host -ForegroundColor White "`n[$] " -NoNewline;Write-Host -ForegroundColor Magenta ("------------- RunTime Statistic For Wordliat Maker -------------`n");
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Total of Duplicates that removed: $Global:Total_Duplicate");
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Remove Duplicates and sort completed in: {0}" -f $sort_time.Elapsed );
            Write-Host -ForegroundColor White "`n[*] " -NoNewline;pause
            [GC]::Collect()

            }
         '4' {
            #All Option
            Clear-Host
            $total_time = [System.Diagnostics.Stopwatch]::StartNew();
            $split_time = [System.Diagnostics.Stopwatch]::StartNew();
            Check-FileSize -directory $Directory
            $split_time.stop();
            [GC]::Collect()

            $merge_time = [System.Diagnostics.Stopwatch]::StartNew();
            $merge_file = WordLists-Merger -directory $Directory
            $merge_time.stop();
            [GC]::Collect()

            $filter_time = [System.Diagnostics.Stopwatch]::StartNew();
            $filtered_file = Word-Filter -Input_File $merge_file
            
            $filter_time.stop();
            [GC]::Collect()
            
            
            $sort_time = [System.Diagnostics.Stopwatch]::StartNew();
            Sort-Dedup -Input_File $filtered_file
            $sort_time.stop();
            $total_time.stop();
            [GC]::Collect()

            Write-Host -ForegroundColor White "`n[$] " -NoNewline;Write-Host -ForegroundColor Magenta ("------------- RunTime Statistic For Wordliat Maker -------------`n");
            if ($split_time.Elapsed.TotalSeconds  -lt 1) {Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Spliting Run Time is: No Spliting was needed ");}
            else {Write-Host -ForegroundColor White "[*] " -NoNewline;Write-Host -ForegroundColor Cyan ("Spliting RunTime is: {0}" -f $split_time.Elapsed );}
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Merging RunTime is: {0}" -f $merge_time.Elapsed );
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Total filtered words are: {0}" -f $Global:Total_Words  );
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Filtering Words Completed in: {0}" -f $filter_time.Elapsed );
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Total of Duplicates that removed: $Global:Total_Duplicate");
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Remove Duplicates and sort completed in: {0}" -f $sort_time.Elapsed );
            Write-Host -ForegroundColor White "[#] " -NoNewline;Write-Host -ForegroundColor Cyan ("Wordlist maker completed in: {0}" -f $total_time.Elapsed );
            Write-Host -ForegroundColor White "`n[*] " -NoNewline;pause
            }

     }    
 }
 until ($selection -eq 'x')


}
Invoke-WordlistMaker
