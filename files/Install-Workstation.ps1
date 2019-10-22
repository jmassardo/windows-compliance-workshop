
# Install Chocolately
Write-Output "Attempting to Install Chocolately"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install required packages
Write-Output "Installing Chef Workstation"
choco install chef-workstation -y
Write-Output "Installing Git"
choco install git -y
Write-Output "Installing VS Code"
choco install vscode -y

# Set up git
Write-Output "Configuring git"
Start-Process "C:\Program Files\Git\bin\git.exe" -Wait -ArgumentList "config --global user.email 'you@example.com'"
Start-Process "C:\Program Files\Git\bin\git.exe" -Wait -ArgumentList "config --global user.name 'Your Name'"

# Accept chef licenses
Write-Output "Setting Chef License ENV variable"
$Env:CHEF_LICENSE="accept"
[Environment]::SetEnvironmentVariable('CHEF_LICENSE', "accept", "Machine")

# Install Kitchen-docker gem
# Windows support is merged but a new gem hasn't been released so
# we're building it from source
Write-Output "Installing kitchen-docker gem"
cd c:\windows\temp
Write-Output "Cloning repo"
Start-Process "C:\Program Files\Git\bin\git.exe" -Wait -ArgumentList "clone https://github.com/test-kitchen/kitchen-docker.git"
cd kitchen-docker
Write-Output "Building gem"
C:\opscode\chef-workstation\bin\chef.bat exec gem build kitchen-docker.gemspec
Write-Output "Installing gem"
C:\opscode\chef-workstation\bin\chef.bat exec gem install kitchen-docker-2.9.0.gem

# Add Windows Defender exclusion to speed up ruby and docker
Add-MpPreference -ExclusionPath "c:\opscode"
Add-MpPreference -ExclusionPath "c:\workshop"
Add-MpPreference -ExclusionProcess "docker.exe"
Add-MpPreference -ExclusionProcess "dockerd.exe"
Add-MpPreference -ExclusionProcess "powershell.exe"
Add-MpPreference -ExclusionProcess "code.exe"

# Let's do a little prep work
Write-Output "Staging workshop files"
New-Item -Type Directory "c:\workshop"
New-Item -Type Directory "c:\workshop\ex1"
New-Item -Type file "c:\workshop\ex1\profile.rb"
New-Item -Type file "c:\workshop\ex1\recipe.rb"

New-Item -Type Directory "c:\workshop\ex2"
New-Item -Type file "c:\workshop\ex2\profile.rb"
New-Item -Type file "c:\workshop\ex2\recipe.rb"

New-Item -Type Directory "c:\workshop\ex3"
C:\opscode\chef-workstation\bin\chef.bat generate cookbook "C:\workshop\ex3\web_server"
Remove-Item -Recurse "C:\workshop\ex3\web_server\.delivery" -Force
Remove-Item -Recurse "C:\workshop\ex3\web_server\Policyfile.rb" -Force

# update kitchen.yml for the docker driver
Remove-Item -Recurse "C:\workshop\ex3\web_server\kitchen.yml" -Force
$ex3yaml = @'
---
driver:
  name: docker
  provision_command: 
    - powershell -ExecutionPolicy Bypass -NoLogo -Command . { iwr -useb https://omnitruck.chef.io/install.ps1 } ^| iex; install
    - powershell -Command $path=$env:Path + ';c:\opscode\chef\embedded\bin'; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $path

transport:
  name: docker
  socket: tcp://localhost:2375

verifier:
  name: inspec

platforms:
- name: windows
  driver_config:
    image: mcr.microsoft.com/windows/servercore:ltsc2019
    platform: windows
  run_list:
  - recipe[web_server]

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
    attributes:
'@

Write-Output $ex3yaml | out-file "C:\workshop\ex3\web_server\kitchen.yml" -encoding ASCII

New-Item -Type Directory "c:\workshop\ex4"
C:\opscode\chef-workstation\bin\chef.bat generate cookbook "C:\workshop\ex4\install_msi"
Remove-Item -Recurse "C:\workshop\ex4\install_msi\.delivery" -Force
Remove-Item -Recurse "C:\workshop\ex4\install_msi\Policyfile.rb" -Force

# update kitchen.yml for the docker driver
Remove-Item -Recurse "C:\workshop\ex4\install_msi\kitchen.yml" -Force
$ex4yaml = @'
---
driver:
  name: docker
  provision_command: 
    - powershell -ExecutionPolicy Bypass -NoLogo -Command . { iwr -useb https://omnitruck.chef.io/install.ps1 } ^| iex; install
    - powershell -Command $path=$env:Path + ';c:\opscode\chef\embedded\bin'; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name Path -Value $path

transport:
  name: docker
  socket: tcp://localhost:2375

verifier:
  name: inspec

platforms:
- name: windows
  driver_config:
    image: mcr.microsoft.com/windows/servercore:ltsc2019
    platform: windows
  run_list:
  - recipe[install_msi]

suites:
  - name: default
    verifier:
      inspec_tests:
        - test/integration/default
    attributes:
'@

Write-Output $ex4yaml | out-file "C:\workshop\ex4\install_msi\kitchen.yml" -encoding ASCII

New-Item -Type Directory "c:\workshop\ex5"
C:\opscode\chef-workstation\bin\chef.bat generate cookbook "C:\workshop\ex5\patching"
Remove-Item -Recurse "C:\workshop\ex5\patching\.delivery" -Force
Remove-Item -Recurse "C:\workshop\ex5\patching\Policyfile.rb" -Force
Remove-Item -Recurse "C:\workshop\ex5\patching\test\integration\default" -Force
C:\opscode\chef-workstation\bin\inspec.bat init profile "C:\workshop\ex5\patching\test\integration\default"

New-Item -Type Directory "c:\workshop\ex6"
C:\opscode\chef-workstation\bin\chef.bat generate cookbook "C:\workshop\ex6\hardening"
Remove-Item -Recurse "C:\workshop\ex6\hardening\.delivery" -Force
Remove-Item -Recurse "C:\workshop\ex6\hardening\Policyfile.rb" -Force
Remove-Item -Recurse "C:\workshop\ex6\hardening\test\integration\default" -Force
C:\opscode\chef-workstation\bin\inspec.bat init profile "C:\workshop\ex6\hardening\test\integration\default"

New-Item -Type Directory "c:\workshop\ex7"
C:\opscode\chef-workstation\bin\chef.bat generate cookbook "C:\workshop\ex7\cis_baseline"
Remove-Item -Recurse "C:\workshop\ex7\cis_baseline\.delivery" -Force
Remove-Item -Recurse "C:\workshop\ex7\cis_baseline\Policyfile.rb" -Force
Remove-Item -Recurse "C:\workshop\ex7\cis_baseline\test\integration\default" -Force
C:\opscode\chef-workstation\bin\inspec.bat init profile "C:\workshop\ex7\cis_baseline\test\integration\default"

Write-Output "Pulling Server Core Docker Image"
Start-Process "docker" -Wait -ArgumentList "pull mcr.microsoft.com/windows/servercore:ltsc2019"
