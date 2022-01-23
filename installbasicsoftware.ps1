$chromeURLPrefix = "https://dl.google.com/chrome/install/"
$arWeb = Invoke-WebRequest -Uri 'https://get.adobe.com/reader/' -UseBasicParsing
$arVersion = [regex]::match($arWeb.Content,'Version ([\d\.]+)').Groups[1].Value.Substring(2).replace('.','')
$vlcWeb = Invoke-WebRequest -Uri "https://www.videolan.org/vlc/download-windows.html" -UseBasicParsing
$vlcVersion = [regex]::match($vlcWeb.Content,'\d\.\d\.\d\d').Value.Trim()
$zoomWeb = Invoke-WebRequest "https://zoom.us/download" -UseBasicParsing
$zoomVersion = [regex]::match($zoomWeb.Content,'\d\.\d\.\d\s\(\d\d\d\d\)').Value.Trim().replace('(','.').replace(')','').replace(' ', '')
$7zWeb = Invoke-WebRequest "https://www.7-zip.org/download.html" -UseBasicParsing
$7zVersion = [regex]::match($7zWeb.Content,'\d\d.\d\d').value.replace(".","")
$arURLPrefix = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/$arVersion/"
$7zipURLPrefix = "https://www.7-zip.org/a/"
$vlcURLPrefix = "https://get.videolan.org/vlc/" + $vlcVersion + "/win32/"
$zoomURLPrefix = "https://cdn.zoom.us/prod/" + $zoomVersion + "/"
$javaURLPrefix = "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/"
function DownloadInstall($fileName, $URI, $Arguments){
    $WebClient = New-Object System.Net.WebClient
    Write-Host -ForegroundColor yellow "Downloading $fileName"
    $WebClient.DownloadFile($URI, $fileName)
    $fileExtension = [System.IO.Path]::GetExtension($fileName)
    if($fileExtension -eq ".msi"){
        $InstallProcess = (Start-Process msiexec.exe -ArgumentList $Arguments -PassThru -Wait)
        if($InstallProcess.ExitCode -ne 0){
            Write-Error "$fileName Installation Failed! `n Error Code: $InstallProcess.ExitCode"
            exit $InstallProcess.ExitCode
        }
        else {
            Write-Host -ForegroundColor green "$fileName Installed Successfully!"
        }
    }
    if($fileExtension -eq ".exe"){
        $InstallProcess = (Start-Process $fileName -ArgumentList $Arguments -PassThru -Wait)
        if($InstallProcess.ExitCode -ne 0){
            Write-Error "$fileName Installation Failed! `n Error Code: $InstallProcess.ExitCode"
            exit $InstallProcess.ExitCode
        }
        else {
            Write-Host -ForegroundColor green "$fileName Installed Successfully!"
        }
    }
}

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$chromeFileName = "googlechromestandaloneenterprise.msi"
$arFileName = "AcroRdrDC" + $arVersion + "_en_US.exe"
$7zipFileName = "7z" + $7zVersion + ".msi"
$vlcFileName = "vlc-" + $vlcVersion + "-win32.msi"
$zoomFileName = "ZoomInstallerFull.msi"
$javaFileName = "OpenJDK11U-jre_x86-32_windows_hotspot_11.0.11_9.msi"

if([Environment]::Is64BitOperatingSystem){
    $vlcURLPrefix = "https://get.videolan.org/vlc/" + $vlcVersion + "/win64/"
    $zoomURLPrefix = "https://cdn.zoom.us/prod/" + $zoomVersion + "/x64/"
    $chromeFileName = "googlechromestandaloneenterprise64.msi"
    $arFileName = "AcroRdrDC" + $arVersion + "_en_US.exe"
    $7zipFileName = "7z" + $7zVersion +"-x64.msi"
    $vlcFileName = "vlc-" + $vlcVersion + "-win64.msi"
    $zoomFileName = "ZoomInstallerFull.msi"
    $javaFileName = "OpenJDK11U-jre_x64_windows_hotspot_11.0.11_9.msi"
}

$chromeURI = $chromeURLPrefix + $chromeFileName
$arURI = $arURLPrefix + $arFileName
$7zipURI = $7zipURLPrefix + $7zipFileName
$vlcURI = $vlcURLPrefix + $vlcFileName
$zoomURI = $zoomURLPrefix + $zoomFileName
$javaURI = $javaURLPrefix + $javaFileName

$chromeArguments = "/i `"$chromeFileName`" /qn"
$arArguments = "/msi EULA_ACCEPT=YES /qn"
$7zipArguments = "/i `"$7zipFileName`" /qn"
$vlcArguments = "/i `"$vlcFileName`" /qn"
$zoomArguments = "/i `"$zoomFileName`" /qn"
$javaArguments = "/i `"$javaFileName`" /qn"

DownloadInstall $chromeFileName $chromeURI $chromeArguments
DownloadInstall $arFileName $arURI $arArguments
DownloadInstall $7zipFileName $7zipURI $7zipArguments
DownloadInstall $vlcFileName $vlcURI $vlcArguments
DownloadInstall $zoomFileName $zoomURI $zoomArguments
DownloadInstall $javaFileName $javaURI $javaArguments