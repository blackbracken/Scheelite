# Scheelite
A slack bot to monitor status of servers

## Config
```yaml
# webhook URL for slack bot
webhook_url: "https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxx"

# a prefix of messages
# <!channel> <!here> <![USER_ID]> etc.
mention: "<!channel>"

# addresses to be monitored
pinged:
  - "google.com"
  - "xxx.xxx.xxx.xxx"
```

## Usage
Download binary from [releases](https://github.com/blackbracken/Scheelite/releases) or build this repository.

`./Scheelite`