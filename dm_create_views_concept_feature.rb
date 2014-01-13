#!/usr/bin/env ruby

require 'sqlite3'
require_relative 'database'

def create_views_conceptid_yes_and_no(dbFile, concept_id)
  concept_v = ["c#{concept_id}_yes", "c#{concept_id}_no"]

  query = "SELECT UUID.id FROM Concepts, UUID WHERE Concepts.id=#{concept_id} and Concepts.uuid_id=UUID.uuid;"
  cmd = "CREATE VIEW IF NOT EXISTS #{concept_v[0]} AS #{query};"
  exesql(dbFile, cmd)

  # DEBUG
  cmd = "SELECT COUNT(*) FROM #{concept_v[0]};" 
  rs = exesql(dbFile, cmd)
  rs.each {|row| puts "#{concept_v[0]}: #{row}"}

  query = "SELECT id FROM UUID EXCEPT SELECT id FROM #{concept_v[0]};"
  cmd = "CREATE VIEW IF NOT EXISTS #{concept_v[1]} AS #{query};"
  exesql(dbFile, cmd)

  # DEBUG
  cmd = "SELECT COUNT(*) FROM #{concept_v[1]};" 
  rs = exesql(dbFile, cmd)
  rs.each {|row| puts "#{concept_v[1]}: #{row}"}

  return concept_v
end

def dm_create_views_concept_feature_yes_and_no(dbFile, concept_id, feature)
  views = []

  # 'yes/no' views for each concept
  concept_v = create_views_conceptid_yes_and_no(@db, concept_id)
  concept_v.each {|view| views << view}

  concept_v.length.times do |i|
    result_v = "#{concept_v[i]}_#{feature}"
    views << result_v

    query = "SELECT #{feature}.* FROM #{concept_v[i]}, #{feature} WHERE #{feature}.rowid=#{concept_v[i]}.id"
    cmd = "CREATE VIEW IF NOT EXISTS #{result_v} AS #{query}" 
    exesql(dbFile, cmd)

    # DEBUG
    cmd = "SELECT COUNT(*) FROM #{result_v};" 
    rs = exesql(dbFile, cmd)
    rs.each {|row| puts "#{result_v}: #{row}"}
  end

  return views
end

if __FILE__ == $0
  dbFile = ARGV[0] 
  concept_num = 94
  features = ['AutoColorCorrelogram', 'CEDD', 'ColorLayout', 'EdgeHistogram', 'FCTH', 'Gabor', 'JCD', 'JpegCH', 'ScalableColor', 'Tamura']
  
  concept_num.times do |concept_id|
    features.each do |feature|
      # 'yes/no' views for each concept_feature
      dm_create_views_concept_feature_yes_and_no(dbFile, concept_id, feature)
    end
  end
end
