#  Brightbox - Easy Ruby Web Application Deployment
#  Copyright (C) 2008, Neil Wilson, Brightbox Systems
#
#  This file is part of the Brightbox deployment system
#

Dir[File.join(File.dirname(__FILE__), 'recipes/*.rb')].each do |recipe|
  Capistrano::Configuration.instance(true).load recipe
end
