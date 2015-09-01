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
    keys.each do |key|
      value = delete(key)
      self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
    end
    self
  end unless method_defined? :deep_transform_keys!

  # NOTE Back ported from Rails 4 to 3
  # Destructively convert all keys to strings.
  # This includes the keys from the root hash and from all
  # nested hashes.
  def deep_stringify_keys!
    deep_transform_keys!{ |key| key.to_s }
  end unless method_defined? :deep_stringify_keys!
end
