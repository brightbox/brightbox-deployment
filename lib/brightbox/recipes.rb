require 'mongrel_cluster/recipes'
Capistrano.configuration(:must_exist).load do

namespace :apache do
  desc "Reload Apache on your Brightbox web servers"
  task :reload, :roles => :web do
    
    sudo "/usr/sbin/apache2ctl graceful"
  end

  desc "Create Apache config for this app on your Brightbox web servers"
  task :configure, :roles => :web do
    sudo "/usr/bin/brightbox-apache -n #{application} -d #{domain} -a #{domain_aliases} -w #{current_path}/public -h #{mongrel_host} -p #{mongrel_port} -s #{mongrel_servers}"
  end
  
  desc "Restart Apache on your Brightbox web servers"
  task :restart, :roles => :web do
    apache.check_config
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
    sudo "/usr/bin/brightbox-logrotate -n #{application} -l #{log_dir} -s #{log_max_size} -k #{log_keep}"
  end
end

namespace :monit do
  desc "Configure monit to handle the mongrel servers for this app"
  task :configure, :roles => :app do
    sudo "/usr/bin/brightbox-monit -n #{application} -r #{current_path} -p #{mongrel_port} -s #{mongrel_servers} -h #{mongrel_host}"
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
  end

  namespace :mongrel
    desc "Restart the mongrel servers using monit"
    task :restart_cluster, :roles => :app do
      sudo "/usr/sbin/monit -g #{application} restart all"
    end

    desc "Start the mongrel servers using monit"
    task :start_cluster, :roles => :app do
      sudo "/usr/sbin/monit -g #{application} start all"
    end

    desc "Stop the mongrel servers using monit"
    task :stop_cluster, :roles => :app do
      sudo "/usr/sbin/monit -g #{application} stop all"
    end
  end
end

desc "Deploy the app to your Brightbox servers for the FIRST TIME.  Sets up Apache config, creates MySQL database and starts Mongrel."
deploy.task :cold do
  transaction do
    deploy.update_code
    deploy.symlink
  end

  mysql.create_database # Keeps going if this fails
  load_schema
  migrate
  apache.configure
  apache.reload  
  mongrel.configure_cluster
  monit.configure
  monit.reload
  monit.mongrel.start_cluster
  logrotation.configure
end

desc "Create all the configs on the Brightbox (overwriting any existing) - does not restart services"
deploy.task :reconfigure do
  mongrel.configure_cluster
  monit.configure
  apache.configure
  logrotation.configure
end

desc "Fully restarts all services - will affect other apps on the the box "
deploy.task :full_restart do
  mongrel.restart_cluster  
  apache.restart
  monit.restart
end

desc "Deploy the app to your Brightbox servers"
deploy.task :default do
  transaction do
    deploy.update_code
    web.disable
    symlink
    monit.mongrel.restart_cluster
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
    monit.mongrel.restart_cluster
  end

  web.enable
end

desc "Load the rails db schema on the primary db server - WILL WIPE EXISTING TABLES"
task :load_schema, :roles => :db, :primary => true do
  set(:confirm) do
    Capistrano::CLI.ui.ask "load_schema will WIPE any existing tables in your database, type yes if you are you sure: "
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
          logger.info data, "[database on #{channel[:host]} asked for password]"
          channel.send_data "#{db_password}\n" 
        end
      end
    end
  end
end
  
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
