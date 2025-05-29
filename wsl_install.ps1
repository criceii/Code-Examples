# Check if WSL is already installed
$wslInstalled = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled'
$vmPlatformInstalled = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq 'Enabled'

if (-not $wslInstalled) {
    # Enable WSL
    Write-Output "Enabling WSL..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
} else {
    Write-Output "WSL is already enabled."
}

if (-not $vmPlatformInstalled) {
    # Enable Virtual Machine Platform
    Write-Output "Enabling Virtual Machine Platform..."
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
} else {
    Write-Output "Virtual Machine Platform is already enabled."
}

# Restart the computer to apply changes if necessary
if (-not $wslInstalled -or -not $vmPlatformInstalled) {
    Write-Output "One or more features require a restart to complete the installation."
    Write-Output "Please save your work and close any open applications before continuing."
    Read-Host -Prompt "Press Enter to restart the computer and apply changes"
    Restart-Computer
}
# Line breaks
Write-Host "`n"

# Check if Ubuntu is already installed
$installedDistributions = wsl --list --quiet
$ubuntuInstalled = $installedDistributions -like "*U*"

if (-not $ubuntuInstalled) {
    # Prompt user to download Ubuntu 20.04
    Write-Output "Ubuntu is not installed. The script will now download Ubuntu 20.04 for you, which could take 5-10 minutes."
    # Line breaks
    Write-Host "`n"

    # Define the output file path
    $ubuntuOutFile = "$env:USERPROFILE\Downloads\Ubuntu.appx"

    # Use Invoke-WebRequest to download the Ubuntu 20.04 installation file
    $ProgressPreference = 'SilentlyContinue' # Suppress progress bar to potentially speed up the download
    Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2004" -OutFile $ubuntuOutFile -UseBasicParsing
    $ProgressPreference = 'Continue' # Reset progress preference to default value

    # Provide instructions for manual installation
    Write-Output "Ubuntu 20.04 has been downloaded to $ubuntuOutFile"
    Write-Output "The script will now attempt to install Ubuntu 20.04 automatically, which could take 5-10 minutes."
    # Line breaks
    Write-Host "`n"

    # Change directory to the user's Downloads folder
    Set-Location -Path "$env:USERPROFILE\Downloads"

    # Install the app package
    Add-AppxPackage -Path ".\Ubuntu.appx"

    # Provide instructions for after installation
    Write-Output "Ubuntu 20.04 has been installed. Please launch Ubuntu to complete the setup and configuration."
    # Line breaks
    Write-Host "`n"
    Write-Output "If Ubuntu throws error similar to 'Error: 0x800701bc WSL 2 requires an update to its kernel component', download the latest WSL 2 Kernel update from 'https://aka.ms/wsl2kernel'"
    # Line breaks
    Write-Host "`n"
    Write-Output "You can set any desired username and password."

    # Wait for user confirmation that Ubuntu setup is complete
    $setupComplete = $false
    while (-not $setupComplete) {
        $userInput = Read-Host -Prompt "Have you launched Ubuntu and completed the setup? (yes/no)"
        if ($userInput -eq "yes") {
            $setupComplete = $true
        } else {
            Write-Host "Please launch Ubuntu, complete the setup, and then return to this script."
        }
    }
} else {
    Write-Output "Ubuntu is already installed."
}
# Line breaks
Write-Host "`n"

# Set WSL version to 2 for Ubuntu
wsl --set-version Ubuntu 2

# Copy WSL & Ansible Bash script from a network share to the local path
$sourcePath = "\\network\share\path\wsl_ansible_config.sh"
$destinationPath = "C:\Temp\wsl_ansible_config.sh"

# Ensure the destination directory exists
$destinationDir = Split-Path -Path $destinationPath -Parent
if (-not (Test-Path -Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir
}

# Copy the file and overwrite if it already exists
Copy-Item -Path $sourcePath -Destination $destinationPath -Force
# Line breaks
Write-Host "`n"

Write-Output "WSL & Ansible Bash script has been copied to $destinationPath"
# Line breaks
Write-Host "`n"

# Create a multi-line string with all the instructions
$instructions = @"
To complete the setup, please follow these steps:
1. Open Windows Subsystem for Linux (WSL) by typing 'wsl' or 'Ubuntu' in the Start menu or command prompt.
2. Once in WSL, navigate to the mounted C: drive by running 'cd /mnt/c/Temp'.
3. Execute the script by running './wsl_ansible_config.sh'.
4. Navigate to 'ansible' directory via 'cd' > 'ls' > 'cd ansible' commands.
5. The 'ansible' directory is your working directory for running playbooks.
6. Navigate to 'ansible/GitHub/group_vars/all/'. If already in 'ansible' directory you can use 'cd /ansible/GitHub/group_vars/all'.
7. 'ansible/GitHub/group_vars/all/' contains the vars.yml and vault.yml needed to execute playbooks.
8. Open 'vault.yml' by using 'nano vault.yml' or 'sudo nano vault.yml' if needed.
9. Retrieve the necessary password and paste it at the end of the line for 'vault_sys_ecwin_ansible_dev_password:'.
10. Press 'cntrl+s' then 'cntrl+x' to save and close the file.
11. Navigate back the 'ansible directory via 'cd ../../../' command'.
12. In the 'ansible' directory you'll find 'inventory_file_template.yml' for reference.
13. Playbook examples can be found at your organization's GitHub repository.
14. Example playbook execution command: 'time ansible-playbook test_playbook.yml -i inv_test.yml'.
15. Example playbook execution command: 'ansible-playbook test_playbook.yml -i inv_test.yml'.
16. Example playbook execution command: 'sudo ansible-playbook test_playbook.yml -i inv_test.yml'.
17. Add the necessary user to 'Local Administrators' on your test/target system. - DO NOT USE ON PRODUCTION SYSTEMS!!
18. You are now ready to start running Ansible playbooks.
19. If you have any further questions, contact your system administrator.

Please copy the above instructions to a text file or take a screenshot for reference.
After copying the instructions, press Enter to close PowerShell.
"@

# Output the instructions
Write-Output $instructions

# Wait for the user to press Enter
$null = Read-Host -Prompt "Press Enter after you have copied the instructions"
