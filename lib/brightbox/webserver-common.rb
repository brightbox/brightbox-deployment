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
require 'optparse'
require 'fileutils'
require 'brightbox/version'

@mongrelhost = "127.0.0.1"
@mongrels = 2
@port = 9200
@aliases = nil
@certificate = nil
@key_file = nil
@maxage = 315360000

def has_required_options?
  [@application, @webroot, @domain].all? &&
    (@certificate || @certificate_key.nil?)
end

def certificate_file
  return @certificate if File.file?(@certificate)
  cert_base = File.basename(@certificate, File.extname(@certificate))
  test_path = File.join('','etc','ssl','certs', cert_base + '.*')
  candidates = Dir[test_path]
  if candidates.empty?
    abort "#{@opts.program_name}: Unable to find certificate file for #{cert_base}"
  end
  result = candidates.pop
  unless candidates.empty?
    abort "#{@opts.program_name}: #{cert_base} resolves to more than one file. Please be more specific"
  end
  result
end

def key_file
  if @certificate_key
    return @certificate_key if File.file?(@certificate_key)
    key_base = File.basename(@certificate_key, File.extname(@certificate_key))
  else
    key_base = File.basename(@certificate, File.extname(@certificate))
  end
  test_path = File.join('','etc','ssl','private', key_base + '.*')
  candidates = Dir[test_path]
  return nil if candidates.empty?
  result = candidates.pop
  unless candidates.empty?
    abort "#{@opts.program_name}: #{key_base} resolves to more than one file. Please be more specific"
  end
  result
end

def intermediate_cert_file
  return @intermediate_cert if File.file?(@intermediate_cert)
  cert_base = File.basename(@intermediate_cert, File.extname(@intermediate_cert))
  test_path = File.join('','etc','ssl','certs', cert_base + '.*')
  candidates = Dir[test_path]
  if candidates.empty?
    abort "#{@opts.program_name}: Unable to find certificate file for #{cert_base}"
  end
  result = candidates.pop
  unless candidates.empty?
    abort "#{@opts.program_name}: #{cert_base} resolves to more than one file. Please be more specific"
  end
  result
end

@opts = OptionParser.new do |opts|
  opts.banner = "#{opts.program_name} creates an #{WEBSERVER} config for a Rails app\n#{opts.banner}"

  opts.on("-n APPLICATION_NAME", "--name APPLICATION_NAME",
    "Name of application (a short useful",
    "name for the app such as 'myforum')"
  ) { |value| @application = value }
  
  opts.on("-w", "--webroot WEB_ROOT",
    "Full path to web root",
    "(e.g: /home/rails/myforum/current/public)"
  ) { |value| @webroot = value }
  
  opts.on("-d", "--domain DOMAIN_NAME",
    "Domain name for application",
    "(e.g: www.example.com)"
  ) { |value| @domain = value }
  
  opts.on("-a", "--aliases ALIASES",
    "Aliases for domain name, comma separated",
    "(e.g: www.example.org,www.example.net)"
  ) { |value| @aliases = value.to_s.split(',').join(' ')}
  
  if WEBSERVER == "apache2"
    
    opts.on("-r", "--passenger",
      "Use phusion passenger (Apache only)",
      "(Will ignore any mongrel values passed)"
    ) { |value| @passenger = value }
    
    opts.on("-e", "--railsenv ENV",
      "Set RailsEnv for passenger (Apache only)"
    ) { |value| @rails_env = value }
    
  end
  
  opts.on("-p", "--port MONGREL_PORT", Integer,
    "Port of the first mongrel service",
    "(default: #{@port})"
  ) { |value| @port = value.to_i }
  
  opts.on("-s", "--servers MONGRELS", Integer,
    "Number of mongrel servers running",
    "(default: #{@mongrels})"
  ) { |value| @mongrels = value.to_i }
  
  opts.on("-h", "--mongrelhost MONGREL_HOST",
    "ip/host where mongrel is running",
    "(default: #{@mongrelhost})"
  ) { |value| @mongrelhost = value }

  opts.on("-c", "--ssl-cert CERTIFICATE_NAME",
          "create an SSL configuration",
          "using CERTIFICATE_NAME"
         ) { |value| @certificate = value }

  opts.on("-k", "--ssl-key KEY_NAME",
          "Name of private key to use CERTIFICATE"
         ) { |value| @certificate_key = value }

  # Optional
  opts.on("-i", "--ssl-cert-intermediate INTERMEDIATE_NAME",
          "name of intermediate certificate"
          ) { |value| @intermediate_cert = value }

  opts.on("-m", "--max-age MAX_AGE",
          "Number of seconds to keep static assets","in cache",
          "(default: #{@maxage})"
         ) { |value| @maxage = value }
 
  begin
    opts.parse(ARGV)
    raise OptionParser::ParseError,
      "You must supply the required arguments" unless has_required_options?
  rescue OptionParser::ParseError => e
    warn e.message
    puts opts
    exit 1
  end
  if @certificate
    @certificate_file = certificate_file
    @key_file = key_file
    # Intermediate is optional
    @intermediate_cert = intermediate_cert_file if @intermediate_cert
  end
end

def configure_site(site_name)
  webserver_config = File.join('','etc', WEBSERVER)
  appfile = "rails-#{site_name}"

  sites_available = File.join(webserver_config, 'sites-available')
  sites_enabled = sites_available.sub("available", "enabled")
  sites_archived = sites_available.sub("available", "archived")

  filename = File.join(sites_available, appfile)
  archivefile = File.join(sites_archived, appfile + "." + Time.now.strftime('%y%m%d%H%M%S'))
  enablelink = File.join(sites_enabled, appfile)
  FileUtils.mkdir_p(sites_available)
  FileUtils.mkdir_p(sites_enabled)

  if File.exists?(filename)
    FileUtils.mkdir_p(sites_archived)
    FileUtils.cp filename, archivefile
  end

  File.open(filename, "w") { |f| f.write @config }
  FileUtils.ln_s(filename, enablelink, :force => true)
end

def config_time_stamp
  "# Created by #{@opts.program_name} at #{Time.now}"
end

def local_app_alias
  @local_app_alias ||= @application+"."+`hostname`.chomp
end
