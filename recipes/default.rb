# Cookbook Name:: hps-handlers
# Recipe:: default
#
# Copyright 2014
#
#

logstash = node['chef_client']['handler']['logstash'] if node['chef_client'] && node['chef_client']['handler']
logstash ||= {}

if logstash['host']
  include_recipe "chef_handler"

  cookbook_file "#{node['chef_handler']['handler_path']}/chef-logstash-notify.rb" do
    source "chef-logstash-notify.rb"
  end.run_action(:create)

  chef_handler "LogStashNotify" do
    source "#{node['chef_handler']['handler_path']}/chef-logstash-notify.rb"
    arguments [
      :host => logstash['host'],
      :port => logstash['port'],
      :unique_message => logstash['unique_message']
    ]
    supports :exception => true, 
      :report => true if logstash['unique_message'] != nil && logstash['unique_message'] != ''
    action :nothing
  end.run_action(:enable)
end
