require 'nokogiri'

# Recoloring for icons from game-icons.net
def recolor(str, bg: '#000', fg: '#fff', bg_opacity: "1.0", fg_opacity: "1.0")
  doc     = Nokogiri::XML(str)
  doc.css('path')[0]['fill'] = bg # dark backdrop
  doc.css('path')[1]['fill'] = fg # light drawing
  doc.css('path')[0]['fill-opacity'] = bg_opacity.to_s # dark backdrop
  doc.css('path')[1]['fill-opacity'] = fg_opacity.to_s # light drawing
  doc.to_xml
end

def load_image_local(path, color)
  if not File.exist? path
    print "Warning: Missing image #{path}\n"
    return nil
  end
  ico = File.open(path){ |f| f.read }
  recolor(ico, fg: color, bg_opacity: 0.0)
end

# Load images from game-icons.net or from local files
def load_images(req_art, colors)
  images = {
    'type_status' => GameIcons.get('aura').recolor(fg: colors['icon'], bg_opacity: 0.0).string,
    'type_active' => GameIcons.get('fast-arrow').recolor(fg: colors['icon'], bg_opacity: 0.0).string,
    'icon_beer' => load_image_local("img/beer.svg", colors['embed']),
    'icon_shot' => load_image_local("img/shot.svg", colors['embed']),
    'icon_bottle' => load_image_local("img/bottle.svg", colors['embed']),
    'icon_cost' => load_image_local("img/cost.svg", colors['icon']),
    'icon_target' => load_image_local("img/target.svg", colors['icon']),
    'icon_event' => load_image_local("img/event.svg", colors['icon']),
  }

  req_art.uniq.each do |(art, type)|
    if GameIcons.names.include? art
      ico = GameIcons.get(art).recolor(fg: colors[type], bg_opacity: 0.0).string
    else
      ico = load_image_local("img/art/#{art}.svg", colors[type])
    end
    images["#{art}_#{type}"] = ico
  end

  images
end
