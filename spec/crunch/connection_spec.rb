require File.dirname(__FILE__) + '/../spec_helper'

module Crunch
  # Test the Connection module without having to screw around with EventMachine
  class DummyConnection
    include Connection
  end
  
  describe Connection do
    def random_spew(count=262)
      i = 0
      while i < count do
        r = rand(20)
        @this.receive_data(@reply_data[i..i+r-1])
        i += r
      end
    end
    
    before(:each) do
      @reply_data = [0x06,0x01,0x00,0x00,0x23,0x38,0x27,0xDE,0x09,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0xE2,0x00,0x00,0x00,0x07,0x5F,0x69,0x64,0x00,0x4C,0x44,0xD1,0x8D,0x3F,0x16,0x51,0x03,0x02,0x00,0x00,0x01,0x0E,0x66,0x6F,0x6F,0x00,0x04,0x00,0x00,0x00,0x62,0x61,0x72,0x00,0x01,0x6E,0x75,0x6D,0x6D,0x79,0x00,0x3B,0xFC,0x35,0x59,0xA3,0x0E,0x27,0x40,0x02,0x73,0x74,0x72,0x69,0x6E,0x67,0x79,0x00,0xA3,0x00,0x00,0x00,0x4E,0x6F,0x77,0x20,0x69,0x73,0x20,0x74,0x68,0x65,0x20,0x74,0x69,0x6D,0x65,0x20,0x66,0x6F,0x72,0x20,0x61,0x6C,0x6C,0x20,0x67,0x6F,0x6F,0x64,0x20,0x6D,0x65,0x6E,0x20,0x74,0x6F,0x20,0x63,0x6F,0x6D,0x65,0x20,0x74,0x6F,0x20,0x74,0x68,0x65,0x20,0x61,0x69,0x64,0x20,0x6F,0x66,0x20,0x74,0x68,0x65,0x69,0x72,0x20,0x70,0x61,0x72,0x74,0x79,0x2E,0x20,0x54,0x6F,0x20,0x73,0x69,0x74,0x20,0x69,0x6E,0x20,0x73,0x75,0x6C,0x6C,0x65,0x6E,0x20,0x73,0x69,0x6C,0x65,0x6E,0x63,0x65,0x20,0x6F,0x6E,0x20,0x61,0x20,0x64,0x75,0x6C,0x6C,0x20,0x64,0x61,0x72,0x6B,0x20,0x64,0x6F,0x63,0x6B,0x2E,0x2E,0x2E,0x20,0x20,0x54,0x68,0x65,0x20,0x71,0x75,0x69,0x63,0x6B,0x20,0x62,0x72,0x6F,0x77,0x6E,0x20,0x66,0x6F,0x78,0x20,0x6A,0x75,0x6D,0x70,0x65,0x64,0x20,0x6F,0x76,0x65,0x72,0x20,0x74,0x68,0x65,0x20,0x6C,0x61,0x7A,0x79,0x20,0x64,0x6F,0x67,0x2E,0x00,0x00,0x06,0x01,0x00,0x00,0x23,0x38,0x27,0xDE,0x09,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0xE2,0x00,0x00,0x00,0x07,0x5F,0x69,0x64,0x00,0x4C,0x44,0xD1,0x8D,0x3F,0x16,0x51,0x03,0x02,0x00,0x00,0x01,0x0E,0x66,0x6F,0x6F,0x00,0x04,0x00,0x00,0x00,0x62,0x61,0x72,0x00,0x01,0x6E,0x75,0x6D,0x6D,0x79,0x00,0x3B,0xFC,0x35,0x59,0xA3,0x0E,0x27,0x40,0x02,0x73,0x74,0x72,0x69,0x6E,0x67,0x79,0x00,0xA3,0x00,0x00,0x00,0x4E,0x6F,0x77,0x20,0x69,0x73,0x20,0x74,0x68,0x65,0x20,0x74,0x69,0x6D,0x65,0x20,0x66,0x6F,0x72,0x20,0x61,0x6C,0x6C,0x20,0x67,0x6F,0x6F,0x64,0x20,0x6D,0x65,0x6E,0x20,0x74,0x6F,0x20,0x63,0x6F,0x6D,0x65,0x20,0x74,0x6F,0x20,0x74,0x68,0x65,0x20,0x61,0x69,0x64,0x20,0x6F,0x66,0x20,0x74,0x68,0x65,0x69,0x72,0x20,0x70,0x61,0x72,0x74,0x79,0x2E,0x20,0x54,0x6F,0x20,0x73,0x69,0x74,0x20,0x69,0x6E,0x20,0x73,0x75,0x6C,0x6C,0x65,0x6E,0x20,0x73,0x69,0x6C,0x65,0x6E,0x63,0x65,0x20,0x6F,0x6E,0x20,0x61,0x20,0x64,0x75,0x6C,0x6C,0x20,0x64,0x61,0x72,0x6B,0x20,0x64,0x6F,0x63,0x6B,0x2E,0x2E,0x2E,0x20,0x20,0x54,0x68,0x65,0x20,0x71,0x75,0x69,0x63,0x6B,0x20,0x62,0x72,0x6F,0x77,0x6E,0x20,0x66,0x6F,0x78,0x20,0x6A,0x75,0x6D,0x70,0x65,0x64,0x20,0x6F,0x76,0x65,0x72,0x20,0x74,0x68,0x65,0x20,0x6C,0x61,0x7A,0x79,0x20,0x64,0x6F,0x67,0x2E,0x00,0x00,0x06,0x01,0x00,0x00,0x23,0x38,0x27,0xDE,0x09,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0xE2,0x00,0x00,0x00,0x07,0x5F,0x69,0x64,0x00,0x4C].pack('c*')
      @database = stub "Database", receive_reply: true
      @sender = stub "Document"
      @message = stub "QueryMessage", sender: @sender, request_id: 1337
      @this = DummyConnection.new @database
    end
    
    it "can receive data" do
      @this.should respond_to(:receive_data)
    end
    
    it "gets pieces of the message" do
      @database.expects(:receive_reply).with(@reply_data[0..261])
      random_spew
    end
    
    it "can receive multiple messages from pieces" do
      @database.expects(:receive_reply).twice.with(@reply_data[0..261])
      random_spew(524)
    end
    
    it "can receive a message all at once" do
      @database.expects(:receive_reply).with(@reply_data[0..261])
      @this.receive_data(@reply_data[0..261])
    end
    
    it "can receive multiple messages all at once" do
      @database.expects(:receive_reply).twice.with(@reply_data[0..261])
      @this.receive_data(@reply_data[0..523])
    end
    
  end
end