Gem::Specification.new do |s|
  s.name = 'seed-fu'
  s.version = '1.2.0'
  s.date = '2009-08-14'
  
  s.summary = "Allows easier database seeding of tables."
  s.description = "Seed Fu is an attempt to once and for all solve the problem of inserting and maintaining seed data in a database. It uses a variety of techniques gathered from various places around the web and combines them to create what is hopefully the most robust seed data system around."
  
  s.authors = ["Michael Bleigh", "Matthew Beale"]
  s.email = "mixonic@synitech.com"
  s.homepage = 'http://github.com/mixonic/seed-fu'
  
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

  s.add_dependency 'rails', ['>= 2.1']
  
  s.files = ["README",
             "Rakefile",
             "init.rb",
             "lib/seed-fu.rb",
             "lib/seed-fu/writer.rb",
             "lib/seed-fu/writer/abstract.rb",
             "lib/seed-fu/writer/seed.rb",
             "lib/seed-fu/writer/seed_many.rb",
             "rails/init.rb",
             "seed-fu.gemspec",
             "spec/schema.rb",
             "spec/seed_fu_spec.rb",
             "spec/spec_helper.rb",
             "tasks/seed_fu_tasks.rake"]

end
