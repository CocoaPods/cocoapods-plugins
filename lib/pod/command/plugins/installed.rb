
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
          max_length = plugins.map { |p| p.name.length }.max
          
          UI.title 'Installed CocoaPods Plugins:' do
            plugins.each do |plugin|
              if self.verbose?
                UI.title(plugin.name)
                UI.labeled('Version', plugin.version)
                UI.labeled('Homepage', plugin.homepage) if plugin.homepage
                UI.labeled('Summary', plugin.summary)
              else
                UI.puts_indented " - #{plugin.name.ljust(max_length)} : #{plugin.version}"
              end
            end
          end
        end

      end
    end
  end
end
