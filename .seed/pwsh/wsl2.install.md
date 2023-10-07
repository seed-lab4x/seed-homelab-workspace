# wsl2.install

installation method

## method 1

Just run [wsl2.install.cmd](./wsl2.install.cmd) from `cmd`

```batch
cmd /c wsl2.install.cmd
```

## method 2

There is no workspace locally to install from url by `iex`,
ensure that you are using an administrative shell.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/seed-lab4x/seed-module-workspace/main/seed/pwsh/wsl2.install.ps1'))
```
