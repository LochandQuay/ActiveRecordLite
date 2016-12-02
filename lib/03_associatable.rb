require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
  end

  def table_name
    # ...
  end
end
#
# options = BelongsToOptions.new(:owner)
# options.foreign_key # => :owner_id
# options.primary_key # => :id
# # this is not the class name...
# options.class_name # => "Owner"
#
# # override defaults
# options = BelongsToOptions.new(:owner, :class_name => "Human")
# options.class_name # => "Human"
# Use the inflector's String#camelcase,String#singularize,
# String#underscore to aid you in your quest.

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: (name.underscore + "_id").to_sym,
      primary_key: :id,
      class_name: name.camelcase
    }
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
