require 'pod/command/plugins_helper'

module Pod
  class Command
    class Plugins

      # The list subcommand. Used to list all known plugins
      #
      class List < Plugins

        self.summary = 'List all known plugins'
        self.description = <<-DESC
                List all known plugins (according to the list hosted on github.com/CocoaPods/cocoapods.org)
        DESC

        def self.options
          super.reject { |option, _| option == '--silent' }
        end

        def run
          plugins = PluginsHelper.known_plugins

          UI.title 'Available CocoaPods Plugins:' do
            plugins.each { |plugin| PluginsHelper.print_plugin plugin, self.verbose? }
          end
        end

      end

    end
  end
end
