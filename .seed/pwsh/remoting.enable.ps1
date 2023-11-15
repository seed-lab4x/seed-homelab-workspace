
Write-Host "Enable pwsh remote"
Enable-PSRemoting -Force

Write-Host "Set trusted all hosts"
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

Write-Host "----------------------"
Write-Host "Test connect 127.0.0.1"
$t1 = New-PSSession -ComputerName 127.0.0.1
if (-not($t1)) {
    Write-Error "failed"
    return 1
} else {
    Invoke-Command -ComputerName 127.0.0.1 -ScriptBlock { Write-Host "Succeed pwsh http connect 127.0.0.1" }
    Invoke-Command -ComputerName 127.0.0.1 -UseSSL -ScriptBlock { Write-Host "Succeed pwsh https connect 127.0.0.1" }
    Remove-PSSession $t1
}


Write-Host "-------------------------"
Write-Host "Test connect use hostname"
$localhost = "localhost"
$hostname = Read-Host "Please enter your hostname[$($localhost)]"
$hostname = ($localhost,$hostname)[[bool]$hostname]
Write-Host "Test connect $hostname"
$t2 = New-PSSession -ComputerName $hostname
if (-not($t2)) {
    Write-Error "failed"
    return 1
} else {
    Invoke-Command -ComputerName $hostname -ScriptBlock { Write-Host "Succeed pwsh http connect $Using:hostname" }
    Invoke-Command -ComputerName $hostname -UseSSL -ScriptBlock { Write-Host "Succeed pwsh https connect $Using:hostname" }
    Remove-PSSession $t2
}


Write-Host "------------------------------------------------"
Write-Host "Test connect use hostname with username+password"
$usernow = $Env:UserName
$username = Read-Host "Please enter your username[$($usernow)]"
$username = ($usernow,$username)[[bool]$username]
$secure = Read-Host "Please enter your password" -AsSecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $secure
$option = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
Write-Host "Test connect $hostname with username+password"
$t3 = New-PSSession -ComputerName "$hostname" -Credential $cred -SessionOption $option
if (-not($t3)) {
    Write-Error "failed"
    return 1
} else {
    Invoke-Command -ComputerName $hostname -ScriptBlock { Write-Host "Succeed pwsh http connect $Using:hostname with username+password" }
    Invoke-Command -ComputerName $hostname -UseSSL -ScriptBlock { Write-Host "Succeed pwsh https connect $Using:hostname with username+password" }
    Remove-PSSession $t3
}
