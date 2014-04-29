require File.expand_path('../../../spec_helper', __FILE__)

# The CocoaPods namespace
#
module Pod

  describe Command::Plugins::Search do
    extend SpecHelper::PluginSearchCommand

    before do
      UI.output = ''
    end

    it 'registers itself' do
      Command.parse(%w(plugins search)).should.be.instance_of Command::Plugins::Search
    end

    #--- JSON handling

    it 'has a json attribute that starts out nil' do
      @command = search_command(argv)
      @command.json.should.be.nil?
    end

    it 'downloads the json file' do
      json = File.read(fixture('plugins.json'))
      stub_request(:get, Command::Plugins::Search::PLUGINS_URL).to_return(:status => 200, :body => json, :headers => {})
      @command = search_command(argv)
      @command.instance_eval { download_json } # private method requires the use of instance_eval to be called for testing
      @command.json.should.not.be.nil?
      @command.json.should.be.kind_of? Hash
      @command.json['plugins'].size.should.eql? 3
    end

    it 'handles empty/bad JSON' do
      stub_request(:get, Command::Plugins::Search::PLUGINS_URL).to_return(:status => 200, :body => 'This is not JSON', :headers => {})
      @command = search_command(argv)
      @command.run
      UI.output.should.include('Could not download plugins list from cocoapods.org')
      @command.json.should.be.nil?
    end

    it 'notifies the user if the download fails' do
      stub_request(:get, Command::Plugins::Search::PLUGINS_URL).to_return(:status => [404, 'Not Found'])
      @command.run
      UI.output.should.include('Could not download plugins list from cocoapods.org')
      @command.json.should.be.nil?
    end

    #--- Output printing

    it 'prints out all plugins when no query passed' do
      @command = search_command(argv)
      @command.json = JSON.parse(File.read(fixture('plugins.json')))
      @command.run
      UI.output.should.include('github.com/CocoaPods/cocoapods-fake-1')
      UI.output.should.include('github.com/CocoaPods/cocoapods-fake-2')
      UI.output.should.include('github.com/chneukirchen/bacon')
    end

    it 'detects if a gem is installed' do
      # private method requires the use of instance_eval to be called for testing
      @command.instance_eval { installed?('bacon') }.should.be.true
      @command.instance_eval { installed?('fake-fake-fake-gem') }.should.be.false
    end

    it 'warns when --full is used with no query' do
      @command = search_command(argv('--full'))
      @command.validate!
      UI.warnings.should.include('`--full` flag is useless without a query')
    end

    #--- Query

    it 'should require a valid regex as query' do
      @command = search_command(argv('[invalid'))
      # rubocop:disable Lambda
      lambda { @command.validate! }
      .should.raise(CLAide::Help)
      .message.should.match(/A valid regular expression is required./)
      # rubocop:enable Lambda
    end

    it 'should filter plugins by name when no full search' do
      @command = search_command(argv('search'))
      @command.json = JSON.parse(File.read(fixture('plugins.json')))
      @command.run
      UI.output.should.not.include('-> CocoaPods Fake Gem')
      UI.output.should.include('-> CocoaPods Searchable Fake Gem')
      UI.output.should.not.include('-> Bacon')
    end

    it 'should filter plugins by name and description when full search' do
      @command = search_command(argv('--full', 'search'))
      @command.json = JSON.parse(File.read(fixture('plugins.json')))
      @command.run
      UI.output.should.include('-> CocoaPods Fake Gem')
      UI.output.should.include('-> CocoaPods Searchable Fake Gem')
      UI.output.should.not.include('-> Bacon')
    end
  end

end
