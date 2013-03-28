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

_cset :log_max_size, "100M"                 #Size at which to rotate log
_cset :log_keep, "10"                       #Keep this many compressed logs
_cset(:log_dir) {File.join(current_path, 'log')}
_cset(:domain) { abort "You need to set the :domain variable, e.g set :domain 'www.example.com'" }
_cset :domain_aliases, nil
_cset :max_age, nil
_cset :user, "rails"
_cset :runner, user
_cset :use_sudo, false
_cset :ssl_certificate, nil
_cset :ssl_intermediate, nil
_cset :ssl_key, nil
_cset :generate_webserver_config, true
_cset :rails_env, "production"
ssh_options[:forward_agent] = true

# Default shared areas
_cset :local_shared_dirs, []
_cset :local_shared_files, []
_cset :global_shared_dirs, []
_cset :global_shared_files, []
_cset(:global_shared_path) { shared_path }
