require 'bundler'
Bundler.setup

require 'oga'
require 'json'
require 'http'
require 'yaml'
require 'pathname'

doc = Oga.parse_html(File.read('input.html'))

links = doc.css('a').map do |a|
  {
      title: a.get('title'),
      text: a.text,
      url: a.get('href')
  }
end

# puts JSON.pretty_generate(links)

# ?do=export_xhtmlbody

urls = links.map { |a| a.fetch(:url) }


urls.concat(YAML.load(File.read('manually_added.yaml')))

urls = urls
           .map { |u| Addressable::URI.parse(u).path } # extract the path from
           .select { |p| p.to_s.start_with?('/doku.php') } # select all paths that starts with /doku.php
           .uniq # filter duplicates


def wiki_url2filename(url)
  url[10..-1].tr(':', '-') << '.html'
end

root = Pathname('dump')
root.mkpath

HTTP.persistent('http://wiki.jmonkeyengine.org') { |http|
  urls.each do |url|
    response = http.get(url + '?do=export_xhtmlbody')
    filename = wiki_url2filename(url)
    puts filename
    if response.status == 200
      body = response.to_s

      root.join(filename).write(body)
    else
      STDERR.puts response.body
    end
  end
}