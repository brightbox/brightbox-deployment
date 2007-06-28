require 'brightbox/recipes'

# The name of your application.  Used for deployment directory and filenames
# and apache configs
set :application, "<%= singular_name %>"

# Target directory for the application on the web and app servers.
set :deploy_to, "/home/rails/#{application}"

# Primary domain name of your application.  Used in the Apache configs
set :domain, "<%= domain_name %>"

# Login user for ssh on your Brightbox server
set :user, "rails"

# URL of your source repository - there i
set :repository, "svn+ssh://rails@<%= server %>/home/rails/subversion/<%= singular_name %>/trunk"

role :web, "<%= server %>"
role :app, "<%= server %>"
role :db,  "<%= server %>", :primary => true

set :use_sudo, false

set :mongrel_host, "127.0.0.1"
set :mongrel_port, 9200
set :mongrel_servers, 2
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

