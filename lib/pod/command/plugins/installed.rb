
module Pod
  class Command
    class Plugins
      # The list subcommand. Used to list all known plugins
      #
      class Installed < Plugins
        self.summary = 'List plugins installed on your machine'
        self.description = <<-DESC
                List all installed plugins and their
                respective version
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

        def print_compact_list(plugins)
          max_length = plugins.map { |p| p.name.length }.max
          plugins.each do |plugin|
            name_just = plugin.name.ljust(max_length)
            UI.puts_indented " - #{name_just} : #{plugin.version}"
          end
        end

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
