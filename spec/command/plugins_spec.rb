require File.expand_path('../../spec_helper', __FILE__)

# The CocoaPods namespace
#
module Pod
  describe Command::Plugins do

    before do
      argv = CLAide::ARGV.new([])
      @command = Command::Plugins.new(argv)
    end

    it "registers it self" do
      Command.parse(%w(plugins)).should.be.instance_of Command::Plugins
    end

    it "exists" do
      @command.should.not.be.nil?
    end

    it "has a json attribute that starts out nil" do
      @command.json.should.be.nil?
    end

    it "downloads the json file" do
      json = File.read(fixture('plugins.json'))
      stub_request(:get, Command::Plugins::PLUGINS_URL).to_return(:status => 200, :body => json, :headers => {})
      @command.download_json
      @command.json.should.not.be.nil?
      @command.json.should.be.kind_of? Hash
      @command.json['plugins'].size.should.eql? 2
    end

    it "handles empty/bad JSON" do
      stub_request(:get, Command::Plugins::PLUGINS_URL).to_return(:status => 200, :body => "This is not JSON", :headers => {})
      @command.run
      UI.output.should.include("Could not download plugins list from cocoapods.org")
      @command.json.should.be.nil?
    end

    it "notifies the user if the download fails" do
      stub_request(:get, Command::Plugins::PLUGINS_URL).to_return(:status => [404, "Not Found"])
      @command.run
      UI.output.should.include("Could not download plugins list from cocoapods.org")
      @command.json.should.be.nil?
    end

    it "prints out each plugin" do
      json_fixture = fixture('plugins.json')
      @json = JSON.parse(File.read(json_fixture))
      @command.json = @json
      @command.run
      UI.output.should.include("github.com/CocoaPods/cocoapods-fake")
      UI.output.should.include("github.com/chneukirchen/bacon")
    end

    it "detects if a gem is installed" do
      @command.installed?("bacon").should.be.true
      @command.installed?("fake-fake-fake-gem").should.be.false
    end

  end

  describe Command::Plugins::Create do
    extend SpecHelper::PluginCreateCommand

    it "registers itself" do
      Command.parse(%w(plugins create)).should.be.instance_of Command::Plugins::Create
    end

    it "should require a name is passed in" do
      @command = create_command(argv)
      # rubocop:disable Lambda
      lambda { @command.validate! }
            .should.raise(CLAide::Help)
            .message.should.match(/A name for the plugin is required./)
      # rubocop:enable Lambda
    end

    it "should require a non-empty name is passed in" do
      @command = create_command(argv(""))
      # rubocop:disable Lambda
      lambda { @command.validate! }
            .should.raise(CLAide::Help)
            .message.should.match(/A name for the plugin is required./)
      # rubocop:enable Lambda
    end

    it "should require the name does not have spaces" do
      @command = create_command(argv("my gem"))
      # rubocop:disable Lambda
      lambda { @command.validate! }
            .should.raise(CLAide::Help)
            .message.should.match(/The plugin name cannot contain spaces./)
      # rubocop:enable Lambda
    end

    it "should download the default template repository" do
      @command = create_command(argv("cocoapods-banana"))
      # @command = Command::Plugins::Create.new(argv("cocoapods-banana"))

      git_command = "clone 'https://github.com/CocoaPods/cocoapods-plugin-template.git' cocoapods-banana"
      @command.expects(:git!).with(git_command)
      @command.expects(:configure_template)
      @command.run
      UI.output.should.include("Creating `cocoapods-banana` plugin")
    end

    it "should download the passed in template repository" do
      alt_repository = "https://github.com/CocoaPods/cocoapods-banana-plugin-template.git"
      @command = create_command(argv("cocoapods-banana", alt_repository))

      @command.expects(:git!).with("clone '#{alt_repository}' cocoapods-banana")
      @command.expects(:configure_template)
      @command.run
      UI.output.should.include("Creating `cocoapods-banana` plugin")
    end

  end

end
