before "gems:install", "packages:install"

namespace :packages do

  desc "Install required Ubuntu packages"
  task :install, :roles => :app do
    sudo "apt-get update -qy >/dev/null"
    sudo "apt-get install -qy #{package_dependencies.join(' ')}"
  end 

end