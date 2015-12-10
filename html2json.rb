require 'bundler'
Bundler.setup

require 'oga'
require 'json'

doc = Oga.parse_html(File.read('input.html'))

links = doc.css('a').map do |a|
  {
      title: a.get('title'),
      text: a.text,
      url: a.get('href')
  }
end
puts JSON.pretty_generate(links)
