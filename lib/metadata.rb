# metadata.rb: contains definition of the Metadata module, which provides
# a set of methods for analyzing metadata across multiple files, such as:
# *Metadata.completeness(arr, fields): for each metadata field provided in the "fields" argument, returns a completeness score.
# **E.g. {date_time: .95} means 95% of the files in arr have data in the "date_time" field
# *Metadata.fields(arr): returns the full list of fields available, aggregated across all files in arr

require 'scrapers/music.rb'
require 'scrapers/image.rb'

module Metadata
  def self.completeness(arr = [], fields = [])
    fields_count = {}
    fields.each do |i|
      fields_count[i] = 0
    end
    arr.each do |file|
    end
  end
end
