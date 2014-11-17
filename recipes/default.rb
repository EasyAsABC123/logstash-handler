# Cookbook Name:: logstash-handler
# Recipe:: default
#
# Copyright 2014
#
#

logstash = node['chef_client']['handler']['logstash'] if node['chef_client'] && node['chef_client']['handler']
logstash ||= {}

if logstash['host']
  include_recipe 'chef_handler'
  
  handler_path = node['chef_handler']['handler_path']
  handler = ::File.join handler_path, 'chef_logstash_notify'
  Chef::Log::info("#{handler}.rb")

  cookbook_file "#{handler}.rb" do
    source 'chef_logstash_notify.rb'
  end.run_action(:create)

  ##
  # This was primarily done to prevent others from having to stub
  # `include_recipe "reboot_handler"` inside ChefSpec.  ChefSpec
  # doesn't seem to handle the following well on convergence.
  ruby_block "reload client config" do
    block do
      begin
        require handler
      rescue LoadError
        log 'Unable to require the LogStash handler!' do
          action :write
        end
      end
    end
  end.run_action(:run)

  chef_handler 'LogStash::LogStashNotify' do
    source handler
    arguments [
      :host => logstash['host'],
      :port => logstash['port'],
      :unique_message => logstash['unique_message'],
      :godeploylog => logstash['godeploylog']
    ]
    supports :report=>true, :exception=>true
    action :nothing
  end.run_action(:enable)
end
