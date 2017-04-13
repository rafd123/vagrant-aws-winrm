# Vagrant-AWS-WinRM

Adds a capability to the `vagrant-aws` provider to retrieve and use the EC2-generated Administrator password when establishing a connection to the instance with the WinRM communicator.

This allows one to use EC2Config to generate a new Administrator password at provision time, obviating the need to use a hardcoded username and password to connect to Windows boxes provisioned in AWS.

## Installation

```bash
$ vagrant plugin install vagrant-aws-winrm
```

## Usage

Install and configure the [vagrant-aws](https://github.com/mitchellh/vagrant-aws) plugin.

In your Vagrantfile, ensure you configure values for `aws.keypair_name` and `ssh.private_key_path`.

When configuring the WinRM credentials, use `Administrator` and `:aws` for the `winrm.username` and `winrm.password`, respectively.

Additionally, you will need to ensure that you set `aws.security_groups` with a Security Group that allows WinRM inbound (port 5985).

Finally, you can leverage `aws.user_data` to ensure that WinRM is enabled and the Windows Firewall is permitting WinRM inbound.

Example:

```
Vagrant.configure("2") do |config|
  # ... other stuff

  config.vm.communicator = "winrm"
  config.winrm.username = "Administrator"

  config.vm.provider "aws" do |aws, override|
    # Indicate that the password should be fetched and decrypted from AWS   
    override.winrm.password = :aws

    # private_key_path needed to decrypt the password
    override.ssh.private_key_path = "PATH TO YOUR PRIVATE KEY"

    # keypair name corresponding to private_key_path
    aws.keypair_name = "KEYPAIR NAME"

    # Use a security group that allows WinRM port inbound (port 5985)
    aws.security_groups = ["SOME SECURITY GROUP THAT ALLOWS WINRM INBOUND"]

    # Enable WinRM on the instance
    aws.user_data = <<-USERDATA
      <powershell>
        Enable-PSRemoting -Force
        netsh advfirewall firewall add rule name="WinRM HTTP" dir=in localport=5985 protocol=TCP action=allow
      </powershell>
    USERDATA
  end
end

```

## Contributing

1. Fork it ( https://github.com/rafd123/vagrant-aws-winrm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
