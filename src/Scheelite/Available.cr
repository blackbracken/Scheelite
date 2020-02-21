require "json"

module Scheelite
  class AvailableRepository
    def initialize(@file_name : String)
      @hash = Hash(String, Available).new

      if File.exists? @file_name
        File.open(@file_name) do |json_file|
          @hash = Hash(String, Available).from_json(json_file)
        end
      end
    end

    def report(address : String, is_available : Bool)
      available = Available.new(0, 0, true)

      if @hash.has_key? address
        available = @hash[address]
      end

      available.count_trying += 1
      available.last_available = is_available
      if is_available
        available.count_successed += 1
      end

      @hash[address] = available
    end

    def flush()
      if File.exists? @file_name
        File.delete(@file_name)
      end

      File.open(@file_name, "w") do |json_file|
        json_file.puts @hash.to_json
      end
    end

    def calc_available_percent(address : String): Float32
      if !@hash.has_key? address
        100.to_f32
      end

      trying = @hash[address].count_trying
      successed = @hash[address].count_successed

      if trying == 0
        100.to_f32
      else
        100 * (successed.to_f32 / trying.to_f32)
      end
    end

    def last_available(address : String): Bool 
      if @hash.has_key? address
        @hash[address].last_available
      else
        true
      end
    end
  end

  class Available
    JSON.mapping(
      count_trying: UInt64,
      count_successed: UInt64,
      last_available: Bool
    )

    def initialize(@count_trying : UInt64, @count_successed : UInt64, @last_available)
    end
  end
end