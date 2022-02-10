module VagrantPlugins
  module CommandServe
    module Service
      class ProvisionerService < Hashicorp::Vagrant::Sdk::ProvisionerService::Service
        prepend Util::HasMapper
        prepend Util::HasBroker
        prepend Util::HasLogger

        include Util::ServiceInfo
        include Util::HasSeeds::Service
        include Util::ExceptionTransformer

        def cleanup(req, ctx)
          machine, plugin_config = _process_args(req)

          provisioner =_lookup_or_instantiate_provisioner(req, ctx, machine, plugin_config)

          provisioner.cleanup
        end

        def cleanup_spec(*_)
          SDK::FuncSpec.new(
            name: "cleanup_spec",
            args: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Args.Target.Machine",
                name: "",
              ),
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Vagrantfile.GeneralConfig",
                name: "",
              )
            ],
            result: [],
          )
        end

        def configure(req, ctx)
          machine, plugin_config = _process_args(req)

          provisioner =_lookup_or_instantiate_provisioner(req, ctx, machine, plugin_config)

          provisioner.configure(machine.config)

          Empty.new
        end

        def configure_spec(*_)
          SDK::FuncSpec.new(
            name: "configure_spec",
            args: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Args.Target.Machine",
                name: "",
              ),
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Vagrantfile.GeneralConfig",
                name: "",
              )
            ],
            result: [],
          )
        end


        def provision(req, ctx)
          machine, plugin_config = _process_args(req)

          provisioner =_lookup_or_instantiate_provisioner(req, ctx, machine, plugin_config)

          provisioner.provision

          Empty.new
        end

        def provision_spec(*_)
          SDK::FuncSpec.new(
            name: "provision_spec",
            args: [
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Args.Target.Machine",
                name: "",
              ),
              SDK::FuncSpec::Value.new(
                type: "hashicorp.vagrant.sdk.Vagrantfile.GeneralConfig",
                name: "",
              )
            ],
            result: [],
          )
        end

        # All of the methods here take the same args, so they have the same
        # args processing which can be shared
        #
        # @param req the request
        # @return [Array(Vagrant::Machine, Vagrant::Plugin::V2::Config)]
        def _process_args(req)
          machine, config = mapper.funcspec_map(
            req, mapper, broker, expect: [
              Vagrant::Machine, SDK::Vagrantfile::GeneralConfig
            ]
          )
          config_klass = config.type.split('::').inject(Kernel) { |memo, obj|
            memo.const_get(obj)
          }
          config_data = config.config.unpack(Google::Protobuf::Struct).to_h
          plugin_config = config_klass.new
          plugin_config.set_options(config_data)
          return machine, plugin_config
        end

        def _lookup_or_instantiate_provisioner(req, ctx, machine, plugin_config)
          @_provisioner_cache ||= {}
          key = ctx.metadata["plugin_name"]
          if @_provisioner_cache[key] != nil
            return @_provisioner_cache[key]
          else
            plugins = Vagrant.plugin("2").local_manager.provisioners
            with_plugin(ctx, plugins, broker: broker) do |plugin|
              provisioner = plugin.new(machine, plugin_config)
              @_provisioner_cache[key] = provisioner
              return provisioner
            end
          end
        end
      end
    end
  end
end
