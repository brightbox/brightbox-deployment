require 'rake/gempackagetask'
require "brightbox-gemspec.rb"

namespace :client do
  Rake::GemPackageTask.new(@client).define

  task :default => [:reinstall, :clobber_package]

  desc "Reinstall the client gem locally"
  task :reinstall => [:repackage] do
    begin
      sh %Q{sudo gem uninstall -x -v #{@client.version} #{@client.name} }
    rescue RuntimeError => e
      puts "Gem not installed, continuing."
    end
    
    sh %Q{sudo gem install pkg/#{@client.name}-#{@client.version}.gem}
  end

end

namespace :server do
  Rake::GemPackageTask.new(@server).define
end

task :clobber_package => "client:clobber_package"
task :package => ["client:package", "server:package"]
task :repackage => ["client:repackage", "server:package"]
