require 'spec_helper'

describe SeedFu::Writer do
  before do
    @file_name = File.dirname(__FILE__) + '/seeded_models.rb'
  end

  after do
    FileUtils.rm(@file_name)
  end

  it "should successfully write some seeds out to a file and then import them back in" do
    SeedFu::Writer.write(@file_name, :class_name => 'SeededModel') do |writer|
      writer << { :id => 1, :title => "Mr" }
      writer << { :id => 2, :title => "Dr" }
    end
    load @file_name

    SeededModel.find(1).title.should == "Mr"
    SeededModel.find(2).title.should == "Dr"
  end

  it "should support chunking" do
    SeedFu::Writer.write(@file_name, :class_name => 'SeededModel', :chunk_size => 2) do |writer|
      writer << { :id => 1, :title => "Mr" }
      writer << { :id => 2, :title => "Dr" }
      writer << { :id => 3, :title => "Dr" }
    end
    load @file_name

    SeededModel.count.should == 3
    File.read(@file_name).should include("# BREAK EVAL\n")
  end

  it "should support specifying the output to use 'seed_once' rather than 'seed'" do
    SeededModel.seed(:id => 1, :title => "Dr")

    SeedFu::Writer.write(@file_name, :class_name => 'SeededModel', :seed_type => :seed_once) do |writer|
      writer << { :id => 1, :title => "Mr" }
    end
    load @file_name

    SeededModel.find(1).title.should == "Dr"
  end
end
