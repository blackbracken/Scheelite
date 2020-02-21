require "file"
require "yaml"
require "json"
require "http/client"
require "pinger"

require "./Scheelite/Available.cr"
require "./Scheelite/Config.cr"

CONFIG_PATH = "./config.yml"
AVAILABLE_PATH = "./available.json"

if !File.exists? CONFIG_PATH
  File.open(CONFIG_PATH, "w") do |config_file|
    config_file.puts <<-YAML
      webhook_url: "https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      pinged:
        - "xxx.xxx.xxx.xxx"
        - "google.com"
      YAML
  end
end

config_file = File.open CONFIG_PATH, "r"
config = Scheelite::Config.from_yaml(config_file)
config_file.close

available_repo = Scheelite::AvailableRepository.new(AVAILABLE_PATH)

loop do
  config.pinged.each do |address|
    pinger = Pinger.new address, count: 4

    if !pinger.ping
      response = HTTP::Client.post config.webhook_url, body: "{ \"text\": \"<!channel> :warning: The server `#{address}` is currently down! \" }"
      puts "ng"
      available_repo.report(address, false)
    else
      puts "ok"
      available_repo.report(address, true)
    end
  end

  available_repo.flush
  sleep 10.minutes
end