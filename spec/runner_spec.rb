require 'spec_helper'

describe SeedFu::Runner do
  it "should seed data from Ruby and gzipped Ruby files in the given fixtures directory" do
    SeedFu.seed(File.dirname(__FILE__) + '/fixtures')

    expect(SeededModel.find(1).title).to eq("Foo")
    expect(SeededModel.find(2).title).to eq("Bar")
    expect(SeededModel.find(3).title).to eq("Baz")
  end

  it "should seed only the data which matches the filter, if one is given" do
    SeedFu.seed(File.dirname(__FILE__) + '/fixtures', /_2/)

    expect(SeededModel.count).to eq(1)
    expect(SeededModel.find(2).title).to eq("Bar")
  end

  it "should use the SpecFu.fixtures_path variable to determine where fixtures are" do
    SeedFu.fixture_paths = [File.dirname(__FILE__) + '/fixtures']
    SeedFu.seed
    expect(SeededModel.count).to eq(3)
  end
end
