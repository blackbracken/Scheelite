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
      mention: "<!channel>"
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
    is_available = Pinger.new(address, count: 4).ping
    last_available = available_repo.last_available address

    available_repo.report(address, is_available)

    puts "#{address} is #{is_available ? "up" : "down"}"

    if is_available ^ last_available
      available_percent = "#{available_repo.calc_available_percent(address).to_s}%"

      if is_available
        # down -> up
        HTTP::Client.post config.webhook_url, body: "{ \"text\": \"#{config.mention} :signal_strength: The server `#{address}` is currently up! Available: #{available_percent}\" }"
      else
        # up -> down
        HTTP::Client.post config.webhook_url, body: "{ \"text\": \"#{config.mention} :warning: The server `#{address}` is currently down! Available: #{available_percent}\" }"
      end
    end
  end

  available_repo.flush
  sleep 5.minutes
end