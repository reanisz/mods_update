#Requires -Version 4

Start-Transcript "mods_update.log"

# 以前からあったバックアップ消してから
# 現用中のディレクトリをバックアップとしてリネームするやつ
function Create-BackUp([string]$path){
    $sourcePath = Convert-Path $path
    if(!(Test-Path $sourcePath)){
        echo "INFO: $sourcePath is not exist."
        return
    }

    $parentDir = Split-Path $sourcePath -Parent
    $destinationName = (Split-Path $sourcePath -Leaf) + ".bak"
    $destinationPath = Join-Path $parentDir $destinationName

    if(Test-Path $destinationPath){
        rm $destinationPath -Recurse -Force
    }

    Rename-Item $sourcePath $destinationName -ErrorAction Stop
}

# PS5のExpand-Archiveが役に立たなかったので
# System.IO.Compression.ZipFileつかってZIP解凍するやつ
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Extract-Zip([string]$zipFilePath, [string]$destinationPath = "."){

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $destinationPath)
}


$InfoUrl = "http://reanisz.site44.com/minecraft/dragonscraft"
$lastInfo = wget "${InfoUrl}/info.json" | ConvertFrom-Json

$Version = $lastInfo.version
$ModsPath = "mods_v${VERSION}.zip"
$ConfigPath = "config_v$VERSION.zip"
$ModsUrl = ([string]$lastInfo.mods_url.client).Replace("dl=0", "dl=1")
$ConfigUrl = ([string]$lastInfo.config_url).Replace("dl=0", "dl=1")

if(!(Test-Path $ModsPath)){
    wget $ModsUrl -OutFile $ModsPath -TimeoutSec (5*60)
}else{
    echo "INFO: $ModsPath is already exists."
}

if(!(Test-Path $ConfigPath)){
    wget $ConfigUrl -OutFile $ConfigPath -TimeoutSec (5*60)
}else{
    echo "INFO: $ConfigPath is already exists."
}

Create-BackUp "mods"
Create-BackUp "config"


Extract-Zip $ModsPath
Extract-Zip $ConfigPath

$lastInfo | ConvertTo-Json | Out-File "info_v$VERSION.json" -Encoding utf8

