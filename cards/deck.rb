require 'squib'
require 'game_icons'
require 'nokogiri'

def recolor(str, bg: '#000', fg: '#fff', bg_opacity: "1.0", fg_opacity: "1.0")
  doc     = Nokogiri::XML(str)
  doc.css('path')[0]['fill'] = bg # dark backdrop
  doc.css('path')[1]['fill'] = fg # light drawing
  doc.css('path')[0]['fill-opacity'] = bg_opacity.to_s # dark backdrop
  doc.css('path')[1]['fill-opacity'] = fg_opacity.to_s # light drawing
  doc.to_xml
end

def load_image_local(path, color)
    ico = File.open(path){ |f| f.read }
    recolor(ico, fg: color, bg_opacity: 0.0)
end


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

images = {
  'type_status' => GameIcons.get('aura').recolor(fg: colors['icon'], bg_opacity: 0.0).string,
  'type_active' => GameIcons.get('fast-arrow').recolor(fg: colors['icon'], bg_opacity: 0.0).string,
  'icon_beer' => load_image_local("img/beer.svg", colors['embed']),
  'icon_shot' => load_image_local("img/shot.svg", colors['embed']),
  'icon_bottle' => load_image_local("img/bottle.svg", colors['icon']),
  'icon_cost' => load_image_local("img/cost.svg", colors['icon']),
  'icon_target' => load_image_local("img/target.svg", colors['icon']),
  'icon_event' => load_image_local("img/event.svg", colors['icon']),
}

# Load images from game-icons.net
req_art = data['art'].zip(data['type'])
req_art.uniq.each do |(art, type)|
  if GameIcons.names.include? art
    ico = GameIcons.get(art).recolor(fg: colors[type], bg_opacity: 0.0).string
  else
    ico = load_image_local("img/art/#{art}.svg", colors[type])
  end
  images["#{art}_#{type}"] = ico
end

def allSatisfying(data)
  data.each_index.select{ |i| yield(data[i]) }
end

Squib::Deck.new(cards: data['name'].size, layout: 'action.yml') do
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

