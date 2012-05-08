require 'spec_helper'

describe SeedFu::Seeder do
  it "should create a model if one doesn't exist" do
    SeededModel.seed(:id) do |s|
      s.id = 5
      s.login = "bob"
      s.first_name = "Bob"
      s.last_name = "Bobson"
      s.title = "Peon"
    end

    bob = SeededModel.find_by_id(5)
    bob.first_name.should == "Bob"
    bob.last_name.should == "Bobson"
  end

  it "should be able to handle multiple constraints" do
    SeededModel.seed(:title, :login) do |s|
      s.login = "bob"
      s.title = "Peon"
      s.first_name = "Bob"
    end

    SeededModel.count.should == 1

    SeededModel.seed(:title, :login) do |s|
      s.login = "frank"
      s.title = "Peon"
      s.first_name = "Frank"
    end

    SeededModel.count.should == 2

    SeededModel.find_by_login("bob").first_name.should == "Bob"
    SeededModel.seed(:title, :login) do |s|
      s.login = "bob"
      s.title = "Peon"
      s.first_name = "Steve"
    end
    SeededModel.find_by_login("bob").first_name.should == "Steve"
  end

  it "should be able to create models from an array of seed attributes" do
    SeededModel.seed(:title, :login, [
      {:login => "bob", :title => "Peon", :first_name => "Steve"},
      {:login => "frank", :title => "Peasant", :first_name => "Francis"},
      {:login => "harry", :title => "Noble", :first_name => "Harry"}
    ])

    SeededModel.find_by_login("bob").first_name.should == "Steve"
    SeededModel.find_by_login("frank").first_name.should == "Francis"
    SeededModel.find_by_login("harry").first_name.should == "Harry"
  end

  it "should be able to create models from a list of seed attribute hashes at the end of the args" do
    SeededModel.seed(:title, :login,
      {:login => "bob", :title => "Peon", :first_name => "Steve"},
      {:login => "frank", :title => "Peasant", :first_name => "Francis"},
      {:login => "harry", :title => "Noble", :first_name => "Harry"}
    )

    SeededModel.find_by_login("bob").first_name.should == "Steve"
    SeededModel.find_by_login("frank").first_name.should == "Francis"
    SeededModel.find_by_login("harry").first_name.should == "Harry"
  end

  it "should update, not create, if constraints are met" do
    SeededModel.seed(:id) do |s|
      s.id = 1
      s.login = "bob"
      s.first_name = "Bob"
      s.last_name = "Bobson"
      s.title = "Peon"
    end

    SeededModel.seed(:id) do |s|
      s.id = 1
      s.login = "bob"
      s.first_name = "Robert"
      s.last_name = "Bobson"
      s.title = "Peon"
    end

    bob = SeededModel.find_by_id(1)
    bob.first_name.should == "Robert"
    bob.last_name.should == "Bobson"
  end

  it "should create but not update with seed_once" do
    SeededModel.seed_once(:id) do |s|
      s.id = 1
      s.login = "bob"
      s.first_name = "Bob"
      s.last_name = "Bobson"
      s.title = "Peon"
    end

    SeededModel.seed_once(:id) do |s|
      s.id = 1
      s.login = "bob"
      s.first_name = "Robert"
      s.last_name = "Bobson"
      s.title = "Peon"
    end

    bob = SeededModel.find_by_id(1)
    bob.first_name.should == "Bob"
    bob.last_name.should == "Bobson"
  end

  it "should default to an id constraint" do
    SeededModel.seed(:title => "Bla", :id => 1)
    SeededModel.seed(:title => "Foo", :id => 1)

    SeededModel.find(1).title.should == "Foo"
  end

  it "should require that all constraints are defined" do
    lambda { SeededModel.seed(:doesnt_exist, :title => "Bla") }.should raise_error(ArgumentError)
  end

  it "should not perform validation" do
    lambda { SeededModel.seed(:id => 1) }.should_not raise_error(ActiveRecord::RecordInvalid)
  end
  
  it "should validate attributes with seed!" do
    expect do
      SeededModel.seed!(:id) do |s|
        s.id = 1
        s.login = "bob"
      end
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
    
  it "should validate attributes with seed_once!" do
    expect do
      SeededModel.seed_once!(:id) do |s|
        s.id = 1
        s.login = "bob"
      end
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
  
  it "should pass validation with seed!" do
    expect do
      SeededModel.seed!(:id) do |s|
        s.id = 1
        s.login = "bob"
        s.title = "Exists"
      end
    end.should_not raise_error(ActiveRecord::RecordInvalid)
    
    bob = SeededModel.find_by_id(1)
    bob.title.should == 'Exists'
  end
  
  if ENV["DB"] == "postgresql"
    it "should update the primary key sequence after a records have been seeded" do
      id = SeededModel.connection.select_value("SELECT currval('seeded_models_id_seq')").to_i + 1
      SeededModel.seed(:title => "Foo", :id => id)

      lambda { SeededModel.create!(:title => "Bla") }.should_not raise_error
    end
  end

  it "should raise an ActiveRecord::RecordNotSaved exception if any records fail to save" do
    lambda { SeededModel.seed(:fail_to_save => true, :title => "Foo") }.should raise_error(ActiveRecord::RecordNotSaved)
  end
end
