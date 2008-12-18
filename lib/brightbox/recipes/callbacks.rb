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
# Hook tasks into the standard deployment system

# Some mongrel specific callbacks have been moved to configure/mongrel.rb

after "deploy:setup",
  "deploy:shared:global:setup",
  "deploy:shared:local:setup",
  "configure:maintenance",
  "configure:logrotation",
  "configure:apache",
  "configure:nginx"

after "deploy:finalize_update",
  "deploy:shared:global:symlink",
  "deploy:shared:local:symlink",
  "deploy:rake_tasks"

after "deploy:update",
  "deploy:cleanup"

after "deploy:start",
  "deploy:web:reload_if_new"

after "deploy:restart",
  "deploy:web:reload_if_new"
