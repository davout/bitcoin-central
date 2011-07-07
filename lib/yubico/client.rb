require 'net/https'

module Yubico
  class Client
    include Singleton
    
    configuration = YAML::load(File.open(File.join(Rails.root, "config", "yubico.yml")))[Rails.env]
    
    API_URL = configuration["api_url"]
    API_ID = configuration["api_id"]
    API_KEY = configuration["api_key"]
    
    def verify_otp(otp)
      uri = URI.parse(API_URL) + 'verify'
      uri.query = "id=#{API_ID}&otp=#{otp}"
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      req = Net::HTTP::Get.new(uri.request_uri)
      result = http.request(req).body
      
      status = result[/status=(.*)$/,1].strip

      status == "OK" || (status == "REPLAYED_OTP" && raise(Yubico::ReplayedOTPError))
    end
  end
end