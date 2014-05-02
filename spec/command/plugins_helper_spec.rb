require File.expand_path('../spec_helper', File.dirname(__FILE__))

# The CocoaPods namespace
#
module Pod
  describe Command::PluginsHelper do
    extend SpecHelper::PluginsStubs

    it 'downloads the json file' do
      stub_plugins_json_request
      json = Command::PluginsHelper.download_json
      json.should.not.be.nil?
      json.should.be.kind_of? Hash
      json['plugins'].size.should.eql? 3
    end

    it 'handles empty/bad JSON' do
      stub_plugins_json_request 'This is not JSON'
      # rubocop:disable Lambda
      lambda { Command::PluginsHelper.download_json }
      .should.raise(Pod::Informative)
      .message.should.match(/Invalid plugins list from cocoapods.org/)
      # rubocop:enable Lambda
    end

    it 'notifies the user if the download fails' do
      stub_plugins_json_request '', [404, 'Not Found']
      # rubocop:disable Lambda
      lambda { Command::PluginsHelper.download_json }
      .should.raise(Pod::Informative)
      .message.should
      .match(/Could not download plugins list from cocoapods.org/)
      # rubocop:enable Lambda
    end

    it 'detects if a gem is installed' do
      Helper = Command::PluginsHelper
      Helper.gem_installed?('bacon').should.be.true
      Helper.gem_installed?('fake-fake-fake-gem').should.be.false
    end
  end
end
