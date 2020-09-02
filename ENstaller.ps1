Write-Host -ForegroundColor Yellow "You are about to install ENIGMA, the FOSS alternative to YoYoGames' GameMaker."
Write-Host -ForegroundColor Yellow "Do you wish to continue? Everything beyond will be completely automatic."
Write-Host
Write-Host -ForegroundColor Yellow "ENIGMA will take up around 2GB of space to install, and will take about 20-50 minutes."
Write-Host
Write-Host -ForegroundColor DarkGray "(close window to cancel, press any key to continue)"
Pause

$MSYS_DIST="http://repo.msys2.org/distrib/x86_64/msys2-base-x86_64-20200720.tar.xz"
$OJDK_DIST="https://developers.redhat.com/download-manager/file/java-1.8.0-openjdk-jre-1.8.0.265-3.b01.redhat.windows.x86_64.zip"
$ProgressPreference = 'SilentlyContinue'
[Console]::CursorVisible=0
Set-Location (Split-Path $MyInvocation.MyCommand.Path)

function curpos([int]$x, [int] $y) {
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x , $y
} 

Clear-Host

Write-Host "ENIGMA Setup will now perform the following actions:`n" -ForegroundColor Yellow
Write-Host " ☐  Download MSYS2" -ForegroundColor DarkGray
Write-Host " ☐  Extract MSYS2" -ForegroundColor DarkGray
Write-Host " ☐  Install MSYS2" -ForegroundColor DarkGray
Write-Host " ☐  Install ENIGMA's required packages" -ForegroundColor DarkGray
Write-Host " ☐  Download ENIGMA's source code" -ForegroundColor DarkGray
Write-Host " ☐  Compile ENIGMA" -ForegroundColor DarkGray
Write-Host " ☐  Download and configure OpenJDK 8 and LateralGM" -ForegroundColor DarkGray
Write-Host " ☐  Create shortcuts" -ForegroundColor DarkGray

curpos 0 2
Write-Host " → Download MSYS2 (~75MB)" -ForegroundColor Cyan

Invoke-WebRequest $MSYS_DIST -OutFile msys2.tar.xz

curpos 0 2
Write-Host " ☑  Download MSYS2        " -ForegroundColor DarkGreen

curpos 0 3
Write-Host " → Extract MSYS2" -ForegroundColor Cyan

$MSYS2DIR="${env:APPDATA}\ENIGMA"
if (Test-Path $MSYS2DIR) {
    Remove-Item $MSYS2DIR -Recurse -Force
}

.\resources\7za.exe x .\msys2.tar.xz -o"${MSYS2DIR}"      > $null
Remove-Item "msys2.tar.xz"
.\resources\7za.exe x "${MSYS2DIR}\*.tar" -o"${MSYS2DIR}" > $null
Remove-Item "${MSYS2DIR}\*.tar"
Move-Item "${MSYS2DIR}\msys64\*" "${MSYS2DIR}\"
Remove-Item "${MSYS2DIR}\msys64"

curpos 0 3
Write-Host " ☑  Extract MSYS2" -ForegroundColor DarkGreen

curpos 0 4
Write-Host " → Install MSYS2" -ForegroundColor Cyan

$MSYS2="${MSYS2DIR}\usr\bin\bash.exe"

Start-Process -Wait $MSYS2 "-lc `"yes \`"
\`" | pacman -Syu`""

Start-Process -Wait $MSYS2 "-lc `"yes \`"
\`" | pacman -Su`""

curpos 0 4
Write-Host " ☑  Install MSYS2" -ForegroundColor DarkGreen

curpos 0 5
Write-Host " → Install ENIGMA's required packages" -ForegroundColor Cyan

Start-Process -Wait $MSYS2 "-lc `"yes \`"
\`" | pacman -Sy git make mingw-w64-x86_64-gcc mingw-w64-x86_64-boost mingw-w64-x86_64-protobuf mingw-w64-x86_64-libpng mingw-w64-x86_64-rapidjson mingw-w64-x86_64-pugixml mingw-w64-x86_64-yaml-cpp mingw-w64-x86_64-openal mingw-w64-x86_64-dumb mingw-w64-x86_64-libvorbis mingw-w64-x86_64-libogg mingw-w64-x86_64-flac mingw-w64-x86_64-mpg123 mingw-w64-x86_64-libsndfile mingw-w64-x86_64-zlib mingw-w64-x86_64-libffi mingw-w64-x86_64-box2d mingw-w64-x86_64-glew mingw-w64-x86_64-glm mingw-w64-x86_64-alure mingw-w64-x86_64-grpc mingw-w64-x86_64-SDL2 mingw-w64-x86_64-pkg-config mingw-w64-x86_64-libgme mingw-w64-x86_64-sfml mingw-w64-x86_64-bullet mingw-w64-x86_64-gtk2 mingw-w64-x86_64-fluidsynth mingw-w64-x86_64-portaudio`""

curpos 0 5
Write-Host " ☑  Install ENIGMA's required packages" -ForegroundColor DarkGreen

curpos 0 6
Write-Host " → Download ENIGMA's source code" -ForegroundColor Cyan

Start-Process -Wait $MSYS2 "-lc `"git clone https://github.com/enigma-dev/enigma-dev.git`""

curpos 0 6
Write-Host " ☑  Download ENIGMA's source code" -ForegroundColor DarkGreen

curpos 0 7 
Write-Host " → Compile ENIGMA" -ForegroundColor Cyan

&"${MSYS2DIR}\msys2_shell.cmd" -no-start -mingw64 -c "cd enigma-dev; make"

curpos 0 7
Write-Host " ☑  Compile ENIGMA" -ForegroundColor DarkGreen

curpos 0 8
Write-Host " → Download and configure OpenJDK 8 and LateralGM" -ForegroundColor Cyan

Invoke-WebRequest $OJDK_DIST -OutFile openjdk.zip
.\resources\7za.exe x -o"${MSYS2DIR}\openjdk" openjdk.zip
Remove-Item openjdk.zip
Start-Process -Wait $MSYS2 "-lc `"cd enigma-dev; ./install.sh`""

curpos 0 8
Write-Host " ☑  Download and configure OpenJDK 8 and LateralGM" -ForegroundColor DarkGreen

curpos 0 9
Write-Host " → Create shortcuts" -ForegroundColor Cyan

$MSYSHOME="${MSYS2DIR}\home\"+(&$MSYS2 -lc 'whoami')

Copy-Item .\resources\start_lateral.sh "${MSYSHOME}\enigma-dev\"
Copy-Item .\resources\start_lateral.bat "${MSYSHOME}\enigma-dev\"
Copy-Item .\resources\lgm-logo.ico "${MSYSHOME}\enigma-dev\"

$TargetFile = "${MSYSHOME}\enigma-dev\start_lateral.bat"
$ShortcutIcon = "${MSYSHOME}\enigma-dev\lgm-logo.ico"
$ShortcutFile = "$env:USERPROFILE\Desktop\LateralGM + Enigma.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.IconLocation = $ShortcutIcon
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

$TargetFile = "${MSYS2DIR}\mingw64.exe"
$ShortcutFile = "$env:USERPROFILE\Desktop\MSYS2 (Enigma Console).lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

curpos 0 9
Write-Host " ☑  Create shortcuts" -ForegroundColor DarkGreen

Clear-Host
Write-Host "There are now two shortcuts on your desktop for ENIGMA."
Write-Host "1. LateralGM + Enigma -- The main Enigma GUI, LateralGM."
Write-Host "2. MSYS2 (Enigma Console) -- Open a console to manage the MSYS2 installation used to run Enigma."
Pause

[Console]::CursorVisible=1