require 'minitest/autorun'
require 'fileutils'
require_relative '../lib/flickr/agent'

describe Flickr::Agent do
  def setup_mock_client
    @mock_client = Minitest::Mock.new

    photosets_json_path = File.join(@fixtures_path, 'photosets.json')
    File.read(photosets_json_path)
    @mock_client.expect(:get, File.read(photosets_json_path), ['flickr.photosets.getList', user_id: @user_id])

    photoset_photos_path = File.join(@fixtures_path, 'photosets', @set_id, 'photos.json')
    @mock_client.expect(:get, File.read(photoset_photos_path), ['flickr.photosets.getPhotos', photoset_id: @set_id])

    photo_info_path = File.join(@fixtures_path, 'photosets', @set_id, 'photos', @photo_id, 'info.json')
    @mock_client.expect(:get, File.read(photo_info_path), ['flickr.photos.getInfo', photo_id: @photo_id])

    photo_comments_path = File.join(@fixtures_path, 'photosets', @set_id, 'photos', @photo_id, 'comments.json')
    @mock_client.expect(:get, File.read(photo_comments_path), ['flickr.photos.comments.getList', photo_id: @photo_id])

    photo_exif_path = File.join(@fixtures_path, 'photosets', @set_id, 'photos', @photo_id, 'exif.json')
    @mock_client.expect(:get, File.read(photo_exif_path), ['flickr.photos.getExif', photo_id: @photo_id])
  end

  def setup_stubbed_downloader
    @stubbed_downloader = Flickr::Downloader.new(load_options)
    @mock_response = Minitest::Mock.new
    @mock_response.expect(:code, '200')
    @mock_response.expect(:body, File.read(File.join(@fixtures_path, 'photosets', @set_id, 'photos', @photo_id, "#{@photo_id}.jpg")))
  end

  def load_options
    config_path = File.join(@fixtures_path, 'config.test.json')
    options = JSON.parse(File.read(config_path))
    options['archive_path'] = @archive_path
    options
  end

  def compare_json(path)
    JSON.parse(File.read(File.join(@fixtures_path, *path)))
      .must_equal(JSON.parse(File.read(File.join(@archive_path, *path))))
  end

  def compare_files(path)
    FileUtils.compare_file(File.join(@fixtures_path, *path), File.join(@archive_path, *path))
      .must_equal(true)
  end

  before do
    @fixtures_path = File.join(File.dirname(__FILE__), 'fixtures')
    @archive_path = File.join(File.dirname(__FILE__), 'tmp')
    @user_id = '74504321@N00'
    @set_id = '72157629556799377'
    @photo_id = '6970875833'

    FileUtils.rm_rf @archive_path

    setup_mock_client
    setup_stubbed_downloader
  end

  describe '#fetch_photosets' do
    before do
      Flickr::Client.stub :new, @mock_client do
        @stubbed_downloader.stub(:http_get, @mock_response, ["http://farm8.static.flickr.com/7201/6970875833_f0138571a1_o.jpg"]) do
          Flickr::Downloader.stub :new, @stubbed_downloader do
            @agent = Flickr::Agent.new(load_options)
            @agent.fetch_photosets
          end
        end
      end
    end

    it 'fetches and organizes photos and metadata' do
      compare_json('photosets.json')
      compare_json(['photosets', @set_id, 'photoset.json'])
      compare_json(['photosets', @set_id, 'photos.json'])
      compare_json(['photosets', @set_id, 'photos', @photo_id, 'info.json'])
      compare_json(['photosets', @set_id, 'photos', @photo_id, 'exif.json'])
      compare_json(['photosets', @set_id, 'photos', @photo_id, 'comments.json'])
      compare_files(['photosets', @set_id, 'photos', @photo_id, "#{@photo_id}.jpg"])
    end
  end
end
