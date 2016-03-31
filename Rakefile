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
  sh "inkscape score_tracker.svg --export-pdf=score_tracker.pdf"
  sh "pdfjam score_tracker.pdf score_tracker.pdf score_tracker.pdf score_tracker.pdf --nup 2x2 --a4paper --landscape --quiet --outfile score_tracker_page.pdf"
  sh "pandoc -V geometry:margin=1in -V geometry:a4paper RULES.md -o rules.pdf"
  sh "pdfunite cards/_output/output.pdf board.pdf score_tracker_page.pdf rules.pdf FratAttack.pdf"
end
  
