@echo off
echo ========================================
echo Installing and Configuring OpenSSH Server
echo ========================================

REM Install OpenSSH Server
powershell -Command "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"

REM Start SSH service
powershell -Command "Start-Service sshd"

REM Set SSH to start automatically
powershell -Command "Set-Service -Name sshd -StartupType 'Automatic'"

REM Configure firewall rule for SSH
powershell -Command "New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction SilentlyContinue"

REM Set PowerShell as default shell for SSH
powershell -Command "New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force"

echo ========================================
echo OpenSSH Server installation completed!
echo ========================================
