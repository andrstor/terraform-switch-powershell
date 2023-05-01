# tfswitch-powershell

The ``terraform-switch.ps1`` script allows Windows users to easily switch between different versions of Terraform. It checks if the desired Terraform version is installed, and if not, it downloads and installs it.

To use the script, simply run ``terraform-switch.bat`` in a PowerShell window. The script will prompt you to select a version or install the latest stable if no version is previously installed.

Tip: To make the script easily accessible from any directory, add the directory containing the script to your system's PATH environment variable.