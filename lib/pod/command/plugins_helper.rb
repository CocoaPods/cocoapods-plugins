module Pod
  class Command
    # This module is used by Command::Plugins::List
    # and Command::Plugins::Search to download and parse
    # the JSON describing the plugins list and manipulate it
    #
    module PluginsHelper
      PLUGINS_URL = 'https://raw.githubusercontent.com/CocoaPods/' \
                    'cocoapods.org/master/data/plugins.json'

      # Force-download the JSON
      #
      # @return [Hash] The hash representing the JSON with all known plugins
      #
      def self.download_json
        UI.puts 'Downloading Plugins list...'
        response = REST.get(PLUGINS_URL)
        if response.ok?
          parse_json(response.body)
        else
          raise Informative, 'Could not download plugins list ' \
                             "from cocoapods.org: #{response.inspect}"
        end
      end

      # The list of all known plugins, according to
      # the JSON hosted on github's cocoapods.org
      #
      # @return [Array] all known plugins, as listed in the downloaded JSON
      #
      def self.known_plugins
        json = download_json
        json['plugins']
      end

      # Filter plugins to return only matching ones
      #
      # @param [String] query
      #        A query string that corresponds to a valid RegExp pattern.
      #
      # @param [Bool] full_text_search
      #        false only searches in the plugin's name.
      #        true searches in the plugin's name, author and description.
      #
      # @return [Array] all plugins matching the query
      #
      def self.matching_plugins(query, full_text_search)
        query_regexp = /#{query}/i
        known_plugins.reject do |plugin|
          texts = [plugin['name']]
          if full_text_search
            texts << plugin['author'] if plugin['author']
            texts << plugin['description'] if plugin['description']
          end
          texts.grep(query_regexp).empty?
        end
      end

      # Tells if a gem is installed
      #
      # @param [String] gem_name
      #        The name of the plugin gem to test
      #
      # @return [Bool] true if the gem is installed, false otherwise.
      #
      def self.gem_installed?(gem_name)
        if Gem::Specification.methods.include?(:find_all_by_name)
          Gem::Specification.find_all_by_name(gem_name).any?
        else
          # Fallback to Gem.available? for old versions of rubygems
          Gem.available?(gem_name)
        end
      end

      # Display information about a plugin
      #
      # @param [Hash] plugin
      #        The hash describing the plugin
      #
      # @param [Bool] verbose
      #        If true, will also print the author of the plugins.
      #        Defaults to false.
      #
      def self.print_plugin(plugin, verbose = false)
        plugin_colored_name = plugin_title(plugin)

        UI.title(plugin_colored_name, '', 1) do
          UI.puts_indented plugin['description']
          UI.labeled('Gem', plugin['gem'])
          UI.labeled('URL',   plugin['url'])
          UI.labeled('Author', plugin['author']) if verbose
        end
      end

      #----------------#

      private

      # Parse the given JSON data, handling parsing errors if any
      #
      # @param [String] json_str
      #        The string representation of the JSON to parse
      #
      def self.parse_json(json_str)
        JSON.parse(json_str)
        rescue JSON::ParserError => e
          raise Informative, "Invalid plugins list from cocoapods.org: #{e}"
      end

      # Format the title line to print the plugin info with print_plugin
      # coloring it according to whether the plugin is installed or not
      #
      # @param [Hash] plugin
      #               The hash describing the plugin
      #
      # @return [String] The formatted and colored title
      #
      def self.plugin_title(plugin)
        plugin_name = "-> #{plugin['name']}"
        if gem_installed?(plugin['gem'])
          plugin_name.green
        else
          plugin_name.yellow
        end
      end
    end
  end
end
