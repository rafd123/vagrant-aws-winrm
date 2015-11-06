require "vagrant-aws-winrm/version"
require "vagrant-aws-winrm/plugin"

module VagrantPlugins
  module AWS
    module WinRM
        lib_path = Pathname.new(File.expand_path("../vagrant-aws-winrm", __FILE__))
        # This returns the path to the source of this plugin.
        #
        # @return [Pathname]
        def self.source_root
          @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
        end
    end
  end
end