require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection::execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL
    .first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      define_method("#{column}=") do |value|
        self.attributes[:"#{column}"] = value
      end
      define_method("#{column}") do
        instance_variable_get(:@attributes)[:"#{column}"]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.table_name = self.to_s.tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end


# Our job is to write a class, SQLObject,
# that will interact with the database.
# By the end of this phase, our ActiveRecord Lite
# will behave just like the real ActiveRecord::Base,
# with methods including:
#
# ::all: return an array of all the records in the DB
# ::find: look up a single record by primary key
#insert: insert a new row into the table to
# represent the SQLObject.
#update: update the row with the id of this SQLObject
#save: convenience method that either calls
# insert/update depending on whether or not the
# SQLObject already exists in the table.
