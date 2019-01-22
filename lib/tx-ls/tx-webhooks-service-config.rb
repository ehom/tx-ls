class TxWebhooksServiceConfig
  def url
    'https://api.transifex.com/organizations/%{org}/projects/%{project_slug}/webhooks/'
  end
end