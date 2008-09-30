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

  def mongrel_command
    "/usr/bin/mongrel_rails"
  end
  depend :remote, :command, mongrel_command

  def monit_command
    "/usr/sbin/monit"
  end
  depend :remote, :command, monit_command

  def mongrel_cluster_command(event)
    "#{mongrel_command} cluster::#{event} -C #{mongrel_config_file}" <<
    if event == "status"
      ""
    else
      " --clean"
    end
  end

  def monitor_cluster_command(event)
    case event
    when "start","restart"
      "#{monit_command} -g #{application} monitor all"
    when "stop"
      "#{monit_command} -g #{application} unmonitor all"
    else
      nil 
    end
  end

  #Override start, stop and restart so that they use mongrel to restart the
  #application servers
  %w(start stop restart status).each do |event|
    desc "Ask mongrel to #{event} your application."
    task event, :roles => :app, :except => {:no_release => true } do
      try_sudo mongrel_cluster_command(event)
      if cmd = monitor_cluster_command(event)
        sudo cmd
      end
    end
  end

  namespace :web do

    desc %Q{
      Reload the webserver
    }
    task :reload, :roles => :web, :except => {:no_release => true } do
      %w(apache2 nginx).each do |webserver|
        initscript = "/etc/init.d/#{webserver}"
        sudo %Q{
          sh -c '[ -f #{initscript} ] && #{initscript} reload || true'
        }
      end
    end

    desc %Q{
    [internal]reload web server if first release
    }
    task :reload_if_new, :roles => :web, :except => {:no_release => true} do
      reset! :releases
      reload if releases.length == 1
    end

    def maintenance_page
      "#{current_path}/public/system/maintenance.html"
    end

    desc %Q{
      Return a 503 Service Temporarily Unavailable error code and display \
      the 'system maintenance' page.
    }
    task :disable, :roles => :web, :except => { :no_release => true } do
      on_rollback {
        run "rm #{maintenance_page}"
      }
      run "ln -s #{File.dirname(maintenance_page)}/index.html #{maintenance_page}"
    end

    desc %Q{
      Makes the application web-accessible again. Removes the link \
      to the maintenance area.
    }
    task :enable, :roles => :web, :except => { :no_release => true } do
      run "rm #{maintenance_page}"
    end


  end

  namespace :monit do

    desc %Q{
      Reload monit
    }
    task :reload do
      sudo "#{monit_command} reload"
    end

  end

  desc %Q{Setup the directories and deploy the initial version of the
  application
  }
  task :initial do
    setup
    cold
  end

  namespace :rake_tasks do

    desc %Q{
      Execute Rake tasks that need to be run once per system
    }
    task :singleton, :roles => :db, :only => {:primary => true} do
      run rake_task("db:check:config")
      run rake_task("db:create")
    end

    desc %Q{
      Execute Rake tasks that need to be run on all deployments
    }
    task :global, :except => {:no_release => true} do
      gems.install
    end

    desc %Q{
      Execute Rake tasks
    }
    task :default do
      singleton
      global
    end
  end

end
