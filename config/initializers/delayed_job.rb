config = YAML::load(File.read(Rails.root.join('config/mongodb.yml')))
MongoMapper.setup(config, Rails.env)

Delayed::Worker.backend = :mongo_mapper