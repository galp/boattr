module Boattr
  class Data
    attr_reader :basename
    def initialize(params)
      @graphite    = params['graphite']['host']
      @couchdb     = params['couchdb']['host']
      @basename    = params['boattr']['basename']
      unless @graphite.nil? || @graphite.empty?
        @g         = Graphite.new(host: "#{@graphite}", port: 2003)
      end
      unless @couchdb.nil? || @couchdb.empty?
        @sensorsdb = CouchRest.database!("http://#{@couchdb}:5984/#{@basename}-sensors")
        @statsdb   = CouchRest.database!("http://#{@couchdb}:5984/#{@basename}-stats")
      end
    end

    def to_db(sensor_data)
      @data  = sensor_data
      @data.each do |x|
        next if x.nil?
        p x
        @doc = { '_id' => now }.merge x
        @sensorsdb.save_doc(@doc)
      end
    end

    def create_views(sensor_data,type)
      # at this point this only creates  views of the same type, in one design doc.
      @data       = sensor_data
      @views      = {}
      @data.each do |x|
        next if x.nil? || x['type'] != type
        @name  = x['name']
        @type  = x['type']
        @view  = { "#{@name}".to_sym => {
          map: "function(doc) {  if (doc.name == \"#{@name}\" && doc.type == \"#{@type}\" ) {  emit(doc._id, doc.value);  }}",
          reduce: '_stats' }
        }
        @views.merge!(@view)
      end
      begin
        doc = @sensorsdb.get("_design/#{type}")
        doc['views'] = @views
        @sensorsdb.save_doc(doc)
      rescue
        @sensorsdb.save_doc(
          '_id' => "_design/#{@type}",
          :language => 'javascript',
          :views    =>  @views
        )
      end
    end

    def amphours(sensor_data, hours = 24)
      @data  = sensor_data
      @hours = hours
      @from = Time.now.to_i - @hours * 60 * 60
      @merged = []
      @data.each do |x|
        next if x.nil? || x['type'] != 'current'
        @name   = x['name']
        @type   = x['type']
        @mode   = x['mode']
        @view   = URI.escape("current/#{@name}?startkey=\"#{@from}\"")
        @result =  @sensorsdb.view(@view)['rows'][0]['value']
        @sum    = @result['sum']
        @count  = @result['count']
        @amph   = @sum / (@hours * 60 / @hours) # is this correct?
        @sensor = { 'name' => @name,  'type' => 'amphours', 'mode' => @mode, 'hours' => @hours, 'value' => @amph.round(2) }
        @merged << @sensor
      end
      @merged
    end
    def amphour_balance(amphours_data)
      @loads, @sources = 0, 0
      @amphours       = amphours_data
      @amphours.each do |x|
        if x['type'] == 'amphours' &&  x['mode'] == 'src'
          @sources += x['value']
        end
        if x['type'] == 'amphours' && x['mode'] == 'load'
          @loads += x['value']
        end
      end
      [{ 'name' => 'sources', 'type' => 'amphours', 'hours' => @hours, 'value' => @sources.round(2) },
       { 'name' => 'loads', 'type' => 'amphours', 'hours' => @hours, 'value' => @loads.round(2) }]
    end

    def to_graphite(sensor_data)
      return if @g.nil?
      @basename  = basename
      @data      = sensor_data
      @data.each do |x|
        next if x.nil?
        @type  = x['type']
        @name  = x['name']
        @value = x['value']
        @g.push_to_graphite do |graphite|
          graphite.puts "#{@basename}.#{@type}.#{@name} #{@value} #{@g.time_now}"
        end
      end
    end

    def now
      # used by to_db()
      Time.now.to_f.round(2).to_s
    end

    def get_remaining_data(name)
      @name = name
      @butes = 0
      begin
        @page = Nokogiri::HTML(open('http://add-on.ee.co.uk/status'))
        @data = @page.css('span')[0].text
      rescue
        return
      end
      @unit = @data.slice(-2..-1)
      if @unit == 'GB'
        @bytes = @data.slice(0..-3).to_f
      else
        @bytes = @data.slice(0..-3).to_f / 1000.0
      end
      { 'name' => @name, 'type' => 'data', 'value' => @bytes.round(2) }
    end
  end
end
