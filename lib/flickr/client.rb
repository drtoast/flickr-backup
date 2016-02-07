require 'net/http'
require 'digest/md5'
require 'cgi'

module Flickr
  class Client
    SITE = "https://api.flickr.com/services/rest/"
    SITE_AUTH = "https://flickr.com/services/auth/"

    attr_accessor :response, :token, :frob, :config, :auth_token, :rate_limit

    def initialize(options={})
      @auth_token = options['auth_token']
      @rate_limit = options['rate_limit']
      @api_key = options['api_key']
      @api_secret = options['api_secret']
    end

    def get(method, params={})
      url = build_url(method, params)
      begin
        return get_json(url)
      rescue => e
        puts e.message
      end
    end

    def get_frob
      json = get 'flickr.auth.getFrob'
      data = JSON.parse(json)
      puts JSON.pretty_generate(data)
      data['frob']['_content']
    end

    def get_desktop_auth_link(frob)
      params = { api_key: DESKTOP_API_KEY, perms: 'read', frob: frob }
      params[:api_sig] = make_api_sig(params.dup)
      SITE_AUTH + "?" + hash_to_query(params)
    end

    def get_token(frob)
      params = { frob: frob }
      json = get 'flickr.auth.getToken', params
      data = JSON.parse(json)
      data['auth']['token']['_content']
    end

    private

    # http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=xxx&photo_id=xxxx
    def build_url(api_method, params)
      params[:method] = api_method
      params[:api_key] = @api_key
      params[:auth_token] = auth_token if auth_token
      params[:format] = 'json'
      params[:nojsoncallback] = '1'

      add_signature(params)

      url = SITE + "?" + hash_to_query(params)
    end

    def add_signature(params)
      if ['flickr.auth.getToken', 'flickr.auth.getFrob'].include?(params[:method]) || params[:auth_token]
        params[:api_sig] = make_api_sig(params.dup)
      end
    end

    def get_json(url)
      puts "fetching #{url}"
      response = get_http(url)

      if response.code == '200'
        sleep 1 if rate_limit # 3600 requests/hour max
        return response.body
      else
        puts "ERROR: #{response.class.to_s}: #{url}"
      end
    end

    def get_http(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      http.use_ssl = true
      http.request(request)
    end

    def hash_to_query(params)
      q = params.map do |query_field, value|
        query_field = CGI.escape(query_field.to_s)
        query_value = CGI.escape(value.to_s)
        "#{query_field}=#{query_value}"
      end
      q.length > 0 ? q.join('&') : ''
    end

    def make_api_sig(values)
      api_string = values.sort{|a,b| a[0] <=> b[0]}.flatten.unshift(@api_secret).join('')
      Digest::MD5.hexdigest(api_string)
    end
  end
end
