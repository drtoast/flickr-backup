require_relative 'storage'

module Flickr
  class Report
    attr_reader :storage

    def initialize(options)
      @storage = Flickr::Storage.new(options)
    end

    def summary
      if ! File.directory?(storage.photosets_path)
        STDERR.puts "Before running a report, you must download photosets to #{storage.photosets_path} by running `ruby backup.rb`.\n\nExiting..."
        exit 1
      end

      storage.load_photosets['photosets']['photoset'].each do |photoset|
        set_id = photoset['id']
        set_title = photoset['title']['_content']

        storage.load_photoset_photos(set_id)['photoset']['photo'].each do |photo|
          photo_id = photo['id']
          photo_info = storage.load_photo_info(photo_id, set_id)['photo']

          photo_title = photo_info['title']['_content']
          photo_is_public = photo_info['visibility']['ispublic'] == 1
          photo_taken = photo_info['dates']['taken']

          puts [set_title, photo_taken, photo_title].join("\t")
        end
      end
    end
  end
end
