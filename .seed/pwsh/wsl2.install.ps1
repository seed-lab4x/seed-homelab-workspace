
wsl --install -d Debian

iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install wsl2 -y --force
