def add_common(spec)
  spec.version = "2.0.0"
  spec.authors = ["John Leach","Neil Wilson"]
  spec.email = "support@brightbox.co.uk"
  spec.homepage = "http://wiki.brightbox.co.uk/docs:thebrightboxgem"
  spec.rubyforge_project = 'brightbox'
  spec.has_rdoc = false
end

@server = Gem::Specification.new do |s|
  add_common(s)
  s.name = "brightbox-server-tools"
  s.files = FileList["LICENSE", "Rakefile", "*.rb", "bin/brightbox-*","{lib,spec}/**/*.rb"].exclude(/recipe/).to_a
  s.add_dependency("ini", ">=0.1.1")
  s.summary = "Brightbox Server configuration scripts"
  s.executables = FileList["bin/brightbox-*"].map { |filename| File.basename(filename) }
end

@client = Gem::Specification.new do |s|
  add_common(s)
  s.name = "brightbox"
  s.files = FileList["LICENSE", "Rakefile", "*.rb", "lib/**/*.rb","bin/brightbox"].exclude("lib/brightbox/database*").to_a
  s.autorequire = "brightbox/recipes"
  s.add_dependency("capistrano", ">= 2.1")
  s.summary = "Brightbox rails deployment scripts for Capistrano"
  s.executable = 'brightbox'
end

