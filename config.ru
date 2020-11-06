require './browser'
require 'yaml'

Configuration.archive_path = YAML.load_file("config/config.yml")["archive_path"]

run Browser
