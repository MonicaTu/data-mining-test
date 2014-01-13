#!/usr/bin/env ruby

require_relative 'system'

@maxHeap='-Xmx4096m'

def weka_pca(input)
  output = "pca-#{File.basename(input, ".*")}.arff"
  filter = 'weka.filters.unsupervised.attribute.PrincipalComponents -R 0.95 -A 5 -M -1'
  exesh("java #{@maxHeap} #{filter} -i #{input} -o #{output}") 
  return output
end

def weka_attribute_selection(input, class_index)
  output = "attribute_selection-#{File.basename(input, ".*")}.arff"
  filter = 'weka.filters.supervised.attribute.AttributeSelection' 
  search_options = '-S "weka.attributeSelection.BestFirst -D 1 -N 5"' 
  evaluator_options = '-E "weka.attributeSelection.CfsSubsetEval "' 
  io_options = "-i #{input} -o #{output}"
  options = "#{evaluator_options} #{search_options} -c #{class_index} #{io_options}"
  exesh("java #{@maxHeap} #{filter} #{options}") 
  return output
end

def weka_normalization(input)
  output = "normalized-#{File.basename(input, ".*")}.arff"
  filter = 'weka.filters.unsupervised.attribute.Normalize'
  options = '-S 1.0 -T 0.0'
  exesh("java #{@maxHeap} #{filter} #{options} -i #{input} -o #{output}") 
  return output
end

def weka_classify(input, class_index)
  arff = "classify-#{File.basename(input, ".*")}.arff"
  options = "-c #{class_index} -no-cv -i"
  exesh("java #{@maxHeap} weka.classifiers.bayes.NaiveBayes #{options} -t #{input} > #{arff}")
  return arff
end

def weka_csv2arff(csv)
  arff = "#{File.basename(csv, ".*")}.arff"
  exesh("java #{@maxHeap} weka.core.converters.CSVLoader #{csv} > #{arff}") 
  return arff
end

def weka_arff2csv(arff)
  csv = "#{File.basename(arff, ".*")}.csv"
  path = File.dirname(arff)
  exesh("java #{@maxHeap} weka.core.converters.CSVSaver -i #{arff} -o #{path}/#{csv}")
  return csv
end

# main
if __FILE__ == $0
  input = ARGV[0] 
#  weka_attribute_selection(input, 'first')
#  weka_classify(input, 'last')
end

