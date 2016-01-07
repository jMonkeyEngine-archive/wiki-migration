require_relative 'boot'
require 'addressable'
require 'http'
require 'anima'
require 'logger'
require 'call_sheet'
require 'dry-component'
require 'dry/component/container'
require 'dry-auto_inject'

module Wiki
  Container = Dry::Container.new
  Import = Dry::AutoInject(Container)
end

require 'wiki/page'
require 'wiki/load_file'
require 'wiki/parse_xml'
require 'wiki/article_transformer'
require 'wiki/markdown_formatter'
module Wiki
  Container.register(:root_path, Pathname('.'))
  Container.register(:build_path, Container[:root_path].join('build'))
  Container.register(:logger, Logger.new(STDOUT).tap { |logger| logger.level = Logger::DEBUG })
  Container.register(:load_file, LoadFile.new)
  Container.register(:parse_xml, ParseXML.new)
  Container.register(:transform_xml, Wiki::ArticleTransformer.new)
  Container.register(:markdown_formatter, Wiki::MarkdownFormatter.new)
end

compile_file = CallSheet(container: Wiki::Container) {
  step(:load_file)
  step(:parse_xml)
  step(:transform_xml)
  step(:markdown_formatter)
}

root = Pathname('build')

Dir[Pathname(__FILE__).dirname.join('dump', '*.html')].each do |file|

  compile_file.call(file) do |result|
    result.success do |page|
      path = Pathname(file)
      root.join(path.basename(path.extname).to_s + '.md').write(page.body)
    end
  end
end

