module Boattr
  class Dashing
    attr_reader :host
    def initialize(params)
      @host      = params['dashing']['host']
      @dash_auth = params['dashing']['auth']
    end

    def to_dashboard(sensor_data)
      @data = sensor_data
      @data.each do |x|
        next if x.nil?
        @type  = x['type']
        @name  = x['name']
        @value = x['value']
        HTTParty.post("http://#{@host}:3030/widgets/#{@type}#{@name}",
                      body: {
                        auth_token: "#{@dash_auth}",
                        current: @value,
                        moreinfo: @type,
                        title: @name }.to_json
                      )
      end
    end

    def list_to_dashboard(sensor_data, widget)
      @data   = sensor_data
      @widget = widget
      @items  = []
      @data.each do |x|
        next if x.nil?
        @name  = x['name']
        @value = x['value']
        @hours = x['hours']
        @items << { label: @name, value: @value }
      end
      HTTParty.post("http://#{@host}:3030/widgets/#{@widget}",
                    body: {
                      auth_token: "#{@dash_auth}",
                      items: @items,
                      moreinfo: "last #{@hours} hours",
                      title: @widget }.to_json
                    )
    end
  end
end
