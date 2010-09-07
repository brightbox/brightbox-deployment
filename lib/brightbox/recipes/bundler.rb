#    Brightbox - Easy Ruby Web Application Deployment
#    Copyright (C) 2010 John Leach
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

after "gems:install", "bundler:install"
depend :remote, :gem, "bundler", ">=1.0.0"

namespace :bundler do

  _cset(:bundle_dir) { File.join(shared_path, "bundle") }
  _cset(:bundle_gemfile) { File.join(latest_release, "Gemfile") }
  _cset(:bundle_without, "development test")
  _cset(:bundle_flags, "--deployment")
  # Set :bundle_disable to true to prevent us from running bundler,
  # even if we detect a Gemfile
  _cset(:bundle_disable, false)
  # Set :bundle_force to true to run bundler even if we can't see a
  # Gemfile
  _cset(:bundle_force, false)
  _cset(:bundle_symlink, true)

  desc "[internal]Install the bundler gem on the server"
  task :install_bundler, :except => {:no_release => true} do
    puts "Checking for bundler gem"
    gems.install_gem("bundler", ">= 1.0.0" )
  end
  
  desc %Q{
  [internal]Install the gems specified by the Gemfile or Gemfile.lock using bundler
  }
  task :install, :except => {:no_release => true} do    
    install_cmd = "(bundle install --gemfile #{bundle_gemfile} "
    install_cmd << "--path #{bundle_dir} #{bundle_flags} "
    install_cmd << "--without #{bundle_without} "
    install_cmd << "&& ln -sf #{bundle_dir} #{File.join(latest_release, "vendor")}" if fetch(:bundle_symlink)
    install_cmd << ")"
    if fetch(:bundle_disable)
      puts "Skipping bundler install as :bundle_enable is set to false"
    elsif fetch(:bundle_force)
      puts "Forcing bundler install as :bundle_force is set to true"
      run install_cmd
    else
      run "if [ -e #{bundle_gemfile} ] ; then #{install_cmd} ; else true ; fi"
    end
  end

  desc %Q{
  [internal]Determine whether the requirements for your application are installed and available to bundler
  }
  task :check, :except => {:no_release => true} do
    run "bundle check --gemfile #{bundle_gemfile}"
  end

end
