require_relative '../../spec_helper'
require_relative '../../shared_examples/message'

module Crunch
  describe UpdateMessage do
    BSON_SELECTOR = "\e\x00\x00\x00\x02foo\x00\x04\x00\x00\x00bar\x00\x10_id\x00\x11\x00\x00\x00\x00" 
    BSON_UPDATE = "\x1E\x00\x00\x00\x03$set\x00\x13\x00\x00\x00\x02foo\x00\x05\x00\x00\x00narf\x00\x00\x00"
    
    before(:each) do
      @collection = stub full_name: 'crunch_test.TestCollection'
      @selector = Fieldset.new 'foo' => 'bar'
      @update = Fieldset.new '$set' => {'foo' => 'narf'}
      @this = UpdateMessage.new(@collection, selector: @selector, id: 17, update: @update, multi: true)
    end
    
    it_should_behave_like "a Message"
    
    it "requires a collection" do
      ->{InsertMessage.new}.should raise_error(ArgumentError)
    end
    
    it "knows its collection name" do
      @this.collection_name.should == "crunch_test.TestCollection"
    end
    
    it "can take an update hash on creation" do
      @this.update.should == @update
    end
    
    it "can take an update hash after the fact" do
      @this.update = {'$inc' => {'somenum' => 5}}
      @this.update.should == {'$inc' => {'somenum' => 5}}
    end
    
    it "can modify the update hash after the fact" do
      @this.update.merge! '$inc' => {'somenum' => 5}
      @this.update.should == {'$set' => {'foo' => 'narf'}, '$inc' => {'somenum' => 5}}
    end
    
    it "can take an id on creation" do
      @this.id.should == 17
    end
    
    it "can take an id after the fact" do
      @this.id = 0
      @this.id.should == 0
    end
    
    it "can take a selector on creation" do
      that = UpdateMessage.new(@collection, selector: {'foo' => 'bar'})
      that.selector.should == {'foo' => 'bar'}
    end
    
    it "can take a selector after the fact" do
      @this.selector = {'somenum' => 5}
      @this.selector.should == {'somenum' => 5}
    end
    
    it "can modify the selector" do
      @this.selector['boo'] = 'bar'
      @this.selector['boo'].should == 'bar'
    end
    
    it "stacks the id and the selector" do
      @this.selector['too'] = 'tar'
      @this.selector.should == {'foo' => 'bar', '_id' => 17, 'too' => 'tar'}
    end
    
    it "overrides the id if the selector is changed" do
      @this.selector['_id'] = :glump
      @this.id.should == :glump
    end
    
    it "can take a multi flag on creation" do
      that = UpdateMessage.new(@collection, multi: true)
      that.multi.should be_true
    end
    
    it "can take a multi flag after the fact" do
      @this.multi = true
      @this.should be_multi
    end
    
    it "can take an upsert flag on creation" do
      that = UpdateMessage.new(@collection, upsert: true)
      that.upsert.should be_true
    end
    
    it "can take an upsert flag after the fact" do
      @this.upsert = true
      @this.should be_upsert
    end
    
    describe "body" do
      it "starts with 0 for no options" do
        @this.body[0..3].unpack('V').first.should == 0
      end
      
      it "contains the collection name" do
        @this.body[4..30].should == "crunch_test.TestCollection\x00"
      end
      
      it "contains the bit flags" do
        @this.body[31..34].should == "\x02\x00\x00\x00"
      end
      
      it "contains the selector" do
        @this.body[35..61].should == BSON_SELECTOR
      end
      
      it "contains the update" do
        @this.body[62..91].should == BSON_UPDATE
      end
    end
  end    
end