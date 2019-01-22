require 'restclient'
require 'json'

class TxFormatsService
  def initialize(tx_client)
    @url       = "https://www.transifex.com/api/2/formats/"
    @tx_client = tx_client
  end

  def formats
    response = RestClient::Request.execute method: :get, url: "#{@url}", user: @tx_client.username, password: @tx_client.password
    JSON.parse response.body
  end
end
