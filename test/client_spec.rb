require 'minitest/autorun'
require 'fileutils'
require 'json'
require_relative '../lib/flickr/client'

describe Flickr::Client do
  before do
    @fixtures_path = File.join(File.dirname(__FILE__), 'fixtures')
    @user_id = '74504321@N00'
    @set_id = '72157629556799377'

    config_path = File.join(@fixtures_path, 'config.test.json')
    options = JSON.parse(File.read(config_path))
    options['archive_path'] = @archive_path

    @client = Flickr::Client.new(options)
  end

  describe '#get' do
    before do
      @fixture_data = File.read(File.join(@fixtures_path, 'photosets.json'))
      @mock_response = Minitest::Mock.new
      @mock_response.expect(:code, '200')
      @mock_response.expect(:body, @fixture_data)
    end

    it 'gets JSON data' do
      url = 'https://api.flickr.com/services/rest/?user_id=74504321%40N00&method=flickr.photosets.getList&api_key=abc123&format=json&nojsoncallback=1'

      @client.stub(:get_http, @mock_response, [url]) do
        @client
          .get('flickr.photosets.getList', user_id: @user_id)
          .must_equal(@fixture_data)
      end
    end
  end
end
