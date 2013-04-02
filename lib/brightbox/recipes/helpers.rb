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
def rake_task(taskname)
  rake = fetch(:rake)
  rake_env = fetch(:rake_env, "")
  directory = current_release
  # FIXME
  "cd #{directory} ; #{rake} RAILS_ENV=#{rails_env} #{rake_env} #{taskname}"
end

def on_one_line(cmd_list)
  cmd_list.gsub!(/\n/m, ' ')
end

# Override cap's depend method so we can intercept any calls we want to
# ourselves and act upon them.
alias :cap_depend :depend
# Our depend method
def depend location, type, *args
  # So far we only care about :remote, :apt. Intercept only that
  if location == :remote && [:apt].include?(type)
    # "Translate" this into a :match call cap can handle for us.
    cap_depend(:remote, :match, "dpkg-query --show -f '${Status}' -- #{args.first}", /^install ok installed$/)
  else
    # we don't want to interfere with this, send it on it's merry way
    cap_depend(location, type, *args) 
  end
end

# Runs the given block when generating webserver configuration is allowed.
# 
# Basically, runs the block unless "set :generate_webserver_config, false" is in deploy.rb
def run_when_generating_webserver_config_allowed
  if fetch(:generate_webserver_config, true)
    yield if block_given?
  else
    logger.trace "Skipped - Not generating webserver config"
  end
end
