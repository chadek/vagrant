# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: proto/ruby_vagrant/ruby-server.proto

require 'google/protobuf'

require 'google/protobuf/empty_pb'
require 'google/protobuf/any_pb'
require 'google/rpc/error_details_pb'
require 'plugin_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("proto/ruby_vagrant/ruby-server.proto", :syntax => :proto3) do
    add_message "hashicorp.vagrant.GetPluginsResponse" do
      repeated :plugins, :message, 1, "hashicorp.vagrant.Plugin"
    end
    add_message "hashicorp.vagrant.Plugin" do
      optional :name, :string, 1
      optional :type, :enum, 2, "hashicorp.vagrant.Plugin.Type"
    end
    add_enum "hashicorp.vagrant.Plugin.Type" do
      value :UNKNOWN, 0
      value :COMMAND, 1
      value :COMMUNICATOR, 2
      value :GUEST, 3
      value :HOST, 4
      value :PROVIDER, 5
      value :PROVISIONER, 6
      value :SYNCEDFOLDER, 7
      value :AUTHENTICATOR, 8
      value :LOGPLATFORM, 9
      value :LOGVIEWER, 10
      value :MAPPER, 11
      value :CONFIG, 12
      value :PLUGININFO, 13
      value :PUSH, 14
    end
    add_message "hashicorp.vagrant.ParseVagrantfileRequest" do
      optional :path, :string, 1
    end
    add_message "hashicorp.vagrant.ParseVagrantfileResponse" do
      optional :vagrantfile, :message, 1, "hashicorp.vagrant.sdk.Vagrantfile.Vagrantfile"
    end
  end
end

module Hashicorp
  module Vagrant
    GetPluginsResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hashicorp.vagrant.GetPluginsResponse").msgclass
    Plugin = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hashicorp.vagrant.Plugin").msgclass
    Plugin::Type = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hashicorp.vagrant.Plugin.Type").enummodule
    ParseVagrantfileRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hashicorp.vagrant.ParseVagrantfileRequest").msgclass
    ParseVagrantfileResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("hashicorp.vagrant.ParseVagrantfileResponse").msgclass
  end
end
