
module GeoStock
  module Response
    def self.from(value, opts = {})
      case value
      when Hash then ResponseHash.from(value, opts)
      when Array then ResponseArray.from(value, opts)
      else raise "Unexpected class. (#{value.class})"
      end
    end
  end
  class ResponseHash < Hash
    attr_accessor :code, :message
    def self.from(value, opts)
      h = new
      value.each do |k, v|
        h[k] = v
      end
      h.code = opts[:code]
      h.message = opts[:message]
      h
    end
  end
  class ResponseArray < Array
    attr_accessor :code, :message
    def self.from(value, opts)
      a = new
      a.push *value
      a.code = opts[:code]
      a.message = opts[:message]
      a
    end
  end
end
