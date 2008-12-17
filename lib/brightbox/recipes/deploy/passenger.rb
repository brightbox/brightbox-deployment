namespace :deploy do
  
  #Override start and stop, they are useless for passenger
  %w(start stop).each do |event|
    desc "Dummy command to #{event} your application. This is not needed when using passenger."
    task event, :roles => :app, :except => {:no_release => true } do
    end
  end
  
  desc "Restart your application using passenger."
  task :restart, :roles => :app, :except => {:no_release => true} do
    try_sudo "touch #{current_path}/tmp/restart.txt"
  end
  
end