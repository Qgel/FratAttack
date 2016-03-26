require 'squib'
require 'game_icons'
require_relative 'images'

color_config = {
  'color' => {
    'status' => '#63b0ef',
    'active' => '#f46400',
    'description' => '#ECF5FD',
    'flavor' => '#ECF5FD',
    'embed' => '#F49000',
    'icon' => '#ffffff',
  },
  'bw' => {
    'status' => '#000000',
    'active' => '#000000',
    'description' => '#000000',
    'flavor' => '#2f2f2f',
    'embed' => '#2f2f2f',
    'icon' => '#2f2f2f'
  }
}


mode = ENV['palette']
colors = color_config[mode]

data = Squib.csv file: 'data/action.csv'
event = Squib.csv file: 'data/event.csv'
event.each do |k, v|
  data[k] += v
end

req_art = data['art'].zip(data['type'])
images = load_images(req_art, colors)

def allSatisfying(data)
  data.each_index.select{ |i| yield(data[i]) }
end

Squib::Deck.new(cards: data['name'].size, layout: 'action.yml', dpi: 450) do
  png file: "img/background_#{mode}.png", layout: :Background
  svg data: images['icon_target'], layout: :Target_Icon 

  svg data: req_art.map{ |(art, type)| images["#{art}_#{type}"] }, layout: :Art

  text str: data['name'], color: data['type'].map{|t| colors[t]}, layout: :Name

  text(str: data['description'], layout: :Description, color: colors['description']) do |embed|
    %w(shot beer bottle).each do |drink|
      embed.svg key: ":#{drink}:", data: images["icon_#{drink}"], width: 40, dx: 0, dy: 2, height: :scale
    end
  end

  text str: data['flavor'].map{|f| "~ #{f} ~"}, layout: :Flavor, color: colors['flavor']

  text str: data['target'], layout: :Target, color: colors['icon']

  svg data: data['type'].map{|t| images["type_#{t}"]}, layout: :Type

  # Cost icons for action cards
  for n in 1..3
    svg data: images['icon_cost'], layout: "Cost#{n}", range: allSatisfying(data['cost']) { |v| v != '?' and v >= n and v <= 3 }
  end
    costlies = allSatisfying data['cost'] { |v| v == '?' or v > 3}
    text str: data['cost'].map{ |c| c.to_s + 'x'}, layout: :Cost_Text, color: colors['icon'], range: costlies
    svg data: images['icon_cost'], layout: :Cost2, range: costlies

  # Display "Event" and icon instead for event cards
  text str: "Event", layout: :Event_Text, color: colors['icon'], range: -event['name'].size..-1
  svg data: images['icon_event'], layout: :Cost1, range: -event['name'].size..-1

  save_pdf width: cm(29.7), height: cm(21)
end

print "Generated #{data['name'].size} cards: #{data['name'].size - event['name'].size} action, #{event['name'].size} event.\n"

