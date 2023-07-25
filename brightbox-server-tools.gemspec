#    Brightbox - Easy Ruby Web Application Deployment
#    Copyright (C) 2013, Neil Wilson, John Leach, Brightbox Systems
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
require 'rake'

Gem::Specification.new do |s|
  s.name = "brightbox-server-tools"
  s.version = Brightbox::VERSION
  s.authors = ["John Leach","Neil Wilson","David Smalley","Caius Durling","Ben Arblaster"]
  s.email = "support@brightbox.com"
  s.homepage = "https://brightbox.com"
  s.licenses = "AGPL-3.0-only"
  s.files = FileList["LICENSE", "*.rb", "bin/railsapp-*","lib/**/*.{rb,gz}"].exclude(/recipe/).to_a
  s.add_dependency("bundler", ">= 1.0")
  s.summary = "Brightbox Server configuration scripts"
  s.executables = FileList["bin/railsapp-*"].sub(/bin\//,'')
end

