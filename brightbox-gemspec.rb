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
require File.join(File.dirname(__FILE__),"lib/brightbox/version")
def add_common(spec)
  spec.version = Brightbox::VERSION
  spec.authors = ["John Leach","Neil Wilson","David Smalley", "Caius Durling"]
  spec.email = "support@brightbox.co.uk"
  spec.homepage = "http://wiki.brightbox.co.uk/docs:thebrightboxgem"
  spec.rubyforge_project = 'brightbox'
  spec.has_rdoc = false
end

@server = Gem::Specification.new do |s|
  add_common(s)
  s.name = "brightbox-server-tools"
  s.files = FileList["LICENSE", "Rakefile", "*.rb", "bin/railsapp-*","lib/**/*.{rb,gz}"].exclude(/recipe/).to_a
  s.summary = "Brightbox Server configuration scripts"
  s.executables = FileList["bin/railsapp-*"].sub(/bin\//,'')
end

@client = Gem::Specification.new do |s|
  add_common(s)
  s.name = "brightbox"
  s.files = FileList["LICENSE", "Rakefile", "*.rb", "lib/**/*.rb","bin/brightbox"].exclude("lib/brightbox/webserver-common.rb").to_a
  s.add_dependency("capistrano", ">= 2.5")
  s.summary = "Brightbox rails deployment scripts for Capistrano"
  s.executable = 'brightbox'
end

