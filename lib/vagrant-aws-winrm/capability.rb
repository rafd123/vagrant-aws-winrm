require "vagrant-aws"
require "log4r"

module VagrantPlugins
  module AWS
    module WinRM
      class Capability
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_aws_winrm::capability::winrm_info")
        end

        def self.winrm_info(machine)
          if machine.config.winrm.password == :aws
            machine.ui.info('Getting WinRM password from AWS...')

            # Call the VagrantPlugins::AWS::Action::ConnectAWS
            # middleware so we can get acces to the Fog connection
            machine.env.action_runner.run(
              Vagrant::Action::Builder.new.tap do |b|
                b.use VagrantPlugins::AWS::Action::ConnectAWS
                b.use self
              end, {
                machine: machine,
                ui: machine.ui,
              }
            )
          end
          return {}
        end

        def call(env)
          machine = env[:machine]
          aws     = env[:aws_compute]

          response            = aws.get_password_data({ instance_id: machine.id })
          password_data       = response.body['passwordData']
          password_data_bytes = Base64.decode64(password_data)
          
          # Try to decrypt the password data using each one of the private key files
          # set by the user until we hit one that decrypts successfully
          machine.config.ssh.private_key_path.each do |private_key_path|
            private_key_path = File.expand_path private_key_path

            @logger.info("Decrypting password data using #{private_key_path}")
            rsa = OpenSSL::PKey::RSA.new File.read private_key_path
            begin
              machine.config.winrm.password = rsa.private_decrypt password_data_bytes
              @logger.info("Successfully decrypted password data using #{private_key_path}")
            rescue OpenSSL::PKey::RSAError
              @logger.warn("Failed to decrypt password data using #{private_key_path}")
              next
            end

            break
          end

          @app.call(env)                   
        end        
      end        
    end      
  end
end
