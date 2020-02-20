require "file"
require "yaml"
require "http/client"
require "pinger"

CONFIG_PATH = "./config.yaml"

class ScheeliteConfig
  YAML.mapping(
    webhook_url: String,
    pinged: Array(String)
  )
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

File.open(CONFIG_PATH) do |file|
  config = ScheeliteConfig.from_yaml(file)

  loop do
    config.pinged.each do |server|
      pinger = Pinger.new server, count: 4
      puts "sent ping to #{server}"

      if !pinger.ping
        response = HTTP::Client.post config.webhook_url, body: "{ \"text\": \"<!channel> :warning: The server `#{server}` is currently down! \" }"
      end
    end

    sleep 10.minutes
  end
end