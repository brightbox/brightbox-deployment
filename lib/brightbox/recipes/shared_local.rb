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
# Manage the local shared area

namespace :deploy do
  namespace :shared do
    namespace :local do

      desc %Q(
      [internal] Creates shared directories. This is called by the setup 
      routine to create the directory structure within the shared area. It
      references two arrays.

       :local_shared_files - the list of files that should be shared
       between releases.
       :local_shared_dirs  - the list of directories that should be
       shared between releases.
      )
      task :setup, :except => {:no_release => true} do
        dirs = local_shared_files.to_a.collect do |file|
          File.join(shared_path, File.dirname(file))
        end
        dirs += local_shared_dirs.to_a.collect do |dir|
          File.join(shared_path, dir)
        end
        try_sudo "umask 02 && mkdir -p #{dirs.join(' ')}" unless dirs.empty?
      end
    
      desc %Q{
      [internal] Sets up the symlinks between the latest release and all
      the shared items described in :local_shared_dirs and
      :local_shared_files
      }
      task :symlink, :except => {:no_release => true} do
        resources = local_shared_dirs.to_a+local_shared_files.to_a
        run %Q{
          cd #{latest_release} &&
          rm -rf #{resources.join(' ')} 
        }
        links = resources.collect do |resource|
          "ln -sf #{File.join(shared_path,resource)} #{File.join(latest_release, resource)}"
        end.join(" && ")
        run links unless links.empty?
      end

    end
  end
end



