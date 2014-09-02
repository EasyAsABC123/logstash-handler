logstash-handler Cookbook
========================
Installs, configures and starts the handlers Controller and/or Agent.

This cookbook does its best to follow platform native idioms at all
times. This means things like logs, pid files, sockets, and service
managers work "as expected" by an administrator familiar with a given
platform.

Requirements
------------
* Chef 11 or higher
* Ruby 1.9 (preferably from the Chef full-stack installer)

#### packages
- `chef_handler` - logstash-handler inherits from this cookbook and creates a new class.

Recipes
-------
### hps-handlers::default

This recipe creates a github gist of the stacktrace and posts the message to IRC

License & Authors
-------------------
- Author:: Justin Schuhmann (<jmschu02@gmail.com>)
