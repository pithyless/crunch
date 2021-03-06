require 'bson'

module Crunch
  
  # The packed binary stuff that goes to MongoDB and comes back. Subclasses implement the specific 
  # header codes and such.
  class Message < BSON::ByteBuffer
    attr_reader :delivered_at
    
    @opcode = 1000  # OP_MSG
    
    @@request_id = 0

    # Generates a new request ID. Monotonically increases across all classes.
    def self.request_id
      @@request_id += 1
    end
    
    def self.opcode
      @opcode
    end
    
    # The request ID for this specific message.
    def request_id
      @request_id ||= self.class.request_id
    end
        
    # The content of the message. Will be overridden in every subclass with more interesting behavior.
    def body
      "To sit in sullen silence...\x00".force_encoding(Encoding::BINARY)
    end
    
    # Puts everything together.
    def deliver
      @delivered_at = Time.now.utc
      header = [(body.length + 16), 
        request_id,
        0,
        self.class.opcode].pack('VVVV')
      "#{header}#{body}"
    end
    

  end
end