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

require 'rubygems'
require 'yaml'
require 'ini'

module Brightbox
  module DatabaseYml
  end
end

class Brightbox::DatabaseYml::Mysql
  attr_reader :errors

  def initialize(appname, filename)
    @filename = filename.to_s
    @appname = appname.to_s
    @errors = []
    load_my_cnf_ini
    load_database_yml
    generate_entries
  end

  def changed?
    @dbconfig != @dborg
  end

  def dump(open_file)
    YAML.dump(@dbconfig,open_file)
  end

private
  def load_database_yml
    if filename_is_missing_but_writable?
      @dbconfig = {}
      @dborg = {}
    else
      @dbconfig = YAML.load_file(@filename)
      @dborg = YAML.load_file(@filename)
    end
  end

  #File.writable? doesn't work unless the file exists
  def filename_is_missing_but_writable?
    !File.exists?(@filename) && 
      begin
        File.open(@filename, 'a')
        File.unlink(@filename)
        true
      rescue Errno
        false
      end
  end


  def generate_entries
    #We must have production as a minimum
    @dbconfig["production"] ||= {}
    sqlreadwrite_mysql_environments.each do |env|
      augment_entry(env)
      check_entry(env)
    end
  end

  def augment_entry(env)
    @dbconfig[env] ||= {}
    entry = @dbconfig[env] 
    entry["adapter"] = "mysql"
    entry["host"] = "sqlreadwrite.brightbox.net"
    entry["username"] ||= @mycnf["user"]
    entry["password"] ||= @mycnf["password"]
    entry["database"] ||= "#{entry["username"]}_#{@appname}_#{env}" 
  end

  def check_entry(env)
    ref = @dbconfig[env]
    @errors <<
      "Database Username missing in #{env} section" unless ref["username"]
    @errors <<
      "Database Password missing in #{env} section" unless ref["password"]
    @errors <<
      "Database name is incorrect in #{env} section.\nMust start with #{ref["username"]}" if ref["database"] !~ /\A#{ref["username"]}_/
  end

  def sqlreadwrite_mysql_env?(environment)
    (
      environment["adapter"].nil? ||
      environment["adapter"] == "mysql"
    ) && (
      environment["host"].nil? ||
      environment["host"] == "sqlreadwrite.brightbox.net"
    )
  end

  def sqlreadwrite_mysql_environments
    @dbconfig.keys.select do |key|
      ref = @dbconfig[key] || {}
      sqlreadwrite_mysql_env?(ref)
    end 
  end

  def load_my_cnf_ini
    @mycnf = Ini.load(self.class.mysql_config_file)[:client]
  end

  def self.mysql_config_file
    File.join(ENV['HOME'], '.my.cnf')
  end


end
