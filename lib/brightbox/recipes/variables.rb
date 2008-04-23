#  Brightbox - Easy Ruby Web Application Deployment
#  Copyright (C) 2008, Brightbox Systems
#  Written by Neil Wilson, <neil@brightbox.co.uk>
#
#  This file is part of the Brightbox deployment system
#
# Provide default settings for variables
_cset :mongrel_pid_file, "tmp/pids/mongrel.pid"  #Stores Process ID for Mongrels
_cset :log_max_size, "100M"                 #Size at which to rotate log
_cset :log_keep, "10"                       #Keep this many compressed logs
_cset(:log_dir) {File.join(current_path, 'log')}
_cset :mongrel_host, "localhost"
_cset :mongrel_port, 9200
_cset :mongrel_servers, 2
_cset(:mongrel_config_file) {File.join(deploy_to, "#{application}_mongrel_config.yml")}
_cset(:domain) { abort "You need to set the :domain variable, e.g set :domain 'www.example.com'" }
_cset :domain_aliases, ""
_cset :user, "rails"
ssh_options[:forward_agent] = true

# Default system dependencies
depend :remote, :gem, "rails", ">=2"
depend :remote, :command, "mongrel_rails"
