require File.dirname(__FILE__) + '/../spec_helper'

module Crunch

  # Our highest-level object is NOT the connection; it's the database.  
  # Each database has one write connection and may have multiple read
  # connections at any given time, which will be managed automatically
  # by Crunch, and can accept one authentication (if necessary).  This 
  # dramatically simplifies the API.
  describe Database do
  
    it "must be instantiated with connect()" do
      lambda{d = Database.new}.should raise_error(NoMethodError)
    end
    
    it "starts EventMachine if it isn't already running" do
      if EventMachine.reactor_running?
        EventMachine.stop_event_loop
        while EventMachine.reactor_running?
          sleep(0.1)
        end
      end
      d = Database.connect 'foo'
      tick
      EventMachine.should be_reactor_running
    end
      
    it "is a singleton" do
      db1 = Database.connect 'crunch_test'
      db2 = Database.connect 'crunch_test'
      db1.should equal(db2)
    end
    
    it "can take a symbol name" do
      db1 = Database.connect 'crunch_test'
      db2 = Database.connect :crunch_test
      db1.should equal(db2)
    end      
  
    it "knows the name is a string even if a symbol is given" do
      db = Database.connect :crunch_test
      db.name.should == 'crunch_test'
    end
    
    it "inherits global options from the Crunch module" do
      db = Database.connect 'crunch_test'
      db.timeout.should > 0
    end
    
    it "can override global options at creation" do
      db = Database.connect 'crunch_test', timeout: 20
      db.timeout.should == 20
    end
    
    describe "collections" do
      
      before(:each) do
        @database = Database.connect :crunch_test
      end
      
      it "can be retrieved", pending: true do
        @database.collection('TestCollection').should be_a(Collection)
      end
      
      it "can be listed", pending: true do
        @database.collections.should include('TestCollection')
      end
      
    end
    
    describe "connecting" do
      
      it "requires a name" do
        ->{d = Database.connect}.should raise_error(ArgumentError)
      end

      it "defaults to localhost:27017" do
        EventMachine.expects(:connect).with('localhost',27017,instance_of(Module),instance_of(Database))
        tick do
          d = Database.connect 'foo'
        end
      end
      
      it "accepts a given host" do
        EventMachine.expects(:connect).with('example.org',27017,instance_of(Module),instance_of(Database))
        tick do
          d = Database.connect 'foo', host: 'example.org'
        end
      end
      

      it "accepts a given port" do
        EventMachine.expects(:connect).with('localhost',71072,instance_of(Module),instance_of(Database))
        tick do 
          d = Database.connect 'foo', port: 71072
        end
      end
              

      it "accepts a username" do
        pending
      end

      it "accepts a password" do
        pending
      end

      it "throws an error if it can't make a read connection" do
        pending
      end

      it "tries to authenticate on 'admin' if the option is given" do
        pending
      end

      it "throws an error if it can't authenticate" do
        pending
      end

      it "creates the database if not told otherwise" do
        pending
      end

      it "does not create the database if told not to" do
        pending
      end

      it "returns a Database object when all is well" do
        pending
      end

      it "returns the same object if called later with the same parameters" do
        pending
      end
      
    end
    
    describe "connections" do
      
      it "will have one at start" do
        this = tick{Database.connect 'crunch_test'}
        this.connection_count.should == 1
      end
      
      it "can set more at initialization" do
        this = tick{Database.connect 'crunch_test', min_connections: 3}
        this.connection_count.should == 3
      end
      
      it "can set zero at initialization" do
        this = tick{Database.connect 'crunch_test', min_connections: 0}
        this.connection_count.should == 0
      end
      
      it "are checked every second by default" do
        this = tick{Database.connect 'crunch_test'}
        this.heartbeat.should == 1
      end
      
      it "can set the heartbeat at initialization" do
        this = tick{Database.connect 'crunch_test', heartbeat: 3}
        this.heartbeat.should == 3
      end
        
        
      
      it "defaults to maximum 10 connections" do
        this = tick{Database.connect 'crunch_test'}
        this.max_connections.should == 10
      end
      
      it "can set maximum connections at initialization" do
        this = tick{Database.connect 'crunch_test', max_connections: 5}
        this.max_connections.should == 5
      end
        
      
      
    end
    
    describe "sending messages" do
      before(:each) do
        @sender = stub "Document"
        @message = stub "QueryMessage", sender: @sender, request_id: 1337, deliver: true
        @this = tick{Database.connect 'crunch_test'} 
      end

      it "requires a Message" do
        ->{@this << nil}.should raise_error(DatabaseError, /must be a Message/)
      end
      
      # it "passes it to the connection" do
      #    Message.any_instance.expects(:deliver).returns("foobar")
      #    tick until @this.connection.is_a?(EventMachine::Connection)
      #    tick do
      #      @this.connection.expects(:send_data).with("foobar")
      #      @this << Message.new
      #    end
      #  end
       
      it "returns true" do
        response = @this << @message
        response.should == true
      end
      
      it "pings the sender back on replies" do
        reply = [0,0,1337,'blah'].pack('VVVa*')
        @sender.expects(:succeed).with(reply)
        @this << @message
        @this.receive_reply(reply)
      end
      
      it "queues the messages" do
        # Keep connections from taking things off the queue
        @this.requests.expects(:push).twice
        2.times {tick{@this << @message}}
      end
      
      
    end

    
    describe "operation" do
      before(:each) do
        @this = Database.connect 'crunch_test'
      end
      
      it "has a command collection" do
        @this.command.should be_a(CommandCollection)
      end
            
      it "can return a collection" do
        @this.collection('TestCollection').should be_a(Collection)
      end
      
    end

  end
  
end