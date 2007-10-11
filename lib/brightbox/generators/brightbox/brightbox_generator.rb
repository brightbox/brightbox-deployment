class BrightboxGenerator < Rails::Generator::NamedBase
  attr_reader :application_name
  attr_reader :domain_name
  attr_reader :server
  
  def initialize(runtime_args, runtime_options = {})
    super
    @application_name = self.file_name
    @domain_name = @args[0]
    @server = @args[1]
  end

  def manifest
    record do |m|
      m.directory "config"
      m.template "deploy.rb", File.join("config", "deploy.rb")
      m.template "Capfile", File.join("Capfile")
    end
  end

  protected

    # Override with your own usage banner.
    def banner
      "Usage: #{$0} brightbox ApplicationName DomainName BrightboxServer"
    end
end
