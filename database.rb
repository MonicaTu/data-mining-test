#!/usr/bin/env ruby

require 'sqlite3'
require_relative 'system'

def db_create_database(dbFile)
  db = SQLite3::Database.open dbFile
  db.close if db
end

def db_create_table_schema(dbFile, table, schema)
  cmd = "CREATE TABLE IF NOT EXISTS #{table} (#{schema});"
  exesql(dbFile, cmd)
end

def db_create_view_schema(dbFile, view, schema)
  cmd = "CREATE VIEW IF NOT EXISTS #{view} (#{schema});"
  exesql(dbFile, cmd)
end

def db_import_csv(dbFile, table, csv)
  if db_is_imported(dbFile, table)
    return
  end

  cmd = "!
.separator ,
.import '#{csv}' #{table}
SELECT COUNT(*) FROM #{table};
!"
  # shell script
  exesh("sqlite3 #{dbFile} << #{cmd}")
end

def db_export_table(dbFile, table)
  output = "#{table}.csv" 
  cmd = "!
.mode csv
.headers on
.output #{output}
SELECT * FROM #{table};
!"
  exesh("sqlite3 #{dbFile} << #{cmd}") 
  return output
end

def db_combine_tables(dbFile, left, right)

  newTable = "#{left}_#{right}"
  cmd = "CREATE TABLE IF NOT EXISTS #{newTable} as select #{left}.*, #{right}.* from #{left}, #{right} where #{left}.rowid=#{right}.rowid;"
  exesql(dbFile, cmd)

  # DEBUG
  cmd = "SELECT COUNT(*) FROM #{newTable};"
  rs = exesql(dbFile, cmd)
  puts "#{newTable}: #{rs}"

  return newTable 
end

def db_drop_table(dbFile, table)
  puts "---------!!!!--------"
  cmd = "DROP TABLE IF EXISTS #{table};"
  exesql(dbFile, cmd)
end

def db_drop_view(dbFile, view)
  puts "---------!!!!--------"
  cmd = "DROP VIEW IF EXISTS #{view};"
  exesql(dbFile, cmd)
end

def db_is_table_created(dbFile, table)
  cmd = "SELECT name FROM sqlite_master WHERE type='table' AND name='#{table}';"
  rs = exesql(dbFile, cmd)
  puts rs
  return (rs == nil) ? false : true
end

def db_is_imported(dbFile, table)
  # check whether data was already imported or not. 
  cmd = "SELECT COUNT(*) FROM #{table};"
  rs = exesql(dbFile, cmd)
  puts "#{table}: #{rs}"
  if rs != nil && rs[0][0] > 0
    return true
  end
  return false
end

def exesql(dbFile, cmd)
  puts cmd

  db = SQLite3::Database.open dbFile
  rs = db.execute cmd 
  rescue SQLite3::Exception => e 
    puts "Exception occured"
    puts e
  ensure
    db.close if db

  puts "rs: #{rs}"
  return rs
end

if __FILE__ == $0
  dbFile = ARGV[0]
  table = ARGV[1]
  db_create_database(dbFile)
  db_create_table_schema(dbFile, table, 'uuid text')
  db_is_imported(dbFile, table)
end
