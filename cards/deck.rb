require 'squib'

colors = {
  'status' => '#63b0ef',
  'action' => '#ff0000',
}

data = Squib.csv file: 'data/action.csv'
Squib::Deck.new(cards: data['name'].size, layout: 'action.yml') do
  png file: 'img/background.png', layout: :Background

  svg file: 'img/art/broken-shield.svg', layout: :Art

  text str: "Broken Shield", color: '#63b0ef', layout: :Name

  text str: "Drink only half the amount (rounded up) you are forced to by any action targeted at you.",
    layout: :Description 

  text str: "~Death by two-thousand cuts~", layout: :Flavor

  svg file: 'img/target.svg', layout: :Target_Icon

  text str: "Self", layout: :Target

  svg file: 'img/type_status.svg', layout: :Type

  svg file: 'img/cost.svg', layout: :Cost1
  svg file: 'img/cost.svg', layout: :Cost2

  save format: :png
end
