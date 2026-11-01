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
      json.should.be.is_a? Hash
      json['plugins'].size.should.eql? 3
    end

    it 'handles empty/bad JSON' do
      stub_plugins_json_request 'This is not JSON'
      expected_error = /Invalid plugins list from cocoapods-plugins/
      should.raise(Pod::Informative) do
        Command::PluginsHelper.download_json
      end.message.should.match(expected_error)
    end

    it 'notifies the user if the download fails' do
      stub_plugins_json_request '', [404, 'Not Found']
      expected_error = /Could not download plugins list from cocoapods-plugins/
      should.raise(Pod::Informative) do
        Command::PluginsHelper.download_json
      end.message.should.match(expected_error)
    end

    it 'rejects a server certificate that is not trusted' do
      key = OpenSSL::PKey::RSA.new(2048)
      cert = OpenSSL::X509::Certificate.new
      cert.version = 2
      cert.serial = 1
      cert.subject = cert.issuer = OpenSSL::X509::Name.parse('/CN=127.0.0.1')
      cert.public_key = key.public_key
      cert.not_before = Time.now - 60
      cert.not_after = Time.now + 60
      cert.sign(key, OpenSSL::Digest::SHA256.new)

      context = OpenSSL::SSL::SSLContext.new
      context.cert = cert
      context.key = key
      tcp_server = TCPServer.new('127.0.0.1', 0)
      server = OpenSSL::SSL::SSLServer.new(tcp_server, context)
      thread = Thread.new do
        begin
          server.accept.close
        rescue OpenSSL::SSL::SSLError
          nil
        end
      end

      helper = Command::PluginsHelper
      original_url = helper::PLUGINS_RAW_URL
      helper.send(:remove_const, :PLUGINS_RAW_URL)
      helper.const_set(:PLUGINS_RAW_URL, "https://127.0.0.1:#{tcp_server.addr[1]}/plugins.json")
      WebMock.disable!
      begin
        exception = should.raise(Pod::Informative) do
          helper.download_json
        end
        exception.message.should.include 'certificate verify failed'
      ensure
        WebMock.enable!
        helper.send(:remove_const, :PLUGINS_RAW_URL)
        helper.const_set(:PLUGINS_RAW_URL, original_url)
        thread.kill
        thread.join
        server.close
      end
    end

    it 'uses the proxy configured for https' do
      proxy_env = %w(https_proxy HTTPS_PROXY no_proxy NO_PROXY).map { |k| [k, ENV.delete(k)] }
      ENV['https_proxy'] = 'http://user:pass@proxy.example:8080'
      Net::HTTP.expects(:new).
        with('raw.githubusercontent.com', 443, 'proxy.example', 8080, 'user', 'pass').
        raises(SocketError)

      begin
        should.raise(SocketError) do
          Command::PluginsHelper.download_json
        end
      ensure
        proxy_env.each { |k, v| v ? ENV[k] = v : ENV.delete(k) }
      end
    end
  end
end
