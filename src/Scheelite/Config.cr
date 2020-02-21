require "yaml"

module Scheelite
  class Config
    YAML.mapping(
      webhook_url: String,
      pinged: Array(String)
    )
  end
end