require 'rake'

spec = Gem::Specification.new do |s| 
  s.name = "brightbox"
  s.version = "0.22"
  s.author = "John Leach"
  s.email = "john@brightbox.co.uk"
  s.homepage = "http://rubyforge.org/projects/brightbox/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Brightbox rails deployment scripts for Capistrano"
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = "name"
  s.has_rdoc = false
  s.add_dependency("capistrano", ">= 1.4")
  s.add_dependency("mongrel_cluster", ">= 0.2.1")
  s.add_dependency("termios")
  s.default_executable = "brightbox"
  s.executables = ["brightbox", "brightbox-apache", "brightbox-monit"]

end
