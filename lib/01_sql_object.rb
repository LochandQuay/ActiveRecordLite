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
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    objects = []
    results.each do |hash|
      objects << self.new(hash)
    end
    objects
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        "#{self.table_name}"
      WHERE
        "#{self.table_name}".id = ?
    SQL
    result.empty? ? nil : self.new(result.first)
  end

  def initialize(params = {})
    params.each do |name, value|
      attr_name = name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col_name|
      send("#{col_name}")
    end
  end

  def insert
    col_names = "(#{self.class.columns.drop(1).join(", ")})"
    question_marks = "(#{(['?'] * (self.class.columns.size - 1)).join(', ')})"
    result = DBConnection.execute(<<-SQL, *self.attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_statement = "#{self.class.columns.drop(1).join(" = ?, ")} = ?"
    DBConnection.execute(<<-SQL, *self.attribute_values.drop(1), id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_statement}
      WHERE
        id = ?
    SQL
  end

  def save
    attributes[:id].nil? ? insert : update
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
