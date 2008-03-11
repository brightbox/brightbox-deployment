Capistrano.configuration(:must_exist).load do

namespace :apache do
  desc "Reload Apache on your Brightbox web servers"
  task :reload, :roles => :web do
    sudo "/usr/sbin/apache2ctl -t"
    sudo "/usr/sbin/apache2ctl graceful"
  end

  desc "Create Apache config for this app on your Brightbox web servers"
  task :setup, :roles => :web do
    sudo "/usr/bin/brightbox-apache -n #{application} -d #{domain} -a #{domain_aliases} -w #{current_path}/public -h #{mongrel_host} -p #{mongrel_port} -s #{mongrel_servers}"
    sudo "/usr/sbin/apache2ctl -t"
  end

end

namespace :mongrel do
  desc "Configure monit to handle the mongrel servers for this app"
  task :configure_cluster, :roles => :app do
    sudo "/usr/bin/brightbox-monit -n #{application} -r #{current_path} -p #{mongrel_port} -s #{mongrel_servers} -h #{mongrel_host}"
  end

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

namespace :monit do
  desc "Display the monit status summary"
  task :status, :roles => :app do
    sudo "/usr/sbin/monit -g #{application} status"
  end

  desc "Reload the monit daemon"
  task :reload, :roles => :app do
    sudo "/usr/sbin/monit reload"
  end
end

desc "Deploy the app to your Brightbox servers for the FIRST TIME.  Sets up Apache config, creates MySQL database and starts Mongrel."
deploy.task :cold do
  transaction do
    deploy.update_code
    deploy.symlink
  end

  mysql.create_database
  migrate
  mongrel.configure_cluster
  monit.reload
  mongrel.start_cluster
  apache.setup
  apache.reload
end

desc "Deploy the app to your Brightbox servers"
deploy.task :default do
  transaction do
    deploy.update_code
    web.disable
    mongrel.stop_cluster
    symlink
    mongrel.start_cluster
  end

  web.enable
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
    set :db_adapter, db_config["production"]["adapter"]
    set :db_user, db_config["production"]["username"]
    set :db_password, db_config["production"]["password"] 
    set :db_name, db_config["production"]["database"]
    set :db_host, db_config["production"]["host"]
end

end
