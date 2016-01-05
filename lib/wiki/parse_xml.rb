require 'oga'
require 'cgi'
module Wiki
  class ParseXML
    def call(input)
      input[:body] = Oga.parse_html(input.fetch(:body))
      Right(input)
    end
  end
end