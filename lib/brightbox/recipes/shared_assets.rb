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
# Manage the shared areas

namespace :deploy do
  namespace :shared do

      def fetch_shared_dirs(shared_files, shared_dirs, shared_path) 
        dirs = shared_files.to_a.collect do |file|
          File.join(shared_path, File.dirname(file))
        end
        dirs += shared_dirs.to_a.collect do |dir|
          File.join(shared_path, dir)
        end
      end

      def setup_shared_dirs(shared_files, shared_dirs, shared_path)
        dirs = fetch_shared_dirs(shared_files, shared_dirs, shared_path)
        try_sudo "umask 02 && mkdir -p #{dirs.join(' ')}" unless dirs.empty?
      end

      def create_shared_links(shared_files, shared_dirs, shared_path) 
        resources = shared_dirs.to_a+shared_files.to_a
        run %Q{
          cd #{latest_release} &&
          rm -rf #{resources.join(' ')} 
        }
        links = resources.collect do |resource|
          "ln -sf #{File.join(shared_path,resource)} #{File.join(latest_release, resource)}"
        end.join(" && ")
        run links unless links.empty?
      end

    namespace :local do

      desc %Q(
      [internal] Creates shared directories. This is called by the setup 
      routine to create the directory structure within the shared area
      referenced by :shared_path. It references two arrays.

       :local_shared_files - the list of files that should be shared
       between releases.
       :local_shared_dirs  - the list of directories that should be
       shared between releases.
      )
      task :setup, :except => {:no_release => true} do
        setup_shared_dirs(local_shared_files, local_shared_dirs, shared_path)
      end
    
      desc %Q{
      [internal] Sets up the symlinks between the latest release and all
      the shared items described in :local_shared_dirs and
      :local_shared_files
      }
      task :symlink, :except => {:no_release => true} do
        create_shared_links(local_shared_files, local_shared_dirs, shared_path)
      end
    end

    namespace :global do

      desc %Q(
      [internal] Creates shared directories in the global area referenced
      by :global_shared_path. This is called by the setup routine to
      create the directory structure within the shared area. It references
      two arrays.

       :global_shared_files - the list of files that should be shared
       between all releases on all servers.
       :global_shared_dirs  - the list of directories that should be
       shared between all releases on all servers.
      )
      task :setup, :except => {:no_release => true} do
        setup_shared_dirs(global_shared_files, global_shared_dirs, global_shared_path)
      end
    
      desc %Q{
      [internal] Sets up the symlinks between the latest release and all
      the shared items described in :global_shared_dirs and
      :global_shared_files
      }
      task :symlink, :except => {:no_release => true} do
        create_shared_links(global_shared_files, global_shared_dirs, global_shared_path)
      end


    end
  end
end



