module Crunch
  class QueryMessage < Message
    @opcode = 2004  # OP_QUERY
    
    attr_reader :sender, :collection_name
    attr_accessor :conditions, :fields, :skip, :limit
    
    # The only required parameter is a Crunch::Collection object. The query criteria,
    # options, etc. will be happily accepted as options, or can be set via accessors
    # at any time prior to sending.  (Note: At this time, tailable cursors and other
    # advanced query options are not supported.)
    #
    # @param [Crunch::Document, Crunch::Group] sender The object sending this message (so that we know where to route replies)
    # @param [optional Hash] opts Optional parameters
    # @option opts [Hash] :query ({}) The selection criteria
    # @option opts [Array] :fields ([]) An optional list of fields to return (returns all if empty)
    # @option opts [Integer] :skip Skip the first x records (for paging)
    # @option opts [Integer] :limit Return only y records
    def initialize(sender, opts={})
      @sender = sender
      @collection_name = sender.collection_name
      @conditions  = opts[:conditions]  || {}
      @fields = opts[:fields] || []
      @skip   = opts[:skip]   || 0
      @limit  = opts[:limit]  || 0
    end
      
    
    # @see http://www.mongodb.org/display/DOCS/Mongo+Wire+Protocol
    def body
      conditions_bson = BSON.serialize @conditions      
      "\x00\x00\x00\x00#{collection_name}\x00#{[skip, limit].pack('VV')}#{conditions_bson}#{field_bson}"
    end
    
    private
    # Produces the hash of {field => 1} values required by the wire protocol
    def field_bson
      return nil if @fields.nil? || @fields.empty?
      hash = {'_id' => 1}
      @fields.each {|field| hash[field] = 1}
      BSON.serialize hash
    end
  end
end
