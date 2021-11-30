require_relative 'accessors'
require_relative 'validation'

class Test
  include Accessors, Validation
  attr_accessor :name, :number, :station

  validate :name, :presence
  validate :number, :format, /A-Z{0,3}/
  validate :name, :format, /A-Z/
  validate :name, :type, String
end