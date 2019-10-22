# Windows Chef Workshop

## Intro

Greetings! This repository contains [Terraform](https://www.terraform.io) plans, [Packer](https://www.packer.io) templates, and example exercises to learn basic Test Driven Development processes using [Chef](https://www.chef.io) and [InSpec](https://www.inspec.io) on Windows.

## Notes

The Packer templates perform the following steps on each server:

* Configures WinRM to allow remote configuration
* Installs [Chocolately](https://chocolatey.org), [Chef Workstation](https://www.chef.sh), [Docker](https://www.docker.com), [Git](https://www.git-scm.com), [VS Code](https://code.visualstudio.com), and the [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) gem
* Creates the scaffolding for the cookbooks/profiles used in the exercises.

## Usage

First, run `packer build windows2019.json` to build the master image.

> NOTE: you may need to edit the region and resource group names to build in your subscription.

Then, you'll need to create a `terraform.tfvars` file and add your subnet so your systems are exposed to the public Internet. You can copy the `terraform.tfvars.example` as a template.

``` toml
"source_address_prefix" = "1.2.3.0/24"
"tag_customer" = "AwesomeCustomer"
"tag_project" = "compliance-workshop"
"tag_dept" = "CustomerSuccess"
"tag_contact" = "jmassardo"
"tag_ttl" = "8"
"count" = "1"
"image_name" = "workshop_workstation"
"image_rg_name" = "my_image_rg"
```

> NOTE: If you do need the security group open to all ranges, enter an asterisk `"*"` in place of the ip address/subnet.

Finally, run `terraform apply`

Once Terraform completes, it will still take 20-30 minutes for the installations to complete in the back ground.

## Exercises

### EX1 - Create File

In this exercise, we'll explore the basics of [Test Driven Development (TDD)](https://en.wikipedia.org/wiki/Test-driven_development). Essentially, we'll write a test, then we'll write code to make the test turn green. By starting with the tests, we're giving ourselves a 'finish line' so we know when we're done.

Let's get on with it. Our goal here is to create a file in the `C:\Windows\Temp` folder. Let's write a test for it. InSpec gives us the option to add a lot of additional detail about the test. Things like who requested it, or who approved the exception if you are deviating from a specific standard. More info [here](https://www.inspec.io/docs/reference/dsl_inspec/).

`profile.rb`

``` ruby
# Simple control to validate that the required file exists.

title "Required Files"

control "req-files-1" do                                   # A unique ID for this control
  impact 1.0                                               # The criticality, if this control fails.
  title "All systems should have a tag file"               # A human-readable title
  desc "This file tags a system so we know Chef built it." # Metadata and other knowledge about this requirement/control
  describe file("c:/windows/temp/chef.txt") do             # The actual test
    it { should exist }
  end
end
```

Now that we have our profile, let's run it and see what we get.

``` dos
PS C:\workshop\ex1> inspec exec .\profile.rb

Profile: tests from .\profile.rb (tests from ..profile.rb)
Version: (not specified)
Target:  local://

  [FAIL]  req-files-1: All systems should have a tag file
     [FAIL]  File c:/windows/temp/chef.txt should exist
     expected File c:/windows/temp/chef.txt to exist


Profile Summary: 0 successful controls, 1 control failure, 0 controls skipped
Test Summary: 0 successful, 1 failure, 0 skipped
```

Just as we expected, the test failed... Let's make it pass by writing a Chef recipe. Chef has a built-in `file` resource so we'll use it.

`recipe.rb`

``` ruby
file 'c:/windows/temp/chef.txt' do
  action :create
end
```

Now let's run it:

``` dos
PS C:\workshop\ex1> chef-client -z .\recipe.rb
Starting Chef Infra Client, version 15.3.14
resolving cookbooks for run list: []
Synchronizing Cookbooks:
Installing Cookbook Gems:
Compiling Cookbooks...
Converging 1 resources
Recipe: @recipe_files::C:/workshop/ex1/recipe.rb
  * file[c:/windows/temp/chef.txt] action create
    - create new file c:/windows/temp/chef.txt

Running handlers:
Running handlers complete
Chef Infra Client finished, 1/1 resources updated in 08 seconds
```

Now that we've ran the recipe to create the file, let's check the test again to make sure it passes.

``` dos
PS C:\workshop\ex1> inspec exec .\profile.rb

Profile: tests from .\profile.rb (tests from ..profile.rb)
Version: (not specified)
Target:  local://

  [PASS]  req-files-1: All systems should have a tag file
     [PASS]  File c:/windows/temp/chef.txt should exist


Profile Summary: 1 successful control, 0 control failures, 0 controls skipped
Test Summary: 1 successful, 0 failures, 0 skipped
```

Awww yeah!

To recap, TDD is a process were we write tests for the things our code needs to do, then we write enough code to turn the tests green. We'll use TDD for all of the following examples so those sections will be shorter.

### EX2 - Create Registry Key

In this example, we'll set the `legalnotice` registry keys so anyone that logs into our systems is presented with our legal notices.

In TDD style, let's write the test first. There are two registry keys so we need to test both.

``` ruby
# Simple control to validate that the required registry keys exist.

title "Required Registry Keys"

control "req-keys-1" do                                                     # A unique ID for this control
  impact 1.0                                                                # The criticality, if this control fails.
  title "All systems should have a Legal notice caption"                    # A human-readable title
  desc "We are required to display legal notices to any user that logs in." # Metadata and other knowledge about this requirement/control
  describe registry_key('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System') do
    its('legalnoticecaption') { should eq "WARNING!" }
  end
end

control "req-keys-2" do                                                     # A unique ID for this control
  impact 1.0                                                                # The criticality, if this control fails.
  title "All systems should have a Legal notice text"                       # A human-readable title
  desc "We are required to display legal notices to any user that logs in." # Metadata and other knowledge about this requirement/control
  describe registry_key('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System') do
    its('legalnoticetext') { should eq "This is a protected system. If you are not an authorized user, log off immediately!" }
  end
end
```

Here's the output:

``` dos
PS C:\workshop\ex2> inspec exec .\profile.rb

Profile: tests from .\profile.rb (tests from ..profile.rb)
Version: (not specified)
Target:  local://

  [FAIL]  req-keys-1: All systems should have a Legal notice caption
     [FAIL]  Registry Key HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System legalnoticecaption should eq "WARNING!"

     expected: "WARNING!"
          got: ""

     (compared using ==)

  [FAIL]  req-keys-2: All systems should have a Legal notice text
     [FAIL]  Registry Key HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System legalnoticetext should eq "This is a protected system. If you are not an authorized user, log off immediately!"

     expected: "This is a protected system. If you are not an authorized user, log off immediately!"
          got: "\u0000"

     (compared using ==)



Profile Summary: 0 successful controls, 2 control failures, 0 controls skipped
Test Summary: 0 successful, 2 failures, 0 skipped
```

Now to turn the tests green:

``` dos
registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System' do
  values [{
    name: "legalnoticecaption",
    type: :string,
    data: 'WARNING!'
  }]
  action :create
end

registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System' do
  values [{
    name: "legalnoticetext",
    type: :string,
    data: 'This is a protected system. If you are not an authorized user, log off immediately!'
  }]
  action :create
end
```

Now run the tests again.

### EX3 - Create Webserver

Up to this point, we've been manually running the commands on our local machine. We don't want to do this manual work day in and day out and we sure don't want to test changes against our local machine... So, what do we do? We use more automation! Enter [Test Kitchen](https://www.kitchen.ci). Test Kitchen (or just Kitchen) provides scaffolding and automation to make it a ton easier to write cookbooks.

Let's take a look at a real cookbook

``` dos
web_server
│   kitchen.yml                 # Config file for Kitchen
│   metadata.rb                 # Info about the cookbook
├───recipes
│       default.rb              # Initial recipe. This is where we put our Chef resources
└───test
    └───integration
        └───default
                default_test.rb # This is where we put our InSpec tests
```

Since we're using Windows Server 2019 for this workshop, let's stick with the new hotness and run Windows Docker containers for our tests.

This is the `kitchen.yml` for our workshop:

``` yaml
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
```

Kitchen does a ton of other stuff around automated testing; however, we're only going to use one command, `kitchen test`. This command creates the container, loads all the Chef bits needed, converges the cookbook, then runs the InSpec tests.

Let's take a look at TDD with Kitchen:

Our test should make sure the server is listening on port 80.

``` ruby
describe port(80) do
  it { should be_listening }
end
```

Now run `kitchen test`. Obviously we'll get a failure, however, the tests are now being run an an ephemeral container.

Install IIS

``` ruby
windows_feature ['web-server, web-webserver'] do
  action :install
  install_method :windows_feature_powershell
end
```

Run `kitchen test` again. The test should pass.

### EX4 - Install MSI

Let's use TDD to install 7Zip on a container:

Test to see if the binary exists

``` ruby
describe file("C:/Program Files/7-Zip/7z.exe") do
  it { should exist }
end
```

And now use the `windows_package` to install using the MSI. We'll fetch it directly from their website and cache it locally.

``` ruby
windows_package '7zip' do
  source 'http://www.7-zip.org/a/7z1900-x64.msi'
  remote_file_attributes ({
    :path => 'c:/windows/temp/7zip.msi'
  })
end
```

### EX5 - Simple Patching

`TODO`

### EX6 - Windows Hardening

`TODO`

### EX7 - CIS Baselines

`TODO`

## Closing

As always, feel free to contact me, open issues, or submit PRs.
