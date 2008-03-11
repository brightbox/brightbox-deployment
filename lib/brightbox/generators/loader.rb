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
        args << (options[:domain] || "application.username-001.vm.brightbox.net")
        args << (options[:server] || "username-001.vm.brightbox.net")

        Rails::Generator::Scripts::Generate.new.run(args)
      end
    end
  end
end
