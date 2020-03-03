# frozen_string_literal: true

require 'ostruct'

# Backport of 2.0.0 stdlib ostruct#to_h
class OpenStruct
  unless method_defined? :to_h
    def to_h
      @table.dup
    end
  end
end

class Hash
  def stringify_values
    each_with_object({}) do |(key, value), options|
      options[key] = value.to_s
    end
  end

  def compact
    select { |_, value| !value.nil? }
  end

  def deep_merge!(other_hash, &block)
    other_hash.each_pair do |k, v|
      tv = self[k]
      self[k] = if tv.is_a?(Hash) && v.is_a?(Hash)
                  tv.deep_merge(v, &block)
                else
                  block && tv ? block.call(k, tv, v) : v
                end
    end
    self
  end

  # NOTE Back ported from Rails 4 to 3
  # Destructively convert all keys by using the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes.
  unless method_defined? :deep_transform_keys!
    def deep_transform_keys!(&block)
      _deep_transform_keys_in_object!(self, &block)
    end
  end

  unless method_defined? :_deep_transform_keys_in_object!
    def _deep_transform_keys_in_object!(object, &block)
      case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
        end
        object
      when Array
        object.map! { |e| _deep_transform_keys_in_object!(e, &block) }
      else
        object
      end
    end
  end

  # NOTE Back ported from Rails 4 to 3
  # Destructively convert all keys to strings.
  # This includes the keys from the root hash and from all
  # nested hashes.
  unless method_defined? :deep_stringify_keys!
    def deep_stringify_keys!
      deep_transform_keys!(&:to_s)
    end
  end
end
