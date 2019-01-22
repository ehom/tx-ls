require 'tx-ls/tx-webhooks-service-config'
require 'restclient'
require 'json'
require 'fileutils'

class TxWebhooksService
  def initialize(tx_client)
    @url       = TxWebhooksServiceConfig.new.url
    @tx_client = tx_client
  end

  def webhooks(progress_reporter)
    # read webhooks file if available
    # if not, then call the service.
    
    begin
      application_data_folder = "%{dir}/.tx-ls" % { dir: Dir.home }
      filepath_to_webhooks = "%{dir}/webhooks.json" % { dir: application_data_folder }
      json_file = File.read(filepath_to_webhooks)
      table_of_webhooks = JSON.parse(json_file)
    rescue
      number_of_projects = @tx_client.projects.length
      table_of_webhooks = @tx_client.projects.each_with_object({}).with_index do |(project, table), index|
        slug        = project["slug"]
        table[slug] = webhooks_from(org: @tx_client.organization, project_slug: slug)
        progress_reporter.update(index, number_of_projects, slug)
      end

      FileUtils.mkdir_p application_data_folder
      File.open(filepath_to_webhooks, "w") do |f|
        f.write(JSON.pretty_generate(table_of_webhooks))
      end
    end
    table_of_webhooks
  end

  private

  def webhooks_from(org: '', project_slug: '' )
    url = @url % { org: org, project_slug: project_slug }
    response = RestClient::Request.execute method: :get, url: "#{url}", user: @tx_client.username, password: @tx_client.password
    JSON.parse response.body
  end
end
