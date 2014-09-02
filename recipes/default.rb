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
    mode "0600"
  end.run_action(:create)

  chef_handler "LogStashNotify" do
    source "#{node['chef_handler']['handler_path']}/chef-logstash-notify.rb"
    arguments [
      :host => logstash['host'],
      :port => logstash['port'],
    ]
    supports :exception => true
    action :nothing
  end.run_action(:enable)
end
