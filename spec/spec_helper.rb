$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'crunch'
require 'spec'
require 'spec/autorun'
require 'mocha'
require 'mongo'  # For verification only!

# Perform the requested action, but then don't come back until at least one EventMachine tick has passed.
def tick
  unless EventMachine.reactor_running?
    Thread.new {EventMachine.run {nil}}
    until EventMachine.reactor_running? do
      sleep 0.0001
    end
  end
  yield if block_given?
  ticked = false
  EventMachine.next_tick do
    ticked = true
  end
  until ticked do
    sleep 0.0001
  end
end
    
def verifier
  @verifier_db.collection('TestCollection')
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
  
  config.before(:all) do
    @verifier_db = Mongo::Connection.new.db('crunch_test') # For verification while we bootstrap
    @verifier_db.create_collection 'TestCollection'
  end
    
    
  config.after(:each) do
    # Clean up our database
    @verifier_db.collections.each do |collection|
      case collection.name
      when 'TestCollection' then collection.remove  # Keep the collection, remove all data
      when /^system\./ then nil   # Leave system collections alone
      else 
        @verifier_db.drop_collection collection
      end
    end
  end

end
