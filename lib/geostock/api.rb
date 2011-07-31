require 'json'
require 'base64'
require 'net/http'
require 'uri'
require 'hmac'
require 'hmac-sha2'
require 'cgi'

module GeoStock
  class API
    REQUEST_EXPIRATION_TIME = 10 * 60 # 10 minutes
    REQUEST_URI_BASE = 'http://geostock.jp/api'

    def initialize(api_key, api_secret)
      raise "API_KEY must be present." if api_key.nil?
      raise "API_SECRET must be present." if api_secret.nil?
      @api_token = api_key
      @api_secret_token = api_secret
    end

    def collections
      get :collections, refresh: 1
    end

    def update_poi(col_name, value)
      update_pois col_name, value
    end
    def update_pois(col_name, value)
      post(:update_pois, col_name => value)
    end

    def delete_poi(value)
      delete_pois(value)
    end
    def delete_pois(value)
      post(:update_pois, value)
    end

    def get_poi(col_name, uid)
      get :get, col: col_name, id: uid
    end
    def get_all_pois(col_name)
      get :get_all, col: col_name
    end

    def create_collection(col_name)
      create_collections col_name
    end
    def create_collections(*col_names)
      col_names = [col_names].flatten
      post(:update_collections, col_names)
    end
    def update_collection(value)
      update_collections(value)
    end
    def update_collections(value)
      post(:update_collections, value)
    end
    def delete_collection(col_name)
      delete_collections(col_name)
    end
    def delete_collections(*col_names)
      col_names = [col_names].flatten
      post(:delete_collections, col_names)
    end

    private
    def sign_request(value)
      text = b64encode(generate_json(value))
      cur = (Time.now.utc.to_i / REQUEST_EXPIRATION_TIME)
      d = HMAC::SHA256.new(@api_secret_token)
      d.update text
      d.update cur.to_s
      [d.hexdigest, text].join('.')
    end
    def b64encode(text)
      Base64.encode64(text).tr('+/', '-_').gsub(/\n/, '')
    end
    def b64decode(text)
      Base64.decode64(text.tr('-_', '+/').gsub(/\n/, ''))
    end
    def generate_json(value)
      JSON.generate value
    end

    CMD2PATH = {
        delete_collections: 'collections/delete',
        update_collections: 'collections/update',
        delete_pois: 'pois/delete',
        update_pois: 'pois/update',
        collections: 'collections'
    }
    def post(cmd, value)
      params = { signed_request: sign_request(value)}
      path = CMD2PATH[cmd]
      raise "Unknown cmd:#{cmd}" unless path
      uri = URI.parse("#{url_base}/#{path}")
      post_to(uri, params)
    end
    def post_to(uri, params)
      query_string = params_to_query(params)
      resp = Net::HTTP.start(uri.host, uri.port) do |http|
        http.send(:post, uri.path, query_string)
      end
      rb = JSON.parse(resp.body)
      raise "Response body must be Hash or Array. (#{rb.class})" unless (rb.is_a?(Hash) || rb.is_a?(Array))
      GeoStock::Response.from(rb, code: resp.code, message: rb.is_a?(Hash) ? rb['message'] : nil)
    end
    def get(cmd, params = {})
      uri = URI.parse("#{url_base}/#{cmd}")
      get_from(uri, params)
    end
    def get_from(uri, params = {})
      query_string = params_to_query(params)
      resp = Net::HTTP.start(uri.host, uri.port) do |http|
        path = "#{uri.path}?#{query_string}"
        http.send(:get, path)
      end
      rb = JSON.parse(resp.body)
      raise "Response body must be Hash or Array. (#{rb.class})" unless (rb.is_a?(Hash) || rb.is_a?(Array))
      GeoStock::Response.from(rb, code: resp.code, message: rb.is_a?(Hash) ? rb['message'] : nil)
    end
    def url_base
      "#{REQUEST_URI_BASE}/#{@api_token}"
    end
    def params_to_query(params)
     params.map do |key,value|
       "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
     end.join("&")
    end
  end
end
