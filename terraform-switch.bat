@echo off
powershell.exe -ExecutionPolicy Bypass -File "%~dp0\terraform-switch.ps1" %*

