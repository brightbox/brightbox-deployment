#  Brightbox - Easy Ruby Web Application Deployment
#  Copyright (C) 2008, Neil Wilson, Brightbox Systems
#
#  This file is part of the Brightbox deployment system
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

    desc "[internal]reload web server if first release"
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
end
