require 'rake'

task default: [:bw]

task :game do
  if (ENV['palette'] == nil)
    ENV['palette'] = 'bw'
  end
  Rake::Task['cards'].invoke
  Rake::Task['assemble'].invoke
end

task :cards do
  Dir.chdir('cards') do
    sh 'ruby deck.rb'
  end
end

task :color do
  ENV['palette'] = 'color' 
  Rake::Task["game"].invoke
end

task :bw do
  ENV['palette'] = 'bw' 
  Rake::Task["game"].invoke
end

task :assemble do
  sh "inkscape board.svg --export-pdf=board.pdf"
  sh "pdfunite cards/_output/output.pdf board.pdf FratAttack.pdf"
end
  
