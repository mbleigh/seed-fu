require 'spec_helper'

describe SeedFu::Seeder do

  it "should work with negative seeds" do
    SeededModel.seed(:id) do |s|
      s.id = 10
      s.login = "bob2"
      s.first_name = "Bob2"
      s.last_name = "Bobson2"
      s.title = "Peaon2"
    end

    SeededModel.seed(:id) do |s|
      s.id = -2
      s.login = "bob"
      s.first_name = "Bob"
      s.last_name = "Bobson"
      s.title = "Peon"
    end

    bob = SeededModel.find_by_id(-2)
    expect(bob.first_name).to eq("Bob")
    expect(bob.last_name).to eq("Bobson")

    if ENV['DB'] == 'postgresql'
      next_id = SeededModel.connection.execute("select nextval('seeded_models_id_seq')")
      expect(next_id[0]['nextval'].to_i).to eq(11)
    end
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
    expect(bob.first_name).to eq("Bob")
    expect(bob.last_name).to eq("Bobson")
  end

  it "should be able to handle multiple constraints" do
    SeededModel.seed(:title, :login) do |s|
      s.login = "bob"
      s.title = "Peon"
      s.first_name = "Bob"
    end

    expect(SeededModel.count).to eq(1)

    SeededModel.seed(:title, :login) do |s|
      s.login = "frank"
      s.title = "Peon"
      s.first_name = "Frank"
    end

    expect(SeededModel.count).to eq(2)

    expect(SeededModel.find_by_login("bob").first_name).to eq("Bob")
    SeededModel.seed(:title, :login) do |s|
      s.login = "bob"
      s.title = "Peon"
      s.first_name = "Steve"
    end
    expect(SeededModel.find_by_login("bob").first_name).to eq("Steve")
  end

  it "should be able to create models from an array of seed attributes" do
    SeededModel.seed(:title, :login, [
      {:login => "bob", :title => "Peon", :first_name => "Steve"},
      {:login => "frank", :title => "Peasant", :first_name => "Francis"},
      {:login => "harry", :title => "Noble", :first_name => "Harry"}
    ])

    expect(SeededModel.find_by_login("bob").first_name).to eq("Steve")
    expect(SeededModel.find_by_login("frank").first_name).to eq("Francis")
    expect(SeededModel.find_by_login("harry").first_name).to eq("Harry")
  end

  it "should be able to create models from a list of seed attribute hashes at the end of the args" do
    SeededModel.seed(:title, :login,
      {:login => "bob", :title => "Peon", :first_name => "Steve"},
      {:login => "frank", :title => "Peasant", :first_name => "Francis"},
      {:login => "harry", :title => "Noble", :first_name => "Harry"}
    )

    expect(SeededModel.find_by_login("bob").first_name).to eq("Steve")
    expect(SeededModel.find_by_login("frank").first_name).to eq("Francis")
    expect(SeededModel.find_by_login("harry").first_name).to eq("Harry")
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
    expect(bob.first_name).to eq("Robert")
    expect(bob.last_name).to eq("Bobson")
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
    expect(bob.first_name).to eq("Bob")
    expect(bob.last_name).to eq("Bobson")
  end

  it "should default to an id constraint" do
    SeededModel.seed(:title => "Bla", :id => 1)
    SeededModel.seed(:title => "Foo", :id => 1)

    expect(SeededModel.find(1).title).to eq("Foo")
  end

  it "should require that all constraints are defined" do
    expect { SeededModel.seed(:doesnt_exist, :title => "Bla") }.to raise_error(ArgumentError)
  end

  it "should not perform validation" do
    expect { SeededModel.seed(:id => 1) }.not_to raise_error()
  end

  if ENV["DB"] == "postgresql"
    it "should update the primary key sequence after a records have been seeded" do
      id = SeededModel.connection.select_value("SELECT currval('seeded_models_id_seq')").to_i + 1
      SeededModel.seed(:title => "Foo", :id => id)

      expect { SeededModel.create!(:title => "Bla") }.not_to raise_error
    end

    it "should not raise error when there is no primary key specified" do
      expect { SeededModelNoPrimaryKey.seed(:id => "Id") }.not_to raise_error
    end

    it "should not raise error when there is primary key without sequence" do
      expect { SeededModelNoSequence.seed(:id => "Id") }.not_to raise_error
    end
  end

  it "should raise an ActiveRecord::RecordNotSaved exception if any records fail to save" do
    expect { SeededModel.seed(:fail_to_save => true, :title => "Foo") }.to raise_error(ActiveRecord::RecordNotSaved)
  end
end
