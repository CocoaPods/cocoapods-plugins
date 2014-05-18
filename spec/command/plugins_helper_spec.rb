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
      expected_error = /Invalid plugins list from cocoapods.org/
      should.raise(Pod::Informative) do
        Command::PluginsHelper.download_json
      end.message.should.match(expected_error)
    end

    it 'notifies the user if the download fails' do
      stub_plugins_json_request '', [404, 'Not Found']
      expected_error = /Could not download plugins list from cocoapods.org/
      should.raise(Pod::Informative) do
        Command::PluginsHelper.download_json
      end.message.should.match(expected_error)
    end

    it 'detects if a gem is installed' do
      Helper = Command::PluginsHelper
      Helper.gem_installed?('bacon').should.be.true
      Helper.gem_installed?('fake-fake-fake-gem').should.be.false
    end
  end
end
