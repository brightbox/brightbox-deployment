@spec = Gem::Specification.new do |s| 
  s.name = "brightbox"
  s.version = "2.0"
  s.author = "John Leach"
  s.email = "john@brightbox.co.uk"
  s.homepage = "http://rubyforge.org/projects/brightbox/"
  s.rubyforge_project = 'brightbox'
  s.platform = Gem::Platform::RUBY
  s.summary = "Brightbox rails deployment scripts for Capistrano"
  s.files = FileList["{bin,lib,spec}/**/*"].to_a
  s.require_path = "lib"
  s.has_rdoc = false
  s.add_dependency("capistrano", ">= 2.1")
  s.add_dependency("ini", ">= 0.1")
#  s.add_dependency("mongrel_cluster", ">= 1.0.5")
  s.default_executable = "brightbox"
  s.executables = %W(brightbox brightbox-mysql brightbox-mongrel brightbox-apache brightbox-monit brightbox-logrotate brightbox-ssh)
end
