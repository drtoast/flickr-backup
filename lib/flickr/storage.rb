require 'json'
require 'fileutils'

module Flickr
  class Storage
    attr_reader :archive_path

    def initialize(options)
      @archive_path = options['archive_path']
    end

    # PATHS

    def photosets_path
      File.join(archive_path, 'photosets')
    end

    def photosets_json_path
      File.join(archive_path, 'photosets.json')
    end

    def favorites_json_path
      File.join(archive_path, 'favorites', 'favorites.json')
    end

    def photoset_path(set_id)
      if set_id == :favorites
        File.join(archive_path, 'favorites')
      else
        File.join(photosets_path, set_id)
      end
    end

    def photoset_json_path(set_id)
      File.join(photoset_path(set_id), "photoset.json")
    end

    def photoset_photos_json_path(set_id)
      File.join(photoset_path(set_id), "photos.json")
    end

    def photo_path(photo_id, set_id)
      File.join(photoset_path(set_id), 'photos', photo_id)
    end

    def photo_image_path(photo_id, set_id, originalformat)
      File.join(photo_path(photo_id, set_id), "#{photo_id}.#{originalformat}")
    end

    def photo_info_json_path(photo_id, set_id)
      File.join(photo_path(photo_id, set_id), "info.json")
    end

    def photo_comments_json_path(photo_id, set_id)
      File.join(photo_path(photo_id, set_id), "comments.json")
    end

    def photo_exif_json_path(photo_id, set_id)
      File.join(photo_path(photo_id, set_id), "exif.json")
    end

    # LOAD

    def load_photosets
      JSON.parse(File.read(photosets_json_path))
    end

    def load_photo_info(photo_id, set_id)
      JSON.parse(File.read(photo_info_json_path(photo_id, set_id)))
    end

    def load_photoset_photos(set_id)
      JSON.parse(File.read(photoset_photos_json_path(set_id)))
    end

    # SAVE

    def save_photo_info_json(photo_info, photo_id, set_id)
      save_json(photo_info, photo_info_json_path(photo_id, set_id))
    end

    def save_photo_comments_json(photo_comments, photo_id, set_id)
      save_json(photo_comments, photo_comments_json_path(photo_id, set_id))
    end

    def save_photo_exif_json(photo_exif, photo_id, set_id)
      save_json(photo_exif, photo_exif_json_path(photo_id, set_id))
    end

    def save_photosets_json(photosets)
      save_json(photosets, photosets_json_path)
    end

    def save_favorites_json(favorites)
      save_json(favorites, favorites_json_path)
    end

    def save_photoset_photos_json(photos, set_id)
      save_json(photos, photoset_photos_json_path(set_id))
    end

    def save_photoset_json(set)
      set_id = set['id']
      save_json(set, photoset_json_path(set_id))
    end

    def save_json(data, destination)
      puts "writing #{destination}"

      FileUtils.mkdir_p(File.dirname(destination))
      File.open(destination, "w") do |f|
        f << JSON.pretty_generate(data)
      end
    end

    # EXISTS

    def exists?(path)
      File.exists?(path)
    end

    def photo_exists?(photo_id, set_id)
      data = load_photo_info(photo_id, set_id)
      originalformat = data['photo']['originalformat']
      exists? photo_image_path(photo_id, set_id, originalformat)
    end
  end
end
