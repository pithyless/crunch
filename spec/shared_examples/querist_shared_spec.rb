shared_examples_for "a Querist" do
  
  it "knows its collection name" do
    @this.collection_name.should == 'crunch_test.TestCollection'
  end

  it "can have query conditions" do
    @this.should respond_to(:query)
  end
  
  it "has fields queried on" do
    @this.should respond_to(:fields)
  end
  
  it "has a starting number" do
    @this.should respond_to(:skip)
  end
  
  it "has a limit" do
    @this.should respond_to(:limit)
  end
  
  describe "querying" do
    it "goes to the database" do
      @database.expects(:<<).with(instance_of(Crunch::QueryMessage))
      @this.refresh
    end
  end
end