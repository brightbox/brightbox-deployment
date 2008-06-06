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

namespace :db do

  desc %Q{
  [internal]Create the database if it doesn't exist
  }
  task :create, :roles => :db, :only => { :primary => true } do
    run rake_task("db:create")
  end

  namespace :check do
    desc %Q{
    [internal]Check the database configuration to make sure that
    it conforms to the Brightbox standard
    }
    task :config, :roles => :db, :only => {:primary => true} do
      run rake_task("db:check:config")
    end
  end

end
