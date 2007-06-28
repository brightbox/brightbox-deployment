require 'mongrel_cluster/recipes'

Capistrano.configuration(:must_exist).load do

desc "Create apache config for this app on your Brightbox web servers"
task :setup_apache, :roles => :web do
  sudo "/usr/bin/brightbox-apache -n #{application} -d #{domain} -w #{current_path}/public -h #{mongrel_host} -p #{mongrel_port} -s #{mongrel_servers}"
  sudo "/usr/sbin/apache2ctl -t"
end

desc "Reload apache on your Brightbox web servers"
task :reload_apache, :roles => :web do
  sudo "/usr/sbin/apache2ctl -t"
  sudo "/usr/sbin/apache2ctl graceful"
end

desc "Load the rails db schema on the primary db server"
task :load_schema, :roles => :db, :primary => true do
  run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} db:schema:load"
end

desc "Configure monit to handle the mongrel servers for this app"
task :configure_mongrel_cluster, :roles => :app do
  sudo "/usr/bin/brightbox-monit -n #{application} -r #{current_path} -p #{mongrel_port} -s #{mongrel_servers} -h #{mongrel_host}"
end

desc "Restart the mongrel servers using monit"
task :restart_mongrel_cluster, :roles => :app do
  sudo "/usr/sbin/monit -g #{application} restart all"
end

desc "Start the mongrel servers using monit"
task :start_mongrel_cluster, :roles => :app do
  sudo "/usr/sbin/monit -g #{application} start all"
end

desc "Stop the mongrel servers using monit"
task :stop_mongrel_cluster, :roles => :app do
  sudo "/usr/sbin/monit -g #{application} stop all"
end

desc "Display the monit status for this app"
task :monit_status, :roles => :app do
  sudo "/usr/sbin/monit -g #{application} status"
end

desc "Reload the monit daemon"
task :monit_reload, :roles => :app do
  sudo "/usr/sbin/monit reload"
end

desc "Deploy the app to your Brightbox servers for the FIRST TIME.  Sets up apache config starts mongrel."
task :cold_deploy do
  transaction do
    update_code
    symlink
  end

  create_mysql_database
  load_schema
  migrate
  configure_mongrel_cluster
  monit_reload
  start_mongrel_cluster
  setup_apache
  reload_apache
end

desc "Deploy the app to your Brightbox servers"
task :deploy do
  transaction do
    update_code
    disable_web
    stop_mongrel_cluster
    symlink
    start_mongrel_cluster
  end

  enable_web
end

desc "Create the mysql database named in the database.yml on the primary db server"
task :create_mysql_database, :roles => :db, :primary => true do
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
  
def read_db_config
    db_config = YAML.load_file('config/database.yml')
    set :db_adapter, db_config["production"]["adapter"]
    set :db_user, db_config["production"]["username"]
    set :db_password, db_config["production"]["password"] 
    set :db_name, db_config["production"]["database"]
    set :db_host, db_config["production"]["host"]
end

end
