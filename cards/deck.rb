require 'squib'

colors = {
  'status' => '#63b0ef',
  'action' => '#f46400',
}

data = Squib.csv file: 'data/action.csv'
Squib::Deck.new(cards: data['name'].size, layout: 'action.yml') do
  png file: 'img/background.png', layout: :Background
  svg file: 'img/target.svg', layout: :Target_Icon

  svg file: data['art'].map{ |art| "img/art/#{art}.svg" }, layout: :Art

  text str: data['name'], color: data['type'].map{|t| colors[t]}, layout: :Name

  text(str: data['description'], layout: :Description) do |embed|
    %w(shot beer).each do |drink|
      embed.svg key: ":#{drink}:", file: "img/#{drink}.svg", width: 32, dx: 3, height: :scale
    end
  end

  text str: data['flavor'].map{|f| "~ #{f} ~"}, layout: :Flavor

  text str: data['target'], layout: :Target

  svg file: data['type'].map{|t| "img/type_#{t}.svg"}, layout: :Type

  for n in 1..3
    range = data['cost'].each_index.select{ |i| data['cost'][i] >= n and data['cost'][i] <= 3}
    svg file: 'img/cost.svg', layout: "Cost#{n}", range: range
  end
    costlies = data['cost'].each_index.select{ |i| data['cost'][i] > 3}
    text str: data['cost'].map{ |c| c.to_s + 'x'}, layout: :Cost_Text, range: costlies
    svg file: 'img/cost.svg', layout: :Cost2, range: costlies

  save format: :png
end
