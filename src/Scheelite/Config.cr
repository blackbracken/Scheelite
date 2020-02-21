require "yaml"

module Scheelite
  class Config
    YAML.mapping(
      webhook_url: String,
      mention: String,
      pinged: Array(String)
    )
  end
end