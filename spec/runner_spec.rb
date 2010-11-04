require 'spec_helper'

describe SeedFu::Runner do
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
