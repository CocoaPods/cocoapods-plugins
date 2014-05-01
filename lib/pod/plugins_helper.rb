module Pod

  # The PluginsHelper module
  #
  # Used by Command::Plugins::List and Command::Plugins::Search to download and parse the JSON
  # describing the plugins list and manipulate it
  #
  module PluginsHelper

    PLUGINS_URL = 'https://raw.githubusercontent.com/CocoaPods/cocoapods.org/master/data/plugins.json'

    # Force-download the JSON
    #
    # @return [Hash] The hash representing the JSON with all known plugins
    #
    def self.download_json
      response = REST.get(PLUGINS_URL)
      if response.ok?
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise Informative, "Invalid plugins list from cocoapods.org: #{e}"
        end
      else
        raise Informative, "Could not download plugins list from cocoapods.org: #{response.inspect}"
      end
    end

    # The list of all known plugins, according to the JSON hosted on github's cocoapods.org
    #
    # @return [Array] all known plugins, as listed in the downloaded JSON
    #
    def self.known_plugins
      UI.puts 'Downloading Plugins list...'
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
    # @return all plugins matching the query
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
    #        The hash describing the plugin's name, description, gem, url and author
    #
    # @param [Bool] verbose
    #        If true, will also print the author of the plugins. Defaults to false.
    #
    def self.print_plugin(plugin, verbose = false)
      plugin_name = "-> #{plugin['name']}"
      installed = gem_installed?(plugin['gem'])
      plugin_colored_name = installed ? plugin_name.green : plugin_name.yellow

      UI.title(plugin_colored_name, '', 1) do
        UI.puts_indented plugin['description']
        UI.labeled('Gem', plugin['gem'])
        UI.labeled('URL',   plugin['url'])
        UI.labeled('Author', plugin['author']) if verbose
      end
    end
  end
end
