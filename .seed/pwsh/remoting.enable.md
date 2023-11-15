# remoting.enable

installation method

## method 1

Just run [remoting.enable.cmd](./remoting.enable.cmd) from `cmd`

```batch
cmd /c remoting.enable.cmd
```

## method 2

There is no workspace locally to install from url by `iex`,
ensure that you are using an administrative shell.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/seed-lab4x/seed-module-workspace/main/seed/pwsh/remoting.enable.ps1'))
```
