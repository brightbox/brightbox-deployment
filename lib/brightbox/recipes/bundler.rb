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

namespace :bundler do

  _cset(:bundle_dir) { File.join(shared_path, "bundle") }
  _cset(:bundle_gemfile) { File.join(latest_release, "Gemfile") }
  _cset(:bundle_without, "development test")
  _cset(:bundle_flags, "--deployment")
  # Set :bundle_disable to true to prevent us from running bundler,
  # even if we detect a Gemfile
  _cset(:bundle_disable, false)
  # bundle_force is ignored now, bundle is used by default now
  _cset(:bundle_force, false)
  _cset(:bundle_symlink, true)
  _cset(:bundle_cmd, "bundle")

  set(:rake) do
    if fetch(:bundle_disable)
      "rake"
    else
      "#{fetch(:bundle_cmd)} exec rake"
    end
  end

  depend :remote, :command, fetch(:bundle_cmd)

  desc "[internal]Install the bundler gem on the server"
  task :install_bundler, :except => {:no_release => true} do
    gems.install_gem("bundler", ">= 1.3.0" )
  end

  desc %Q{
  [internal]Install the gems specified by the Gemfile or Gemfile.lock using bundler
  }
  task :install, :except => {:no_release => true} do
    install_cmd = "(cd #{latest_release} && #{bundle_cmd} install --gemfile #{bundle_gemfile} "
    install_cmd << "--quiet "
    install_cmd << "--path #{bundle_dir} #{bundle_flags} "
    install_cmd << "--without #{bundle_without} "
    install_cmd << "--disable-shared-gems "
    install_cmd << "&& ln -sf #{bundle_dir} #{File.join(latest_release, "vendor")}" if fetch(:bundle_symlink)
    install_cmd << ")"
    if fetch(:bundle_disable)
      logger.info "Skipping bundler install as :bundle_enable is set to false"
    else
      run install_cmd
    end
  end

  desc %Q{
  [internal]Determine whether the requirements for your application are installed and available to bundler
  }
  task :check, :except => {:no_release => true} do
    run "cd #{latest_release} && #{bundle_cmd} check --gemfile #{bundle_gemfile}"
  end

end
