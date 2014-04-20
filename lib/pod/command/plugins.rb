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

      #-----------------------------------------------------------------------#

      class Create < Plugins
        self.summary = 'Creates a new plugin'

        self.description = <<-DESC
          Creates a scaffold for the development of a new plugin according to the CocoaPods best practices.
          If a `TEMPLATE_URL`, pointing to a git repo containing a compatible template, is specified, it will be used in place of the default one.
        DESC

        self.arguments = 'NAME [TEMPLATE_URL]'

        def initialize(argv)
          @name = argv.shift_argument
          @template_url = argv.shift_argument
          super
        end

        def validate!
          super
          help! "A name for the plugin is required." unless @name
          help! "The plugin name cannot contain spaces." if @name.match(/\s/)
        end

        def run
          clone_template
          configure_template
        end

        private

        #----------------------------------------#

        # !@group Private helpers

        extend Executable
        executable :git
        executable :ruby

        TEMPLATE_REPO = "https://github.com/CocoaPods/cocoapods-plugin-template.git"
        TEMPLATE_INFO_URL = "https://github.com/CocoaPods/cocoapods-plugin-template"

        # Clones the template from the remote in the working directory using
        # the name of the plugin.
        #
        # @return [void]
        #
        def clone_template
          UI.section("Creating `#{@name}` plugin") do
            git!"clone '#{template_repo_url}' #{@name}"
          end
        end

        # Runs the template configuration utilities.
        #
        # @return [void]
        #
        def configure_template
          UI.section("Configuring template") do
            Dir.chdir(@name) do
              if File.exists? "configure"
                system "./configure #{@name}"
              else
                UI.warn "Template does not have a configure file."
              end
            end
          end
        end

        # Checks if a template URL is given else returns the TEMPLATE_REPO URL
        #
        # @return String
        #
        def template_repo_url
          @template_url || TEMPLATE_REPO
        end
      end

    end
  end
end
