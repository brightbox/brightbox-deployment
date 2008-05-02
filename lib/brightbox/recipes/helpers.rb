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
  rake = fetch(:rake, "rake")
  rails_env = fetch(:rails_env, "production")
  rake_env = fetch(:rake_env, "")
  directory = current_release 

  run "cd #{directory}; #{rake} RAILS_ENV=#{rails_env} #{rake_env} #{taskname}"
end

def execute_on_one_line(cmd_list)
  cmd_list.gsub!(/\n/m, ' ')
  invoke_command cmd_list, :via => fetch(:run_method, :sudo)
end


