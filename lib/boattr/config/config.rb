module Boattr
  class Config
    attr_reader :enabled_sensors, :read
    def self.read(config_file = './config.yml')
      parsed = begin
                 YAML.load(File.open(config_file))
               rescue ArgumentError => e
                 puts "Could not parse config file: #{e.message}"
               end
    end
    def self.enabled_sensors(config = self.read)
      @data = []
      config['sensors'].each() do |k,v| 
        v.each() do |x| 
          next if x[1]['disabled']
          @data <<  x[1].merge!({'type' => k, 'name' => x[0] })
        end
      end
      return @data
    end
  end
end
