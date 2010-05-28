$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'crunch'
require 'spec'
require 'spec/autorun'
require 'mocha'

# Perform the requested action, but then don't come back until at least one EventMachine tick has passed.
def tick
  yield
  ticked = false
  EventMachine.next_tick do
    ticked = true
  end
  until ticked do
    sleep 0.0001
  end
end
    

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
