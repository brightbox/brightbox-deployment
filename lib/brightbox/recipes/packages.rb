before "gems:install", "packages:install"

namespace :packages do

  _cset(:packages_install, true)

  def install_package name
    run %Q{dpkg-query --show -f '${Status}' #{name} 2>/dev/null|egrep -q "^install ok installed$" || #{sudo} apt-get install -qy #{name}}
  end

  def package_dependencies?
    matches = (fetch(:dependencies,{})[:remote]||{})[:match] || []
    # Because we're given the entire dpkg-query command back, pull out just the package name
    matches.select {|x| x.first[/dpkg-query --show -f '\$\{Status\}'/] }.map {|x| x.first[/\-\- (.+)$/, 1] }
  end

  def install_packages
    deps = package_dependencies?
    if deps.empty?
      logger.info "Skipping, no packages defined for installation"
    else
      logger.info "Updating package information with apt-get"
      run "#{sudo} apt-get update -qy >/dev/null"
      deps.each do |pkg|
        name = pkg
        logger.info "Checking for package #{name}"
        install_package(name)
      end
    end
  end

  desc %Q{
  [internal]Run the packages install task in the application.
  }
  task :install, :except => {:no_release => true, :packages_install => false}, :on_no_matching_servers => :continue do
    if fetch(:packages_install)
      install_packages
    else
      logger.info "Skipping packages:install as :packages_install is set to false"
    end
  end

end
