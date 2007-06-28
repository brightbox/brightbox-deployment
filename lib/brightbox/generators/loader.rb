module Brightbox
  module Generators
    class RailsLoader
      def self.load!(options)
        require "#{options[:apply_to]}/config/environment"
        require "rails_generator"
        require "rails_generator/scripts/generate"

        Rails::Generator::Base.sources << Rails::Generator::PathSource.new(
          :brightbox, File.dirname(__FILE__))

        args = ["brightbox"]
        args << (options[:application] || "Application")
        args << (options[:domain] || "application.boxname.username.brightbox.co.uk")
        args << (options[:server] || "87.237.63.??")

        Rails::Generator::Scripts::Generate.new.run(args)
      end
    end
    class ApacheLoader
      def self.load!(options)
        require "/home/john/devel/reflex/capistrano-setup/cap-test2/config/environment"
        require "rails_generator"
        require "rails_generator/scripts/generate"

        Rails::Generator::Base.sources << Rails::Generator::PathSource.new(
          :brightboxapache, "/etc/apache2/sites-available")

        args = ["brightboxapache"]
        args << (options[:application] || "application").downcase
        args << (options[:web_root] || "/home/rails/#{options[:application]}/current/public")
        args << (options[:domain] || "application.boxname.username.brightbox.co.uk")
        args << (options[:port] || 9200)
        args << (options[:mongrels] || 2)

        Rails::Generator::Scripts::Generate.new.run(args)
      end
    end
  end
end
