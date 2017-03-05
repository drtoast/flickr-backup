# Flickr Backup

This is a simple Ruby command line utility to maintain a local archive of your Flickr photosets, photos, and JSON metadata. Run it periodically to incrementally add any new photos or sets you've added.

**This will not download photos that are not in a photoset, but [the batch-edit page](https://www.flickr.com/photos/organize/) makes it easy to add all those photos into their own photoset.**

Photos and data will be saved in a hierarchy structured like this:

```
photosets.json
photosets/
  72157629556799377/
    photoset.json
    photos.json
    photos/
      6970875833/
        6970875833.jpg
        comments.json
        exif.json
        info.json
```

where:

  * `photosets.json` is the list of all your photosets
  * `photosets` is a directory containing one subdirectory per photoset
  * `72157629556799377` is a subdirectory containing one photoset
  * `photoset.json` contains metadata about one photoset
  * `photos.json` contains an index of the photos in that photoset
  * `6970875833` is a subdirectory containing one photo
  * `6970875833.jpg` is the downloaded original-sized photo
  * `comments.json` includes the comments for the photo
  * `exif.json` includes the EXIF metadata for the photo file
  * `info.json` includes the general metadata for the photo

## Limitations

Pagination is not handled yet, so if you have any sets with more than 500 photos or comments they won't all be downloaded. Test coverage is not complete, so the obvious caveats apply.

## Requirements

* Ruby 2.2
* Minitest (for development)

## Installation

1. `git clone git@github.com:drtoast/flickr-backup.git`
2. `gem install minitest` (for development only)

## Configuration

1. Copy `config.example.json` to `config.json`, and edit as follows.
2. Add your own `user_id`. You can look it up based on your username [here](https://www.flickr.com/services/api/explore/?method=flickr.people.findByUsername).
3. Add your own `api_key` and `api_secret`. You can get them  [here](https://www.flickr.com/services/apps/create/apply/?).
4. Add your `archive_path`. This is the full path to wherever you want to store your photos and data.
5. Set `rate_limit` to `true` or `false`. Note that Flickr has a pretty draconian limit of 3600 queries per hour per API key. If you think you might go over that, setting `rate_limit` to `true` will add a 1 second pause after each query.
6. Leave `auth_token` null for now - if you need it, you can get it by following the steps described later.

## Usage

To archive your **public photos**, just run `ruby backup.rb` with no arguments and you should be good to go.

To archive your **favorites**, run `ruby backup.rb favorites`.

To archive your **private photos**, you'll need an authorization token:

1. Run `ruby backup.rb token`
2. Visit the given URL and allow the requested access.
3. Hit `enter` and copy the given `auth_token` into your `config.json`
