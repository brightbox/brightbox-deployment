#    Brightbox - Easy Ruby Web Application Deployment
#    Copyright (C) 2008, Neil Wilson, Brightbox Systems
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

namespace :gems do
  
  desc "[internal]Install the matching brightbox-server-tools gem for this client gem version"
  task :check_server_tools, :except => {:no_release => true} do
    puts "Checking for brightbox-server-tools at #{::Version}"
    install_gem("brightbox-server-tools", ::Version)
  end
  
  def install_gem(gem, version)
    sudo %Q{sh -c "
      gem spec #{gem} --version '#{version}' 2>/dev/null|egrep -q '^name:' ||
        sudo gem install --no-ri --no-rdoc --version '#{version}' #{gem}"
    }
  end
  

  def gem_dependencies?
    (fetch(:dependencies,{})[:remote]||{})[:gem]
  end

  def install_gems
    deps = gem_dependencies?
    deps.each do |gemspec|
      gem = gemspec[0]
      version = gemspec[1]
      puts "Checking for #{gem} at #{version}"
      install_gem(gem, version)
    end
  end

  desc %Q{
  [internal]Run the gems install task in the application.
  }
  task :install, :except => {:no_release => true} do
    if gem_dependencies?
      install_gems
      sudo rake_task("gems:install")
    else
      sudo rake_task("gems:install")
    end
  end

end
