require 'mongrel_cluster/recipes'
Capistrano::Configuration.instance(true).load do

set :rails_env, "production"  
set :rake, "/usr/bin/rake"
set :mongrel_pid_file, "log/mongrel.pid"

# The size at which to rotate a log
set :log_max_size, "100M"
# How many old compressed logs to keep
set :log_keep, "10"

namespace :apache do
  desc "Reload Apache on your Brightbox web servers"
  task :reload, :roles => :web do 
    sudo "/usr/sbin/apache2ctl graceful"
  end

  desc "Create Apache config for this app on your Brightbox web servers"
  task :configure, :roles => :web do
    sudo "/usr/bin/brightbox-apache -n #{fetch(:application)} -d #{fetch(:domain)} -a '#{fetch(:domain_aliases)}' -w #{fetch(:current_path)}/public -h #{fetch(:mongrel_host)} -p #{fetch(:mongrel_port)} -s #{fetch(:mongrel_servers)}"
  end
  
  desc "Restart Apache on your Brightbox web servers"
  task :restart, :roles => :web do
    sudo "/etc/init.d/apache2 restart"
  end
  
  desc "Checks the Apache configuration for errors"
  task :check_config, :roles => :web do
    sudo "/usr/sbin/apache2ctl -t"
  end

end

namespace :logrotation do
  desc "Configure log rotation for this app"
  task :configure, :roles => :app do
    sudo "/usr/bin/brightbox-logrotate -n #{fetch(:application)} -l #{fetch(:log_dir)} -s #{fetch(:log_max_size)} -k #{fetch(:log_keep)}"
  end
end

namespace :monit do
  
  desc "Configure monit to manage this app"
  task :configure, :roles => :app do
    mongrel.cluster.confgure
  end

  
  desc "Display the monit status summary"
  task :status, :roles => :app do
    sudo "/usr/sbin/monit status"
  end

  desc "Reload the monit daemon"
  task :reload, :roles => :app do
    sudo "/usr/sbin/monit reload"
    sleep 5
  end
  
  desc "Restart the monit daemon"
  task :restart, :roles => :app do
    sudo "/etc/init.d/monit restart"
    sleep 5
  end

  namespace :mongrel do
    namespace :cluster do
      desc "Restart the mongrel servers using monit"
      task :restart, :roles => :app do
        sudo "/usr/sbin/monit -g #{fetch(:application)} restart all"
      end

      desc "Start the mongrel servers using monit"
      task :start, :roles => :app do
        sudo "/usr/sbin/monit -g #{fetch(:application)} start all"
      end

      desc "Stop the mongrel servers using monit"
      task :stop, :roles => :app do
        sudo "/usr/sbin/monit -g #{fetch(:application)} stop all"
      end
      
      desc "Configure monit to manage the mongrel cluster for this app"
      task :configure, :roles => :app do
        sudo "/usr/bin/brightbox-monit -n #{fetch(:application)} -r #{fetch(:current_path)} -p #{fetch(:mongrel_port)} -s #{fetch(:mongrel_servers)} -h #{fetch(:mongrel_host)}"
      end
    end
  end
end

desc "Deploy the app to your Brightbox servers for the FIRST TIME.  Sets up Apache config, creates MySQL database and starts Mongrel."
deploy.task :cold do
  gems.brightbox.check
  transaction do
    deploy.update_code
    deploy.symlink
  end

  mysql.create_database # Keeps going if this fails
  load_schema # Will prompt for confirmation
  migrate
  apache.configure
  apache.reload  
  mongrel.cluster.configure
  monit.configure
  monit.reload
  monit.mongrel.cluster.start
  logrotation.configure
end

desc "Create all the configs on the Brightbox (overwriting any existing) - does not restart services"
deploy.task :reconfigure do
  gems.brightbox.check
  mongrel.cluster.configure
  monit.configure
  apache.configure
  logrotation.configure
end

desc "Restart the app (Mongrel cluster using monit)" do
deploy.task :restart
  monit.mongrel.cluster.restart
end

desc "Stop the app (Mongrel cluster using monit)" do
deploy.task :stop
  monit.mongrel.cluster.stop
end

desc "Start the app (Mongrel cluster using monit)" do
deploy.task :start
  monit.mongrel.cluster.start
end


desc "Fully restarts all services - will affect other apps on the the box "
deploy.task :full_restart do
  mongrel.cluster.restart
  apache.restart
  monit.restart
end

desc "Deploy the app to your Brightbox servers"
deploy.task :default do
  transaction do
    deploy.update_code
    web.disable
    symlink
    monit.mongrel.cluster.restart
  end

  web.enable
end

desc "Deploy the app to your Brightbox servers and run any outstanding migrations"
deploy.task :migrations do
  transaction do
    deploy.update_code
    web.disable
    symlink
    migrate
    monit.mongrel.cluster.restart
  end

  web.enable
end

desc "Load the rails db schema on the primary db server - WILL WIPE EXISTING TABLES"
task :load_schema, :roles => :db, :primary => true do
  set(:confirm) do
    Capistrano::CLI.ui.ask "  !! load_schema will WIPE ANY EXISTING TABLES in your database, type yes if you are you sure: "
  end
  if confirm == 'yes'
    logger.important "Loading schema"
    run "cd #{current_path} && #{rake} RAILS_ENV=#{(rails_env||"production").to_s} db:schema:load"
  else
    logger.important "Skipping load_schema"
  end
end

namespace :mysql do
  desc "Create the mysql database named in the database.yml on the primary db server"
  task :create_database, :roles => :db, :primary => true do
    read_db_config
    if db_adapter == 'mysql'
      run "mysql -h #{db_host} --user=#{db_user} -p --execute=\"CREATE DATABASE #{db_name}\" || true" do |channel, stream, data|
        if data =~ /^Enter password:/
          logger.info data, "[mysql on #{channel[:host]} asked for password]"
          channel.send_data "#{db_password}\n" 
        end
      end
    end
  end
end

namespace :gems do
  desc "Install the given gem (will prompt)"
  task :install, :roles => :app do
    set(:gems_to_install) do
      Capistrano::CLI.ui.ask "  Gems to install: "
    end
    unless gems_to_install.empty?
      sudo "gem install -y --no-rdoc --no-ri #{gems_to_install}"
    end
  end
  
  namespace :brightbox do
    desc "Check the version of the Brightbox gem on the servers"
    task :check, :roles => :app do
      bb_gem_version = nil
      run "gem list brightbox" do |channel, stream, data|
        if data =~ /^brightbox \(([^ ,]+)/
          bb_gem_version = $1
        end
      end
      if bb_gem_version.nil?
        logger.important "ERROR: Brightbox gem not found on server"
        raise Capistrano::CommandError, "ERROR: Brightbox gem not found on server"
      else
        logger.info "Brightbox gem version #{bb_gem_version} found on server"
      end
    end

      desc "Install the latest Brightbox gem  and it's dependencies on the servers"
    task :install, :roles => [:app, :web] do
      sudo "gem install -y --no-rdoc --no-ri brightbox"
    end    
  end
  
end

# Load the database.yml from the current Rails app
def read_db_config
    db_config = YAML.load_file('config/database.yml')
    set :db_adapter, db_config[(rails_env||"production").to_s]["adapter"]
    set :db_user, db_config[(rails_env||"production").to_s]["username"]
    set :db_password, db_config[(rails_env||"production").to_s]["password"] 
    set :db_name, db_config[(rails_env||"production").to_s]["database"]
    set :db_host, db_config[(rails_env||"production").to_s]["host"]
    if db_host !~ /^sqlreadwrite/
      logger.important "WARNING: Database host is not sqlreadwrite as per the Brightbox requirements"
    end
    if db_name !~ /^#{db_user}\_/
      logger.important "WARNING: Database name is not prefixed with MySQL username as per the Brightbox requirements"
    end
end

end