require 'brightbox/recipes'
## Created with the brightbox command on <%= Time.now %>

# The name of your application.  Used for deployment directory and filenames
# and Apache configs. Should be unique on the Brightbox
set :application, "<%= singular_name %>"

# Login user for ssh on your Brightbox server(s)
set :user, "rails"

# Target directory for the application on the web and app servers.
set :deploy_to, "/home/rails/#{application}"

# Primary domain name of your application. Used in the Apache configs
set :domain, "<%= domain_name %>"
# Comma separated list of additional domains for Apache
set :domain_aliases, ""

# URL of your source repository. This is the default one that comes on 
# every Brightbox, you can use your own (we'll let you :)
set :repository, "svn+ssh://rails@<%= server %>/home/rails/subversion/<%= singular_name %>/trunk"

# set :scm, :subversion
# set :scm_username, "rails"
# set :scm_password, "mysecret"

role :web, "<%= server %>"
role :app, "<%= server %>"
role :db,  "<%= server %>", :primary => true

set :use_sudo, false

set :mongrel_host, "127.0.0.1"
set :mongrel_port, 9200
set :mongrel_servers, 2
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

## Logrotation
# Where the logs are stored
set :log_dir, "#{deploy_to}/shared/log"
# The size at which to rotate a log
set :log_max_size, "100M"
# How many old compressed logs to keep
set :log_keep, "10"

# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

ssh_options[:forward_agent] = true
ssh_options[:port] = 22
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)


