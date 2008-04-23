#  Brightbox - Easy Ruby Web Application Deployment
#  Copyright (C) 2008, Brightbox Systems
#  Written by Neil Wilson, <neil@brightbox.co.uk>
#
#  This file is part of the Brightbox deployment system
#
# Hook tasks into the standard deployment system

after "deploy:setup",
 "configure:logrotation",
 "configure:monit",
 "configure:mongrel",
 "configure:apache",
 "deploy:monit:reload"

before "deploy:update_code",
  "configure:check"

before "deploy:migrate",
  "database:create"

after "deploy:start",
  "deploy:web:reload_if_new"

after "deploy:restart",
  "deploy:web:reload_if_new"
