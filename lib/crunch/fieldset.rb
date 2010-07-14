require 'bson'

module Crunch
  
  # What the BSON spec describes as a "document" -- a hashlike binary structure.  In practice, a Fieldset
  # is a _lot_ like a Hash, with two major differences:
  #   1. All keys are strings; and
  #   2. It's immutable. (Hence, #[]= and all in-place modifiers like #merge! are missing.)
  #
  # @see http://bsonspec.org/#/specification
  class Fieldset < Hash
    
    # Enable the replacement we need to do in the initializer
    alias_method :private_replace, :replace
    private :private_replace
    
    # Returns the document as a binary string in BSON format.
    # @see http://bsonspec.org/#/specification
    # @return String
    def to_s
      BSON.serialize(self).to_s
    end
    
    # We're immutable!  These pesky modification methods aren't allowed.
    # (If you're wondering WHY we're immutable, consider the difference between MongoDB retrieval techniques
    # and MongoDB value setting techniques. Then consider what it would be like if we had to make every hash
    # in Crunch threadsafe against document changes queued up in EventMachine. Then consider pretty puppies
    # and rainbows, because you're gonna need a break.)
    def []=(*args)
      raise FieldsetError, "Fieldset objects are immutable!"
    end
    alias_method :update,   :[]=
    alias_method :store,    :[]=
    alias_method :shift,    :[]=
    alias_method :replace,  :[]=
    alias_method :reject!,  :[]=
    alias_method :rehash,   :[]=
    alias_method :merge!,   :[]=
    alias_method :delete_if,:[]=
    alias_method :delete,   :[]=
    alias_method :clear,    :[]=
        
    # @param [optional, Hash, String, BSON::ByteBuffer] data Sets the hash values -- either directly, or after deserializing if a BSON binary string is provided
    def initialize(data=nil)
      super(nil)
      
      hash = case data
      when Fieldset then data   # Don't bother doing anything
      when Hash then stringify_keys(data)
      when String then BSON.deserialize(BSON::ByteBuffer.new(data))
      when BSON::ByteBuffer then BSON.deserialize(data)
      when nil then nil
      else raise FieldsetError, "Crunch::Fieldset can only be initialized from a hash or binary data! You supplied: #{data}"
      end
      
      private_replace(hash) if hash
      self.freeze
    end
    
    private
    
    # Turns all keys into their string values. Inefficient, but it gets too confusing if we don't.
    def stringify_keys(hash)
      out = {}
      hash.each {|k,v| out[k.to_s] = v}
      out
    end
  end
end