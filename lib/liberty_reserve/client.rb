require 'builder'
require 'digest'
require 'net/https'

module LibertyReserve
  class Client
    def random_id
      (rand * 10 ** 9).to_i
    end

    def authentication_block(xml)
      secret = BitcoinBank::LibertyReserve['secret_word']
      token = "#{secret}:#{DateTime.now.utc.strftime("%Y%m%d:%H")}"
      token = Digest::SHA2.new.update(token).to_s.upcase

      xml.Auth do
        xml.ApiName BitcoinBank::LibertyReserve['api_name']
        xml.Token token
      end
    end

    def get_transaction(transaction_id = "49869203")
      account_id = BitcoinBank::LibertyReserve['account']

      send_request("history") do |xml|
        xml.HistoryRequest :id => random_id do
          authentication_block(xml)
          
          xml.History do
            xml.AccountId account_id
            xml.ReceiptId transaction_id
          end
        end
      end
    end

    def transfer(account, amount, currency)
      payer = BitcoinBank::LibertyReserve['account']

      send_request("transfer") do |xml|
        xml.TransferRequest :id => random_id do
          authentication_block(xml)

          xml.Transfer do
            xml.TransferType "transfer"
            xml.Payer payer
            xml.Payee account
            xml.CurrencyId currency
            xml.Amount amount
            xml.Anonymous "false"
          end
        end
      end
    end

    # Get history for last 7 days and last 20 transactions
    def history(currency)
      account_id = BitcoinBank::LibertyReserve['account']

      send_request("history") do |xml|
        xml.HistoryRequest :id => random_id do
          authentication_block(xml)

          xml.History do
            xml.CurrencyId currency
            xml.AccountId account_id
            xml.PageSize  "20"
          end
        end
      end
    end

    private

    def send_request(operation)
      result = nil

      # certificate = OpenSSL::X509::Certificate.new(File.read(File.join(Rails.root, "config", "liberty_reserve.pem")))
      uri = URI.parse(BitcoinBank::LibertyReserve['api_uri'])

      http = Net::HTTP.new(uri.host, '443')
      http.use_ssl = true

      # TODO : Actually verify the server certificate
      # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      # http.cert = certificate

      http.start do |http|
        req = Net::HTTP::Get.new("/xml/#{operation}.aspx?req=#{generate_xml{ |xml| yield(xml) }}")
        response = http.request(req)
        result = Hash.from_xml(response.body)
      end

      if result["#{operation.capitalize}Response"]['Error']
        raise "#{result["#{operation.capitalize}Response"]['Error']['Code']} - #{result["#{operation.capitalize}Response"]['Error']['Text']}"
      end

      result
    end

    def generate_xml
      request = String.new
      xml = Builder::XmlMarkup.new(:target => request)
      xml.instruct!
      yield(xml)
      CGI::escape(request)
    end
  end
end
