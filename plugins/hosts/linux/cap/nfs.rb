
        NFS_EXPORTS_PATH = "/etc/exports".freeze
          nfs_cleanup("#{Process.uid} #{id}")
          output = "#{nfs_exports_content}\n#{output}"
          nfs_write_exports(output)
          return if !File.exist?(NFS_EXPORTS_PATH)
          # Create editor instance for removing invalid IDs
          editor = Vagrant::Util::StringBlockEditor.new(nfs_exports_content)
          # Build composite IDs with UID information and discover invalid entries
          composite_ids = valid_ids.map do |v_id|
            "#{user} #{v_id}"
          end
          remove_ids = editor.keys - composite_ids

          logger.debug("Known valid NFS export IDs: #{valid_ids}")
          logger.debug("Composite valid NFS export IDs with user: #{composite_ids}")
          logger.debug("NFS export IDs to be removed: #{remove_ids}")
          if !remove_ids.empty?
            ui.info I18n.t("vagrant.hosts.linux.nfs_prune")
            nfs_cleanup(remove_ids)
        def self.nfs_cleanup(remove_ids)
          return if !File.exist?(NFS_EXPORTS_PATH)
          editor = Vagrant::Util::StringBlockEditor.new(nfs_exports_content)
          remove_ids = Array(remove_ids)
          # Remove all invalid ID entries
          remove_ids.each do |r_id|
            editor.delete(r_id)
          end
          nfs_write_exports(editor.value)
        end
        def self.nfs_write_exports(new_exports_content)
          if(nfs_exports_content != new_exports_content.strip)
            begin
              # Write contents out to temporary file
              new_exports_file = Tempfile.create('vagrant')
              new_exports_file.puts(new_exports_content)
              new_exports_file.close
              new_exports_path = new_exports_file.path

              # Only use "sudo" if we can't write to /etc/exports directly
              sudo_command = ""
              sudo_command = "sudo " if !File.writable?(NFS_EXPORTS_PATH)

              # Ensure new file mode and uid/gid match existing file to replace
              existing_stat = File.stat(NFS_EXPORTS_PATH)
              new_stat = File.stat(new_exports_path)
              if existing_stat.mode != new_stat.mode
                File.chmod(existing_stat.mode, new_exports_path)
              end
              if existing_stat.uid != new_stat.uid || existing_stat.gid != new_stat.gid
                chown_cmd = "#{sudo_command}chown #{existing_stat.uid}:#{existing_stat.gid} #{new_exports_path}"
                result = Vagrant::Util::Subprocess.execute(*Shellwords.split(chown_cmd))
                if result.exit_code != 0
                  raise Vagrant::Errors::NFSExportsFailed,
                    command: chown_cmd,
                    stderr: result.stderr,
                    stdout: result.stdout
                end
              end
              # Always force move the file to prevent overwrite prompting
              mv_cmd = "#{sudo_command}mv -f #{new_exports_path} #{NFS_EXPORTS_PATH}"
              result = Vagrant::Util::Subprocess.execute(*Shellwords.split(mv_cmd))
              if result.exit_code != 0
                raise Vagrant::Errors::NFSExportsFailed,
                  command: mv_cmd,
                  stderr: result.stderr,
                  stdout: result.stdout
              end
            ensure
              if File.exist?(new_exports_path)
                File.unlink(new_exports_path)
              end
            end
          end
        end

        def self.nfs_exports_content
          if(File.exist?(NFS_EXPORTS_PATH))
            if(File.readable?(NFS_EXPORTS_PATH))
              File.read(NFS_EXPORTS_PATH)
            else
              cmd = "sudo cat #{NFS_EXPORTS_PATH}"
              result = Vagrant::Util::Subprocess.execute(*Shellwords.split(cmd))
              if result.exit_code != 0
                raise Vagrant::Errors::NFSExportsFailed,
                  command: cmd,
                  stderr: result.stderr,
                  stdout: result.stdout
              else
                result.stdout
              end
            end
          else
            ""
          end