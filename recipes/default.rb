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
  handler = ::File.join handler_path, 'chef-logstash-notify'

  cookbook_file "#{handler}.rb" do
    source 'chef-logstash-notify.rb'
    action :create
  end

  chef_handler 'LogStash::LogStashNotify' do
    source handler
    arguments [
      :host => logstash['host'],
      :port => logstash['port'],
      :unique_message => logstash['unique_message']
    ]
    supports :report=>true, :exception=>true
    action :enable
  end
end
