function Invoke-WordlistsFetch ($Directory){

    if (!($Directory)){

        $Directory = $PWD
    }
    
function WorkSpace ($Directory) {
    $Base_Folder = $Directory + "\Wordlists"
    
    if (!(Test-Path -Path $Base_Folder)) {

        try {
            New-Item -Path $Directory -Name "Wordlists" -ItemType Directory -ErrorAction Stop | Out-Null     
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

    function Get-UrlStatusCode([string] $Url) {
        try {(Invoke-WebRequest -Uri $Url -UseBasicParsing -DisableKeepAlive).StatusCode}
        catch [Net.WebException]
        {[int]$_.Exception.Response.StatusCode}
    }



    function HashKiller-Wordlist($Path) {
        
        $base_Folder = "$Path\HashKiller"
        $Found_leaks = "$base_Folder\HashKiller_Leaks"
        $Passwords_Folder = "$base_Folder\HashKiller_Wordlist"

        New-Item -Path $base_Folder -ItemType Directory
        New-Item -Path $Found_leaks -ItemType Directory
        New-Item -Path $Passwords_Folder -ItemType Directory

        $Utf8NoBomEncoding = [System.Text.Encoding]::GetEncoding(65001)
        $outFile = "$Passwords_Folder\HashKiller-Wordlist.txt"
        
        
        
        $HashKiller_Leaks = "https://hashkiller.io/leaks"
        $HashKiller = $HashKiller_Leaks.substring(0,22)
        $LinkList =  (Invoke-WebRequest -Uri $HashKiller_Leaks).links.href;
        foreach ($Link in $LinkList){
    
            if ($Link -cmatch "found_leaks"){

                $pass_file = $HashKiller + $Link
                Write-Host "`n[+] Downloading: $pass_file"
                Invoke-WebRequest -Uri $pass_file -OutFile ($Found_leaks + "\" + $pass_file.split("/")[-1])
                Write-Host ("[#] The File has been saved to: {0}" -f ($Found_leaks + "\" + $pass_file.split("/")[-1]))
            }
        }

        $filelist = Get-ChildItem -Path $Found_leaks -File *.txt  -Recurse | %{$_.FullName}
        $Writer = New-Object System.IO.StreamWriter ($outFile, $Utf8NoBomEncoding)
        foreach ($file in $filelist) {

            $reader = New-Object System.IO.StreamReader($file, $Utf8NoBomEncoding)
            Write-Host "`n[#] Now Reading The File: $file"
            while(-not ($reader.EndOfStream)) {
            
                $line = $reader.ReadLine();
                $passowrd = $line.Split(":")[-1]
                $Writer.WriteLine($passowrd)

            }


        
        }
        $reader.Close()
        $Writer.Close()
        $reader.Dispose()
        $Writer.Dispose()
        [GC]::Collect()
        
                
        
        Move-Item -Path $outFile -Destination $base_Folder
        Remove-Item $Found_leaks -Force  -Recurse -ErrorAction SilentlyContinue
        Remove-Item $Passwords_Folder -Force  -Recurse -ErrorAction SilentlyContinue 

    }

    function capsop-Wordlists ($Path) {
    
        $base_Folder = "$Path\capsop-Wordlists"
        if (!(Test-Path -Path $Base_Folder)) {

            try {
                New-Item -Path $base_Folder -Name "capsop-Wordlists" -ItemType Directory -ErrorAction Stop | Out-Null     
                Write-Host -ForegroundColor White "`n[*] Work Space as been Created at: " -NoNewline; Write-Host -BackgroundColor Red "$Base_Folder"
            } 
       
            catch {
                Write-Error -Message "`n[-] Unable To create: $Base_Folder`n[!] Error Was: $_ "
                 
            }
        } 
        else {
            Write-Host -ForegroundColor White "`n[!] " -NoNewline;Write-Host -BackgroundColor Magenta "Work Space For capsop-wordlist AllReady Exist"
        
        }

        

        $capsop = "https://wordlists.capsop.com/"
        $LinkList =  ((Invoke-WebRequest -Uri $capsop).links.href | Sort-Object -Unique)
        [System.Collections.ArrayList]$file2donwload = @()
        foreach ($link in $LinkList){
            if ($Link.EndsWith("/")){
                $capsop2 = $capsop + $link
                $NewLinks = ((Invoke-WebRequest -Uri $capsop2).links.href | Sort-Object -Unique)
                foreach ($n in $NewLinks){
                    if ($n.EndsWith(".txt")){
                        [void]$file2donwload.Add($n)
                    }
        
                }
            }
            if ($link.EndsWith(".txt")){
                [void]$file2donwload.Add($link)
            }

        }
        foreach ($file in $file2donwload){

            $lst = $capsop  + $file
            $dest = $base_Folder + "\" + $lst.Split("/")[-1]

            

            #If the file does not exist, create it.
            if (-not(Test-Path -Path $dest -PathType Leaf)) {
                $statusCode = Get-UrlStatusCode -Url $lst
                if (!($statusCode -eq 404)){

                    Write-Host "`n[+] Downloading: $lst"
                    
                    Invoke-WebRequest -URI $lst -OutFile $dest
                    Write-Host ("[#] The File has been saved to: {0}" -f ($base_Folder + "\" + $file))
                }
                else{write-host "[!] The Remote Server returned 404: $lst"} 
                 
             }
            
             else {
                 Write-Host "[!] The File: $dest already exists."
             }

            
        }

    }


    
    $workspace = WorkSpace -Directory $Directory
    HashKiller-Wordlist -Path $workspace
    capsop-Wordlists -Path $workspace
    


}