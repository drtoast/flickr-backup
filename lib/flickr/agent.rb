require_relative 'storage'
require_relative 'downloader'
require_relative 'client'
require 'json'

module Flickr
  class Agent
    attr_reader :client, :storage, :downloader, :user_id, :auth_token, :overwrite

    def initialize(options)
      @user_id = options['user_id']
      @overwrite = options['overwrite']
      @storage = Flickr::Storage.new(options)
      @downloader = Flickr::Downloader.new(options)
      @client = Flickr::Client.new(options)
    end

    def get_auth_token
      frob = client.get_frob
      puts "Visit this URL and then press return:"
      puts client.get_desktop_auth_link(frob)
      STDIN.gets
      token = client.get_token(frob)
      puts %Q(Add to config.json: "auth_token": "#{token}")
    end

    def fetch_photosets
      json = client.get 'flickr.photosets.getList', user_id: user_id
      data = JSON.parse(json)
      storage.save_photosets_json(data)

      data['photosets']['photoset'].each do |set|
        storage.save_photoset_json(set)
        fetch_photoset(set['id'])
      end
    end

    def fetch_favorites
      json = client.get 'flickr.favorites.getList', user_id: user_id
      data = JSON.parse(json)
      storage.save_favorites_json(data)

      data['photos']['photo'].each do |photo|
        photo_id = photo['id']
        fetch_photo_info(photo_id, :favorites)
        fetch_photo_comments(photo_id, :favorites)
        fetch_photo_exif(photo_id, :favorites)
        downloader.download(photo_id, :favorites)
      end
    end

    def fetch_photoset(set_id)
      json = client.get 'flickr.photosets.getPhotos', photoset_id: set_id
      data = JSON.parse(json)
      storage.save_photoset_photos_json(data, set_id)
      data['photoset']['photo'].each do |photo|
        photo_id = photo['id']
        fetch_photo_info(photo_id, set_id)
        fetch_photo_comments(photo_id, set_id)
        fetch_photo_exif(photo_id, set_id)
        downloader.download(photo_id, set_id)
      end
    end

    def fetch_photo_info(photo_id, set_id)
      unless overwrite
        return if storage.exists?(storage.photo_info_json_path(photo_id, set_id))
      end

      json = client.get 'flickr.photos.getInfo', photo_id: photo_id
      data = JSON.parse(json)
      storage.save_photo_info_json(data, photo_id, set_id)
    end

    def fetch_photo_comments(photo_id, set_id)
      return if storage.exists?(storage.photo_comments_json_path(photo_id, set_id))
      json = client.get 'flickr.photos.comments.getList', photo_id: photo_id
      data = JSON.parse(json)
      storage.save_photo_comments_json(data, photo_id, set_id)
    end

    def fetch_photo_exif(photo_id, set_id)
      return if storage.exists?(storage.photo_exif_json_path(photo_id, set_id))
      json = client.get 'flickr.photos.getExif', photo_id: photo_id
      data = JSON.parse(json)
      storage.save_photo_exif_json(data, photo_id, set_id)
    end
  end
end
