module Pod
  class Command
    class Plugins

      # The search subcommand. Used to search a plugin in the list of known plugins,
      # searching into the name and description fields
      #
      class Search < Plugins

        PLUGINS_URL = 'https://raw.githubusercontent.com/CocoaPods/cocoapods.org/master/data/plugins.json'

        attr_accessor :json

        self.summary = 'Search for known plugins'
        self.description = <<-DESC
                Searches plugins whose name contains the given text (ignoring case).
                * Without any QUERY, it lists all known plugins.
                * With --full, it searches by name but also by author and description.
        DESC

        self.arguments = '[QUERY]'

        def self.options
          [
            ['--full',  'Search by name, author, and description'],
          ].concat(super.reject { |option, _| option == '--silent' })
        end

        def initialize(argv)
          @full_text_search = argv.flag?('full')
          @query = argv.shift_argument unless argv.arguments.empty?
          super
        end

        def validate!
          super
          UI.warn '`--full` flag is useless without a query' if @full_text_search && @query.nil?
          begin
            /#{@query}/
          rescue RegexpError
            help! "A valid regular expression is required."
          end
        end

        def run
          UI.puts 'Downloading Plugins list...'
          begin
            download_json unless json
          rescue => e
            UI.puts e.message
          end

          if json
            if @query
              list_matching_plugins
            else
              list_all_plugins
            end
          else
            UI.puts 'Could not download plugins list from cocoapods.org'
          end
        end

        #----------------------------------------#

        private

        # !@group Private helpers

        # Force-download the JSON
        def download_json
          response = REST.get(PLUGINS_URL)
          if response.ok?
            @json = JSON.parse(response.body)
          end
        end

        # List only plugins matching the query
        def list_matching_plugins
          UI.puts "\nAvailable CocoaPods Plugins matching '#{@query}'\n"

          query_regexp = /#{@query}/i
          json['plugins'].each do |plugin|
            texts = [plugin['name']]
            if @full_text_search
              texts << plugin['author'] if plugin['author']
              texts << plugin['description'] if plugin['description']
            end
            print_plugin plugin unless texts.grep(query_regexp).empty?
          end
        end

        # List all plugins
        def list_all_plugins
          UI.puts "\nAvailable CocoaPods Plugins\n"

          json['plugins'].each do |plugin|
            print_plugin plugin
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

      end

    end
  end
end
