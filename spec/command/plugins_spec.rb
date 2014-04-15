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
end
