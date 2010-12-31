require 'net/http'
require 'addressable/uri'
require 'json'

module Bitcoin
  class JsonWrapper
    def initialize(url, username, password)
      @address = Addressable::URI.parse(url)
      @username = username
      @password = password
    end

    def request(params)
      result = nil

      full_params = params.merge({
          :jsonrpc => "2.0",
          :id => (rand * 10 ** 12).to_i.to_s
        })

      request_body = full_params.to_json

      Net::HTTP.start(@address.host, @address.port) do |connection|
        post = Net::HTTP::Post.new(@address.path)
        post.body = request_body
        post.basic_auth(@username, @password)
        result = connection.request(post)
        result = JSON.parse(result.body)
      end

      if error = result["error"]
        raise "#{error["message"]}, request was #{request_body}"
      end

      result = result["result"]
      result
    end
  end
end
