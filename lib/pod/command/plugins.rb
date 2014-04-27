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

      # Force-download the JSON
      def download_json
        response = REST.get(PLUGINS_URL)
        if response.ok?
          @json = JSON.parse(response.body)
        end
      end

      # Tells if a gem is installed
      def installed?(gemname)
        if Gem::Specification.methods.include?(:find_all_by_name)
          Gem::Specification.find_all_by_name(gemname).any?
        else
          # Fallback to Gem.available? for old versions of rubygems
          Gem.available?(gemname)
        end
      end

      # Download the JSON if not already in @json, then execute the given block
      def fetch_plugins_list
        UI.puts 'Downloading Plugins list...'
        begin
          download_json unless json
        rescue => e
          UI.puts e.message
        end

        if json
          yield @json['plugins'] if block_given?
        else
          UI.puts 'Could not download plugins list from cocoapods.org'
        end
      end

      def run
        fetch_plugins_list do |plugins|
          UI.puts "\nAvailable CocoaPods Plugins\n"

          plugins.each do |plugin|
            print_plugin plugin
          end
        end
      end

      # Display information about a plugin given its hash
      def print_plugin(plugin)
        plugin_name = "-> #{plugin['name']}"
        plugin_colored_name = installed?(plugin['gem']) ? plugin_name.green : plugin_name.yellow

        UI.title(plugin_colored_name, '', 1) do
          UI.puts_indented plugin['description']
          UI.labeled('Gem', plugin['gem'])
          UI.labeled('URL',   plugin['url'])
          UI.labeled('Author', plugin['author']) if self.verbose?
        end
      end

      #-----------------------------------------------------------------------#

      # The search subcommand. Used to search a plugin in the list of known plugins,
      # searching into the name and description fields
      #
      class Search < Plugins
        self.summary = 'Search for known plugins'

        self.description = <<-DESC
          Search plugins whose name contains the given text (ignoring case).
          With --full, search by name but also author and description
        DESC

        self.arguments = 'QUERY'

        def self.options
          [
            ["--full",  "Search by name, author, and description"],
          ].concat(super.reject { |option, _| option == '--silent' })
        end

        def initialize(argv)
          @full_text_search = argv.flag?('full')
          @query = argv.shift_argument unless argv.arguments.empty?
          super
        end

        def validate!
          super
          help! "A search query is required." if @query.nil? || @query.empty?
          begin
            /#{@query}/
          rescue RegexpError
            help! "A valid regular expression is required."
          end
        end

        def run
          fetch_plugins_list do |plugins|
            UI.puts "\nAvailable CocoaPods Plugins matching '#{@query}'\n"

            query_regexp = /#{@query}/i
            plugins.each do |plugin|
              texts = [plugin['name']]
              if @full_text_search
                texts << plugin['author'] if plugin['author']
                texts << plugin['description'] if plugin['description']
              end
              print_plugin plugin unless texts.grep(query_regexp).empty?
            end
          end
        end

      end

      #-----------------------------------------------------------------------#

      # The create subcommand. Used to create a new plugin using either the
      # default template (CocoaPods/cocoapods-plugin-template) or a custom
      # template
      #
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
          help! 'A name for the plugin is required.' if @name.nil? || @name.empty?
          help! 'The plugin name cannot contain spaces.' if @name.match(/\s/)
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

        TEMPLATE_REPO = 'https://github.com/CocoaPods/cocoapods-plugin-template.git'
        TEMPLATE_INFO_URL = 'https://github.com/CocoaPods/cocoapods-plugin-template'

        # Clones the template from the remote in the working directory using
        # the name of the plugin.
        #
        # @return [void]
        #
        def clone_template
          UI.section("Creating `#{@name}` plugin") do
            git! "clone '#{template_repo_url}' #{@name}"
          end
        end

        # Runs the template configuration utilities.
        #
        # @return [void]
        #
        def configure_template
          UI.section('Configuring template') do
            Dir.chdir(@name) do
              if File.file? 'configure'
                system "./configure #{@name}"
              else
                UI.warn 'Template does not have a configure file.'
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
