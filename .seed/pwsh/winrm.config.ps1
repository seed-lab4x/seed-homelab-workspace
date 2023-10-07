
winrm quickconfig

Write-Host "----------------------"
Write-Host "Test connect 127.0.0.1"
winrs -r:http://127.0.0.1:5985/wsman echo Succeed winrs http connect 127.0.0.1
winrs -r:http://127.0.0.1:5986/wsman -ssl echo Succeed winrs https connect 127.0.0.1


Write-Host "----------------------"
Write-Host "Test connect use hostname"
$localhost = "localhost"
$hostname = Read-Host "Please enter your hostname[$($localhost)]"
$hostname = ($localhost,$hostname)[[bool]$hostname]
Write-Host "Test connect $hostname"
winrs -r:http://${hostname}:5985/wsman echo Succeed winrs http connect $hostname
winrs -r:http://${hostname}:5986/wsman -ssl echo Succeed winrs https connect $hostname


Write-Host "------------------------------------------------"
Write-Host "Test connect use hostname with username+password"
$usernow = $Env:UserName
$username = Read-Host "Please enter your username[$($usernow)]"
$username = ($usernow,$username)[[bool]$username]
$secure = Read-Host "Please enter your password" -AsSecureString
$password = [System.Net.NetworkCredential]::new("",$secure).Password
Write-Host "Test connect $hostname with username+password"
winrs -r:http://${hostname}:5985/wsman -u:$username -p:$password echo Succeed winrs http connect $hostname with username+password
winrs -r:http://${hostname}:5985/wsman -u:$username -p:$password -ssl echo Succeed winrs https connect $hostname with username+password
