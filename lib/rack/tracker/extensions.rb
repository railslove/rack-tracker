require 'ostruct'

# Backport of 2.0.0 stdlib ostruct#to_h
class OpenStruct
  def to_h
    @table.dup
  end unless method_defined? :to_h
end

class Hash
  def stringify_values
    inject({}) do |options, (key, value)|
      options[key] = value.to_s
      options
    end
  end

  def compact
    select { |_, value| !value.nil? }
  end

  def deep_merge!(other_hash, &block)
    other_hash.each_pair do |k,v|
      tv = self[k]
      if tv.is_a?(Hash) && v.is_a?(Hash)
        self[k] = tv.deep_merge(v, &block)
      else
        self[k] = block && tv ? block.call(k, tv, v) : v
      end
    end
    self
  end

  # NOTE Back ported from Rails 4 to 3
  # Destructively convert all keys by using the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes.
  def deep_transform_keys!(&block)
    _deep_transform_keys_in_object!(self, &block)
  end unless method_defined? :deep_transform_keys!

  def _deep_transform_keys_in_object!(object, &block)
    case object
    when Hash
      object.keys.each do |key|
        value = object.delete(key)
        object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
      end
      object
    when Array
      object.map! {|e| _deep_transform_keys_in_object!(e, &block)}
    else
      object
    end
  end unless method_defined? :_deep_transform_keys_in_object!

  # NOTE Back ported from Rails 4 to 3
  # Destructively convert all keys to strings.
  # This includes the keys from the root hash and from all
  # nested hashes.
  def deep_stringify_keys!
    deep_transform_keys!{ |key| key.to_s }
  end unless method_defined? :deep_stringify_keys!
end
