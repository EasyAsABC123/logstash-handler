# Cookbook Name:: logstash-handler
# Recipe:: default
#
# Copyright 2014
#
#

logstash = node['chef_client']['handler']['logstash'] if node['chef_client'] && node['chef_client']['handler']
logstash ||= {}

if logstash['host']
  include_recipe 'chef_handler::default'

  cookbook_file "#{node['chef_handler']['handler_path']}/chef-logstash-notify.rb" do
    source 'chef-logstash-notify.rb'
    action :create
  end

  chef_handler 'LogStashNotifyModule::LogStashNotify' do
    source "#{node['chef_handler']['handler_path']}/chef-logstash-notify"
    arguments [
      :host => logstash['host'],
      :port => logstash['port'],
      :unique_message => logstash['unique_message']
    ]
    supports :report=>true, :exception=>true
    action :enable
  end
end
