require 'geo_ruby/geojson'
require 'phone'
require 'sequel'

ENV['DATABASE_URL'] ||= "postgres://localhost/citygram_#{Citygram::App.environment}"
DB = Sequel.connect(ENV['DATABASE_URL'])

Sequel.default_timezone = :utc

# no mass-assignable columns by default
Sequel::Model.set_allowed_columns(*[])

# use first!, create!, save! to raise
Sequel::Model.raise_on_save_failure = false

# sequel's standard pagination
Sequel::Model.db.extension :pagination

# common model plugins
Sequel::Model.plugin :attributes_helpers
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :save_helpers
Sequel::Model.plugin :serialization
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :validation_helpers

# round trip a geojson geometry through a postgis geometry column
Sequel::Plugins::Serialization.register_format(:geojson,
  # transform a geojson geometry into extended well-known text format
  ->(v){ GeoRuby::GeojsonParser.new.parse(v).as_ewkt },
  # transform extended well-known binary into a geojson geometry
  ->(v){ GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(v).to_json }
)

# set default to US for now
Phoner::Phone.default_country_code = '1'

# normalize phone numbers to E.164
Sequel::Plugins::Serialization.register_format(:phone,
  ->(v){ Phoner::Phone.parse(v).to_s },
  ->(v){ v } # identity
)

module Citygram
  module Models
  end
end

require 'app/models/event'
require 'app/models/publisher'
require 'app/models/subscription'

# access model class constants without qualifying namespace
include Citygram::Models
