require 'squib'
require 'game_icons'

colors = {
  'status' => '#63b0ef',
  'active' => '#f46400',
}


data = Squib.csv file: 'data/action.csv'

# Load images from game-icons.net
req_art = data['art'].zip(data['type'])
req_art.uniq.each do |(art, type)|
  path = "img/art/#{art}_#{type}.svg"
  unless File.exist? path
    File.open(path, "w+") do |f|
      f.write(GameIcons.get(art).recolor(fg: colors[type], bg_opacity: 0.0).string)
    end
  end
end

Squib::Deck.new(cards: data['name'].size, layout: 'action.yml') do
  png file: 'img/background.png', layout: :Background
  svg file: 'img/target.svg', layout: :Target_Icon

  svg file: req_art.map{ |(art, type)| "img/art/#{art}_#{type}.svg" }, layout: :Art

  text str: data['name'], color: data['type'].map{|t| colors[t]}, layout: :Name

  text(str: data['description'], layout: :Description) do |embed|
    %w(shot beer bottle).each do |drink|
      embed.svg key: ":#{drink}:", file: "img/#{drink}.svg", width: 40, dx: 0, dy: 2, height: :scale
    end
  end

  text str: data['flavor'].map{|f| "~ #{f} ~"}, layout: :Flavor

  text str: data['target'], layout: :Target

  svg file: data['type'].map{|t| "img/type_#{t}.svg"}, layout: :Type

  for n in 1..3
    range = data['cost'].each_index.select{ |i| data['cost'][i] != '?' and data['cost'][i] >= n and data['cost'][i] <= 3}
    svg file: 'img/cost.svg', layout: "Cost#{n}", range: range
  end
    costlies = data['cost'].each_index.select{ |i| data['cost'][i] == '?' or data['cost'][i] > 3}
    text str: data['cost'].map{ |c| c.to_s + 'x'}, layout: :Cost_Text, range: costlies
    svg file: 'img/cost.svg', layout: :Cost2, range: costlies

  save_pdf width: cm(29.7), height: cm(21)
end
