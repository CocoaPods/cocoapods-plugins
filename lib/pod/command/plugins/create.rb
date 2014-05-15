module Pod
  class Command
    class Plugins
      # The create subcommand. Used to create a new plugin using either the
      # default template (CocoaPods/cocoapods-plugin-template) or a custom
      # template
      #
      class Create < Plugins
        NAME_PREFIX = 'cocoapods-'

        self.summary = 'Creates a new plugin'
        self.description = <<-DESC
                Creates a scaffold for the development of a new plugin
                according to the CocoaPods best practices.

                If a `TEMPLATE_URL`, pointing to a git repo containing a
                compatible template, is specified, it will be used
                in place of the default one.
        DESC

        self.arguments = [
            ['NAME', :required],
            ['TEMPLATE_URL', :optional]
        ]

        def initialize(argv)
          @name = argv.shift_argument
          unless @name.nil? || @name.empty? || @name.index(NAME_PREFIX) == 0
            @name = @name.dup.prepend(NAME_PREFIX)
          end
          @template_url = argv.shift_argument
          super
        end

        def validate!
          super
          if @name.nil? || @name.empty?
            help! 'A name for the plugin is required.'
          end
          if @name.match(/\s/)
            help! 'The plugin name cannot contain spaces.'
          end
        end

        def run
          clone_template
          configure_template
        end

        #----------------------------------------#

        private

        # !@group Private helpers

        extend Executable
        executable :git
        executable :ruby

        TEMPLATE_BASE_URL = 'https://github.com/CocoaPods/'
        TEMPLATE_REPO = TEMPLATE_BASE_URL + 'cocoapods-plugin-template.git'
        TEMPLATE_INFO_URL = TEMPLATE_BASE_URL + 'cocoapods-plugin-template'

        # Clones the template from the remote in the working directory using
        # the name of the plugin.
        #
        # @return [void]
        #
        def clone_template
          UI.section("-> Creating `#{@name}` plugin") do
            UI.notice "using template '#{template_repo_url}'"
            git! "clone '#{template_repo_url}' #{@name}"
          end
        end

        # Runs the template configuration utilities.
        #
        # @return [void]
        #
        def configure_template
          UI.section('-> Configuring template') do
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
