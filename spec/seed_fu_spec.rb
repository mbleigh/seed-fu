require 'spec_helper'

describe SeedFu::Seeder do
  before do
    SeededModel.delete_all
  end

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

  it "should alias seed as seed_many (deprecated)" do
    SeededModel.seed_many(:id => 2, :title => "Foo")
    SeededModel.find(2).title.should == "Foo"
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

  it "should raise an error if validation fails" do
    lambda { SeededModel.seed(:id => 1) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should seed data from Ruby and gzipped Ruby files in the given fixtures directory" do
    SeedFu.seed(File.dirname(__FILE__) + '/fixtures')

    SeededModel.find(1).title.should == "Foo"
    SeededModel.find(2).title.should == "Bar"
    SeededModel.find(3).title.should == "Baz"
  end

  it "should seed only the data which matches the filter, if one is given" do
    SeedFu.seed(File.dirname(__FILE__) + '/fixtures', /_2/)

    SeededModel.count.should == 1
    SeededModel.find(2).title.should == "Bar"
  end

  it "should use the SpecFu.fixtures_path variable to determine where fixtures are" do
    SeedFu.fixture_paths = [File.dirname(__FILE__) + '/fixtures']
    SeedFu.seed
    SeededModel.count.should == 3
  end
end
