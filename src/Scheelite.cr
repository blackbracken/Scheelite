require "file"
require "yaml"
require "json"
require "http/client"
require "pinger"

require "./Scheelite/Available.cr"

CONFIG_PATH = "./config.yaml"
AVAILABLE_PATH = "./available.json"

module Scheelite
  class ScheeliteConfig
    YAML.mapping(
      webhook_url: String,
      pinged: Array(String)
    )
  end
end

if !File.exists? CONFIG_PATH
  config = File.open CONFIG_PATH, "w"
  config.puts <<-YAML
    webhook_url: "https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    pinged:
      - "xxx.xxx.xxx.xxx"
      - "google.com"
    YAML
  config.close
end

available_repo = Scheelite::AvailableRepository.new(AVAILABLE_PATH)

File.open(CONFIG_PATH) do |config_file|
  config = Scheelite::ScheeliteConfig.from_yaml(config_file)

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
end