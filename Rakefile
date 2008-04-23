require 'rake/gempackagetask'
gem_name = "brightbox"
require "#{gem_name}-gemspec.rb"

Rake::GemPackageTask.new(@spec).define

task :default => [:reinstall, :clobber_package]

task :reinstall => [:gem] do
  sh %Q{sudo gem uninstall -x -v #{@spec.version} #{@spec.name} }
  sh %q{sudo gem install pkg/*.gem}
end

