require 'tx-ls/tx-secret'
require 'tx-ls/tx-client'
require 'tx-ls/tx-webhooks-service'
require 'tx-ls/tx-formats-service'

require 'pp'
require 'optparse'

class TxProjectsLister
  def initialize(projects)
    @projects = projects
  end

  def display
    headers = "\n%s %s %s\n\n" % [ "project-name".ljust(32), "project-slug".ljust(32), "source-language-code".center(20)] 

    @projects.each_with_index do |project, index|
      puts headers if index % 10 == 0
      puts "%s %s %s" % [ project["name"].ljust(32, "."), project["slug"].ljust(32), project["source_language_code"].center(20, '.')   ]
    end
  end
end

class TxWebhooksLister
  def initialize(webhooks)
    @webhooks = webhooks
  end

  def display
    @webhooks.sort.to_h.each_pair do |project_name, project_webhooks|
      puts "[#{project_name}]"
      if project_webhooks.empty?
        puts "no webhooks"
      end
      project_webhooks.each do |h|
        if h['status'] == 'active'
          puts "* %{url}" % { url: h["url"] }
        else
          puts "%{url}" % { url: h["url"] }
        end
      end
      puts
    end
  end
end

class TxSupportedFormatsLister
  def initialize(dictionary)
    @dictionary = dictionary
  end
  def display
    @dictionary.sort.to_h.each_pair do |key, value|
      puts "%32s:" % [ key ]
      display_pair("file-extensions", value["file-extensions"])
      display_pair("description", value["description"])
      display_pair("mimetype", value["mimetype"])
      puts
    end
  end
  def display_pair(key, value)
    formatted_key_string = "%32s" % [ key ]
    puts "#{formatted_key_string}: \"#{value}\""
  end
end

class TxGetWebhooksProgressReporter
  def initialize
  end

  def update(index, number_of_projects, slug)
    puts "%2d of %d: Getting webhooks from `%s`..." % [index,  number_of_projects, slug]
  end
end
  
module App
  def self.parse(arguments)
    options = {}

    option_parser = OptionParser.new do |opts|
      opts.banner = "Usage: tx-ls.rb [options]"
      opts.separator ""
      opts.separator "Options"

      opts.on("--formats", "List supported formats") do |formats|
        options[:formats] = true
      end

      opts.on("--projects", "List projects") do |projects|
        options[:projects] = true
      end

      opts.on("--webhooks", "List webhooks of each project") do |webhooks|
        options[:webhooks] = true
      end

      opts.on("-h", "--help", "Prints this help") do
        puts option_parser
        exit
      end
    end

    option_parser.parse! arguments

    if options.empty?
      puts option_parser
      exit
    else
      options
    end
  end

  def self.main(arguments)
    options = parse arguments

    login_info = TxSecret.new(password: ENV['TX_API_TOKEN'], organization: ENV['TX_ORG'])
    tx_client  = TxClient.new(login_info)

    if options[:projects]
      TxProjectsLister.new(tx_client.projects).display
    end

    if options[:formats] 
      TxSupportedFormatsLister.new(TxFormatsService.new(tx_client).formats).display
    end
   
    if options[:webhooks] 
      webhooks = TxWebhooksService.new(tx_client).webhooks(TxGetWebhooksProgressReporter.new)
      TxWebhooksLister.new(webhooks).display
    end
  end
end
