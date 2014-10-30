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

  cookbook_file "#{Chef::Config[:file_cache_path]}/chef-logstash-notify.rb" do
    source "chef-logstash-notify.rb"
  end

  chef_handler "LogStashNotify" do
    source "#{Chef::Config[:file_cache_path]}/chef-logstash-notify.rb"
    arguments [
      :host => logstash['host'],
      :port => logstash['port'],
      :unique_message => logstash['unique_message']
    ]
    supports :exception => true
    action :nothing
  end
end
