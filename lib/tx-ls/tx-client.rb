require 'rest-client'
require 'json'
require 'tx-ls/tx-service-config'

class TxClient
  attr_reader :username, :password, :http_client, :projects,
              :organization

  def initialize(login_info)
    @username, @password, @organization = login_info.username, 
                                          login_info.password, 
                                          login_info.organization 
    @config      = TxServiceConfig.new
    @projects    = get_projects
  end

  private

  def get_projects
    response = RestClient::Request.execute method: :get, url: "#{@config.base_url}projects/", user: @username, password: @password
    JSON.parse response.body
  end
end
