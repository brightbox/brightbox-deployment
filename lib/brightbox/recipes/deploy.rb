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
# Override standard tasks that don't do what we want

namespace :deploy do

  def monit_command
    "/usr/sbin/monit"
  end
  depend :remote, :command, monit_command

  #Override start, stop and restart so that they use Monit to restart the
  #application servers
  %W(start stop restart).each do |event|
    desc "Ask monit to #{event} your application."
    task event, :roles => :app, :except => {:no_release => true } do
      invoke_command "#{monit_command} -g #{application} #{event} all",
        :via => fetch(:run_method, :sudo)
    end
  end

  namespace :web do

    desc %Q{
      Reload the apache webserver
    }
    task :reload, :roles => :web, :except => {:no_release => true } do
      invoke_command "/usr/sbin/invoke-rc.d apache2 reload", 
        :via => fetch(:run_method, :sudo)
    end

    desc %Q{
    [internal]reload web server if first release
    }
    task :reload_if_new, :roles => :web, :except => {:no_release => true} do
      reset! :releases
      reload if releases.length == 1
    end

  end

  namespace :monit do

    desc %Q{
      Reload monit
    }
    task :reload do
      invoke_command "#{monit_command} reload",
        :via => fetch(:run_method, :sudo)
    end

  end

  desc %Q{Setup the directories and deploy the initial version of the
  application
  }
  task :initial do
    setup
    cold
  end

end
