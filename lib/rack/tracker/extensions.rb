require 'ostruct'

# Backport of 2.0.0 stdlib ostruct#to_h
class OpenStruct
  def to_h
    @table.dup
  end unless method_defined? :to_h
end
