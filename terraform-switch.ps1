# Set the path to the Terraform installations directory
$installDir = "C:\Terraform"

# List the available Terraform versions
$versions = Get-ChildItem -Path $installDir -Directory | Select-Object -ExpandProperty Name

if ($versions.Count -eq 0) {
    Write-Host "No Terraform versions are currently installed in $installDir."
    
    # Download the latest stable Terraform version
    Write-Host "Downloading latest stable Terraform version"
    $latestVersion = Invoke-RestMethod "https://checkpoint-api.hashicorp.com/v1/check/terraform" | Select-Object -ExpandProperty current_version
    $response = Invoke-WebRequest "https://releases.hashicorp.com/terraform/$latestVersion/terraform_$($latestVersion)_windows_amd64.zip" -OutFile "terraform.zip"

    if (!$response -or ($response.StatusCode -eq "404")) {
        Write-Host "Terraform version $latestVersion does not exist. Please select a valid version."
        Exit 1
    }
    # Extract the downloaded zip file
    Write-Host "Extracting Terraform"
    Expand-Archive "terraform.zip" -DestinationPath "$installDir\$latestVersion"

    # Remove the downloaded zip file
    Write-Host "Cleaning up"
    Remove-Item "terraform.zip"

    # Set the PATH environment variable to include the latest Terraform version
    $env:Path = "$installDir\$latestVersion;" + ($env:Path -split ';' | Where-Object { $_ -notlike "*$installDir*" } | Select-Object -Unique)

    # Verify that the new Terraform version is installed
    Write-Host "Terraform version:"
    terraform version
}
else {
    # Prompt the user to select a version to use
    Write-Host "Available Terraform versions:"
    $versions | ForEach-Object { Write-Host $_ }
    $selectedVersion = Read-Host "Enter the version of Terraform you want to use"

    # Check that the selected version has the correct format
    $validVersion = $selectedVersion -match '^\d+\.\d+(\.\d+)?$'
    if (!$validVersion) {
        Write-Host "Invalid Terraform version number. Please enter a version number in the format 'x.y.z' or 'x.y'."
        Exit 1
    }

    # Check if the selected version is already installed
    if (Test-Path "$installDir\$selectedVersion") {
        Write-Host "Using Terraform version $selectedVersion"
    }
    else {
        # Download the specified Terraform version
        Write-Host "Downloading Terraform version $selectedVersion"
        $response = Invoke-WebRequest "https://releases.hashicorp.com/terraform/$selectedVersion/terraform_$($selectedVersion)_windows_amd64.zip" -OutFile "terraform.zip" -PassThru

        if (!$response -or ($response.StatusCode -eq "404")) {
            Write-Host "Terraform version $selectedVersion does not exist. Please select a valid version."
            Exit 1
        }
        # Extract the downloaded zip file
        Write-Host "Extracting Terraform"
        Expand-Archive "terraform.zip" -DestinationPath "$installDir\$selectedVersion"

        # Remove the downloaded zip file
        Write-Host "Cleaning up"
        Remove-Item "terraform.zip"

        # Verify that the new Terraform version is installed
        Write-Host "Terraform version $selectedVersion is now installed"
    }

    # Set the PATH environment variable to include the selected Terraform version
    $env:Path = "$installDir\$selectedVersion;" + ($env:Path -split ';' | Where-Object { $_ -notlike "*$installDir*" } | Select-Object -Unique)

    # Verify that the correct Terraform version is being used
    Write-Host "Terraform version:"
    terraform version

    # Persist changes to PATH environment variable across PowerShell sessions
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $newPath = "$installDir\$selectedVersion"

    # Remove existing Terraform paths from the PATH environment variable
    $currentPath = $currentPath -split ';' | Where-Object { ($_ -notlike "*$installDir*") -or ($_ -eq $newPath) }
    $currentPath = $currentPath -join ';'

    # Add the new Terraform path to the PATH environment variable
    $newPathVariable = "$currentPath;$newPath"
    [System.Environment]::SetEnvironmentVariable("Path", $newPathVariable, "Machine")

}
