require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)



# Lookup through_name in assoc_options; call this 
# through_options.
# Using through_options.model_class, lookup source_name in
# assoc_options; call this source_options.
# Why can we not lookup source_name in self.class.assoc_options?
# Once you have these two sets of options, it's time to
#  write the query. Look at the above sample query to inspire
# your building of the query from the constituent association options.
#
# Unlike when you used where in the belongs_to/has_many, you'll
# have to ::parse_all yourself.
  end
end
