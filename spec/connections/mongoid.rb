Mongoid.logger.level = Logger::DEBUG
Moped.logger.level = Logger::DEBUG
Mongoid.logger = Logger.new(File.expand_path("../../../debug.log", __FILE__))
Moped.logger = Logger.new(File.expand_path("../../../debug.log", __FILE__))

Mongoid.load!(File.expand_path("../mongoid.yml", __FILE__), "test")
