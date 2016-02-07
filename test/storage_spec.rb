require 'minitest/autorun'
require_relative '../lib/flickr/storage'

describe Flickr::Storage do
  before do
    @fixtures_path = File.join(File.dirname(__FILE__), 'fixtures')
    @set_id = '72157629556799377'
    @photo_id = '6970875833'

    config_path = File.join(@fixtures_path, 'config.test.json')
    options = JSON.parse(File.read(config_path))
    options['archive_path'] = @fixtures_path

    @storage = Flickr::Storage.new(options)
  end

  describe 'path helpers' do
    describe '#photosets_path' do
      it 'returns the expected path' do
        @storage.photosets_path.must_equal "./fixtures/photosets"
      end
    end

    describe '#photosets_json_path' do
      it 'returns the expected path' do
        @storage.photosets_json_path.must_equal './fixtures/photosets.json'
      end
    end

    describe '#favorites_json_path' do
      it 'returns the expected path' do
        @storage.favorites_json_path.must_equal './fixtures/favorites/favorites.json'
      end
    end

    describe '#photoset_json_path' do
      it 'returns the expected path' do
        @storage.photoset_json_path('myset').must_equal('./fixtures/photosets/myset/photoset.json')
      end
    end

    describe '#photoset_photos_json_path' do
      it 'returns the expected path' do
        @storage.photoset_photos_json_path('myset').must_equal('./fixtures/photosets/myset/photos.json')
      end
    end

    describe '#photo_path' do
      it 'returns the expected path' do
        @storage.photo_path('myphoto', 'myset').must_equal('./fixtures/photosets/myset/photos/myphoto')
      end
    end

    describe '#photo_image_path' do
      it 'returns the expected path' do
        @storage.photo_image_path('myphoto', 'myset', 'jpg').must_equal('./fixtures/photosets/myset/photos/myphoto/myphoto.jpg')
      end
    end

    describe '#photo_info_json_path' do
      it 'returns the expected path' do
        @storage.photo_info_json_path('myphoto', 'myset').must_equal('./fixtures/photosets/myset/photos/myphoto/info.json')
      end
    end

    describe '#photo_comments_json_path' do
      it 'returns the expected path' do
        @storage.photo_comments_json_path('myphoto', 'myset').must_equal('./fixtures/photosets/myset/photos/myphoto/comments.json')
      end
    end

    describe '#photo_exif_json_path' do
      it 'returns the expected path' do
        @storage.photo_exif_json_path('myphoto', 'myset').must_equal('./fixtures/photosets/myset/photos/myphoto/exif.json')
      end
    end

    describe '#photoset_path' do
      describe 'when the set_id is :favorites' do
        it 'returns the expected path' do
          @storage.photoset_path(:favorites).must_equal('./fixtures/favorites')
        end
      end

      describe 'when the set_id is not :favorites' do
        it 'returns the expected path' do
          @storage.photoset_path('myset').must_equal('./fixtures/photosets/myset')
        end
      end
    end
  end

  describe 'data loading' do
    describe '#load_photosets' do
      it 'loads and parses the photoset JSON' do
        data = @storage.load_photosets
        data['photosets']['photoset'][0]['id'].must_equal @set_id
      end
    end

    describe '#load_photo_info' do
      it 'loads and parses the photo JSON' do
        data = @storage.load_photo_info(@photo_id, @set_id)
        data['photo']['id'].must_equal @photo_id
      end
    end

    describe '#load_photoset_photos' do
      it 'loads and parses the photoset photos JSON' do
        data = @storage.load_photoset_photos(@set_id)
        data['photoset']['photo'][0]['id'].must_equal @photo_id
      end
    end
  end

end
