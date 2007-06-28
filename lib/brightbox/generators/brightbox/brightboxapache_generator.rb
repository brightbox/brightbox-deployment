class BrightboxapacheGenerator < Rails::Generator::NamedBase
  attr_reader :application_name
  attr_reader :domain_name
  attr_reader :port
  attr_reader :mongrels
  
  def initialize(runtime_args, runtime_options = {})
    super
    @application_name = self.file_name
    @domain_name = @args[0]
    @port = @args[1]
    @mongrels = @args[2]
  end

  def manifest
    record do |m|
      m.template "apache_config", @application_name
    end
  end

  protected

    # Override with your own usage banner.
    def banner
      "Usage: #{$0} brightbox_apache ApplicationName DomainName MongrelPort NumberOfMongrels"
    end
end
