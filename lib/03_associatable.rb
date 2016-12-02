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
    @name.to_s.singularize.camelcase.constantize
  end

  def table_name
    @name.to_s.singularize.camelcase.constantize.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: (name.to_s.underscore + "_id").to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase
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
      foreign_key: (self_class_name.to_s.singularize.underscore + "_id").to_sym,
      primary_key: :id,
      class_name: name.to_s.singularize.camelcase
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
    options = BelongsToOptions.new(name, options)
    @@assoc_options[:belongs_to] = options
    
    define_method(:"#{name}") do
      foreign_key = send("#{options.foreign_key}")
      target_model_class = options.model_class
      target_model_class.where(options.primary_key => foreign_key).first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method(:"#{name}") do
      foreign_key = send("#{options.primary_key}")
      target_model_class = options.model_class
      target_model_class.where(options.foreign_key => foreign_key)
    end
  end

  def assoc_options
    @@assoc_options = {}
    DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      JOIN

      WHERE
    SQL
  end

#  has_one_through is going to need to make a join query that uses
#  and combines the options (table_name, foreign_key, primary_key)
#  of the two constituent associations. This requires us to store
#  the options of a belongs_to association so that has_one_through
#  can later reference these to build a query.
#
# Modify your 03_associatiable.rb file and implement the
# ::assoc_options class method. It lazily-initializes a class
# instance variable with a blank hash. Modify your belongs_to
# method to save the BelongsToOptions in the assoc_options hash,
# setting the options as the value for the key name
#
#   SELECT
#   houses.*
# FROM
#   humans
# JOIN
#   houses ON humans.house_id = houses.id
# WHERE
#   humans.id = ?
end

class SQLObject
  extend Associatable
end
