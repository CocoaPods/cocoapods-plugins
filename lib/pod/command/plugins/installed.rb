
module Pod
  class Command
    class Plugins
      # The `installed` subcommand.
      # Used to list all installed plugins.
      #
      class Installed < Plugins
        self.summary = 'List plugins installed on your machine'
        self.description = <<-DESC
                List all installed plugins and their
                respective version.
        DESC

        def self.options
          # Silent mode is meaningless for this command as
          # the command only purpose is to print information
          super.reject { |option, _| option == '--silent' }
        end

        def run
          plugins = CLAide::Command::PluginManager.specifications
          UI.title 'Installed CocoaPods Plugins:' do
            if self.verbose?
              print_verbose_list(plugins)
            else
              print_compact_list(plugins)
            end
          end
        end

        private

        # Print the given plugins as a compact list, one line
        # per plugin with only its name & version
        #
        # @param [Array<Gem::Specification>] plugins
        #        The list of plugins to print
        #
        def print_compact_list(plugins)
          max_length = plugins.map { |p| p.name.length }.max
          plugins.each do |plugin|
            name_just = plugin.name.ljust(max_length)
            UI.puts_indented " - #{name_just} : #{plugin.version}"
          end
        end

        # Print the given plugins as a verbose list,
        #    with name, version, homepage and summary
        #    for each plugin.
        #
        # @param [Array<Gem::Specification>] plugins
        #        The list of plugins to print
        #
        def print_verbose_list(plugins)
          plugins.each do |plugin|
            UI.title(plugin.name)
            UI.labeled('Version', plugin.version)
            UI.labeled('Homepage', plugin.homepage) if plugin.homepage
            UI.labeled('Summary', plugin.summary)
          end
        end
      end
    end
  end
end
