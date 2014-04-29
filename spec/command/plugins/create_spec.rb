require File.expand_path('../../../spec_helper', __FILE__)

# The CocoaPods namespace
#
module Pod

  describe Command::Plugins::Create do
    extend SpecHelper::PluginCreateCommand

    before do
      UI.output = ''
    end

    it 'registers itself' do
      Command.parse(%w(plugins create)).should.be.instance_of Command::Plugins::Create
    end

    it 'should require a name is passed in' do
      @command = create_command(argv)
      # rubocop:disable Lambda
      lambda { @command.validate! }
      .should.raise(CLAide::Help)
      .message.should.match(/A name for the plugin is required./)
      # rubocop:enable Lambda
    end

    it 'should require a non-empty name is passed in' do
      @command = create_command(argv(''))
      # rubocop:disable Lambda
      lambda { @command.validate! }
      .should.raise(CLAide::Help)
      .message.should.match(/A name for the plugin is required./)
      # rubocop:enable Lambda
    end

    it 'should require the name does not have spaces' do
      @command = create_command(argv('my gem'))
      # rubocop:disable Lambda
      lambda { @command.validate! }
      .should.raise(CLAide::Help)
      .message.should.match(/The plugin name cannot contain spaces./)
      # rubocop:enable Lambda
    end

    it 'should download the default template repository' do
      @command = create_command(argv('cocoapods-banana'))
      # @command = Command::Plugins::Create.new(argv("cocoapods-banana"))

      git_command = "clone 'https://github.com/CocoaPods/cocoapods-plugin-template.git' cocoapods-banana"
      @command.expects(:git!).with(git_command)
      @command.expects(:configure_template)
      @command.run
      UI.output.should.include('Creating `cocoapods-banana` plugin')
    end

    it 'should download the passed in template repository' do
      alt_repository = 'https://github.com/CocoaPods/cocoapods-banana-plugin-template.git'
      @command = create_command(argv('cocoapods-banana', alt_repository))

      @command.expects(:git!).with("clone '#{alt_repository}' cocoapods-banana")
      @command.expects(:configure_template)
      @command.run
      UI.output.should.include('Creating `cocoapods-banana` plugin')
    end

  end

end
