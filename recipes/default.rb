# Cookbook Name:: logstash-handler
# Recipe:: default
#
# Copyright 2014
#
#

logstash = node['chef_client']['handler']['logstash'] if node['chef_client'] && node['chef_client']['handler']
logstash ||= {}

if logstash['host']
  include_recipe "chef_handler"

  cookbook_file "#{Chef::Config[:file_cache_path]}/chef-logstash-notify.rb" do
    source "chef-logstash-notify.rb"
    action :nothing
  end.run_action(:create)

  chef_handler "LogStashNotifyModule::LogStashNotify" do
    source "#{Chef::Config[:file_cache_path]}/chef-logstash-notify.rb"
    arguments [
      :host => logstash['host'],
      :port => logstash['port'],
      :unique_message => logstash['unique_message']
    ]
    supports :report=>true, :exception=>true
    action :nothing
  end.run_action(:enable)
end
