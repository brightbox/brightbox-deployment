#    Brightbox - Easy Ruby Web Application Deployment
#    Copyright (C) 2008, Neil Wilson, Brightbox Systems
#
#    This file is part of the Brightbox deployment system
#
#    Brightbox gem is free software: you can redistribute it and/or modify it
#    under the terms of the GNU Affero General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General
#    Public License along with this program.  If not, see
#    <http://www.gnu.org/licenses/>.
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
_cset :runner, user
ssh_options[:forward_agent] = true

# Default system dependencies
depend :remote, :gem, "rails", ">=2"
depend :remote, :command, "mongrel_rails"
