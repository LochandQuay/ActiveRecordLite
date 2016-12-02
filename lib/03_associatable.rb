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
    @name.singularize.camelcase.constantize
  end

  def table_name
    @name.singularize.camelcase.constantize.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: (name.underscore + "_id").to_sym,
      primary_key: :id,
      class_name: name.camelcase
    }
    options = defaults.merge(options)
    @name = name
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: (self_class_name.singularize.underscore + "_id").to_sym,
      primary_key: :id,
      class_name: name.singularize.camelcase
    }
    options = defaults.merge(options)
    @name = name
    @self_class_name = self_class_name
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    belongs = BelongsToOptions.new(name, options)
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

# Begin writing a belongs_to method for Associatable.
# This method should take in the association name and
# an options hash. It should build a BelongsToOptions object;
# save this in a local variable named options.
#
# Within belongs_to, call define_method to create a new
# method to access the association. Within this method:
#
# Use send to get the value of the foreign key.
# Use model_class to get the target model class.
# Use where to select those models where the primary_key
# column is equal to the foreign key value.
# Call first (since there should be only one such item).
# Throughout this method definition, use the options object
# so that defaults are used appropriately.
#
# Do likewise for has_many.


class SQLObject
  # Mixin Associatable here...
end
