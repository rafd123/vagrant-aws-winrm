begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant AWS WinRM plugin must be run within Vagrant."
end

module VagrantPlugins
  module AWS
    module WinRM
      class Plugin < Vagrant.plugin("2")
        name "AWS WinRM"
        description <<-DESC
        Facilitates using the AWS-EC2-provided Administrator password as the WinRM communicator's credentials.
        DESC

        provider_capability(:aws, :winrm_info) do
          require_relative 'capability'
          VagrantPlugins::AWS::WinRM::Capability
        end
      end
    end    
  end
end