# Vagrant-AWS-WinRM

Adds a capability to the `vagrant-aws` provider to retrieve and use the EC2-generated Administrator password when estabilishing a connection to the instance with the WinRM communicator.

This allows one to use EC2Config to generate a new Administrator password at provision time, obviating the need to use a hardcoded username and password to connect to Windows boxes provisioned in AWS.

## Installation

```bash
$ vagrant plugin install vagrant-aws-winrm
```

## Usage

Install and configure the [vagrant-aws](https://github.com/mitchellh/vagrant-aws) plugin.

In your Vagrantfile, ensure you configure values for `aws.keypair_name` and `ssh.private_key_path`.

When configuring the WinRM credentials, use `Administrator` and `:aws` for the `winrm.username` and `winrm.password`, respectively.

Example:

```
Vagrant.configure("2") do |config|
  
  # Other stuff

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "YOUR KEY"
    aws.secret_access_key = "YOUR SECRET KEY"
    aws.keypair_name = "KEYPAIR NAME"    
    override.ssh.private_key_path = "PATH TO YOUR PRIVATE KEY"
    override.vm.communicator = "winrm"
    override.winrm.username = "Administrator"
    override.winrm.password = :aws
    override.winrm.transport = :ssl
  end
end
```

## Setting up your server

You'll have to configure WinRM to use basic authentication. As a result, it is recommended that you configure WinRM to use a HTTPS listener.

```
winrm quickconfig -q
winrm set winrm/config/service/auth @{Basic="true"}
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{CertificateThumbprint="YOUR CERT THUMBPRINT"}
```

For self-signed SSL certs, you'll have to configure your Vagrantfile to set `winrm.ssl_peer_verification` to false.

See also:

* [MSDN article about configuring WinRM](http://msdn.microsoft.com/en-us/library/aa384372\(v=vs.85\).aspx)
* [WinRM gem](https://github.com/WinRb/WinRM/blob/master/README.md#ssl)

## Contributing

1. Fork it ( https://github.com/rafd123/vagrant-aws-winrm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
