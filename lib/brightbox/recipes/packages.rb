before "gems:install", "packages:install"

namespace :packages do

  def install_package name
    run %Q{dpkg-query --show -f '${Status}' #{name} 2>/dev/null|egrep -q "^install ok installed$" || sudo -p '#{sudo_prompt}' apt-get install -qy #{name}}
  end

  def package_dependencies?
    matches = (fetch(:dependencies,{})[:remote]||{})[:match] || []
    # Because we're given the entire dpkg-query command back, pull out just the package name
    matches.select {|x| x.first[/dpkg-query --show -f '\$\{Status\}'/] }.map {|x| x.first[/\-\- (.+)$/, 1] }
  end

  def install_packages
    deps = package_dependencies?
    puts "Updating apt-get"
    sudo "apt-get update -qy >/dev/null"
    deps.each do |pkg|
      name = pkg
      puts "Checking for #{name}"
      install_package(name)
    end
  end

  desc %Q{
  [internal]Run the packages install task in the application.
  }
  task :install, :except => {:no_release => true} do
    puts "Checking required packages are installed"
    install_packages
  end

end