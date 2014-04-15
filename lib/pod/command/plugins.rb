require 'rest'
require 'json'

# The CocoaPods namespace
#
module Pod
  class Command

    # The pod plugins command.
    #
    class Plugins < Command

      PLUGINS_URL = 'https://raw.githubusercontent.com/CocoaPods/cocoapods.org/master/data/plugins.json'

      attr_accessor :json

      self.summary = 'Show available CocoaPods plugins'

      self.description = <<-DESC
        Shows the available CocoaPods plugins and if you have them installed or not.
      DESC

      def download_json
        response = REST.get(PLUGINS_URL)
        if response.ok?
          @json = JSON.parse(response.body)
        end
      end

      def installed?(gemname)
        if Gem::Specification.methods.include?(:find_all_by_name)
          Gem::Specification.find_all_by_name(gemname).any?
        else
          # Fallback to Gem.available? for old versions of rubygems
          Gem.available?(gemname)
        end
      end

      def run
        UI.puts "Downloading Plugins list..."
        begin
          download_json unless json
        rescue => e
          UI.puts e.message
        end

        if !json
          UI.puts "Could not download plugins list from cocoapods.org"
        else
          print_plugins
        end
      end

      def print_plugins
        UI.puts "Available CocoaPods Plugins\n\n"

        @json['plugins'].each do |plugin|
          UI.puts "Name: #{plugin['name']}"

          if installed?(plugin['gem'])
            UI.puts "Gem: #{plugin['gem']}".green
          else
            UI.puts "Gem: #{plugin['gem']}".yellow
          end

          UI.puts "URL: #{plugin['url']}"
          UI.puts "\n#{plugin['description']}\n\n"
        end
      end

    end
  end
end
