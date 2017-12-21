module VagrantPlugins
  module HostDarwin
    module Cap
      class SMB

        @@logger = Log4r::Logger.new("vagrant::host::darwin::smb")

        # If we have the sharing binary available, smb is installed
        def self.smb_installed(env)
          File.exist?("/usr/sbin/sharing")
        end

        # Required options for mounting a share hosted
        # on macos.
        def self.smb_mount_options(env)
          ["ver=3", "sec=ntlmssp", "nounix", "noperm"]
        end

        def self.smb_cleanup(env, machine, opts)
          m_id = machine_id(machine)
          result = Vagrant::Util::Subprocess.execute("/bin/sh", "-c",
            "/usr/sbin/sharing -l | grep -E \"^name:.+\\svgt-#{m_id}-\" | awk '{print $2}'")
          if result.exit_code != 0
            @@logger.warn("failed to locate any shares for cleanup")
          end
          shares = result.stdout.split(/\s/).map(&:strip)
          @@logger.debug("shares to be removed: #{shares}")
          shares.each do |share_name|
            @@logger.info("removing share name=#{share_name}")
            share_name.strip!
            result = Vagrant::Util::Subprocess.execute("/usr/bin/sudo",
              "/usr/sbin/sharing", "-r", share_name)
            if result.exit_code != 0
              # Removing always returns 0 even if there are currently
              # guests attached so if we get a non-zero value just
              # log it as unexpected
              @@logger.warn("removing share `#{share_name}` returned non-zero")
            end
          end
        end

        def self.smb_prepare(env, machine, folders, opts)
          folders.each do |id, data|
            hostpath = data[:hostpath]

            chksum_id = Digest::MD5.hexdigest(id)
            name = "vgt-#{machine_id(machine)}-#{chksum_id}"
            data[:smb_id] ||= name

            @@logger.info("creating new share name=#{name} id=#{data[:smb_id]}")

            cmd = [
              "/usr/bin/sudo",
              "/usr/sbin/sharing",
              "-a", hostpath,
              "-S", data[:smb_id],
              "-s", "001",
              "-g", "000",
              "-n", name
            ]

            r = Vagrant::Util::Subprocess.execute(*cmd)

            if r.exit_code != 0
              raise VagrantPlugins::SyncedFolderSMB::Errors::DefineShareFailed,
                host: hostpath.to_s,
                stderr: r.stderr,
                stdout: r.stdout
            end
          end
        end

        # Generates a unique identifier for the given machine
        # based on the name, provider name, and working directory
        # of the environment.
        #
        # @param [Vagrant::Machine] machine
        # @return [String]
        def self.machine_id(machine)
          @@logger.debug("generating machine ID name=#{machine.name} cwd=#{machine.env.cwd}")
          Digest::MD5.hexdigest("#{machine.name}-#{machine.provider_name}-#{machine.env.cwd}")
        end
      end
    end
  end
end
