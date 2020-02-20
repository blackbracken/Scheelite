require "file"
require "yaml"
require "http/client"
require "pinger"

CONFIG_PATH = "./config.yaml"

if !File.exists?(CONFIG_PATH)
  config = File.open CONFIG_PATH, "w"
  config.puts <<-DEFAULT_CONFIG
    Slack:
      WebhookURL: "https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    Pinged:
      - "xxx.xxx.xxx.xxx"
      - "google.com"
    DEFAULT_CONFIG
  config.close
end

File.open(CONFIG_PATH) do |file|
  config = YAML.parse file
  url = config["Slack"]["WebhookURL"].as_s
  pinger = Pinger.new("google.com", count: 4)
  response = HTTP::Client.post url, body: "{ \"text\": \"Hello, yoneyan #{pinger.ping}\" }"
  
  puts response.body
end