module Wiki
  class Path
    def initialize(segments)
      @segments = segments.freeze
    end

    attr_reader :segments

    def to_s
      @segments.join(':')
    end

    class << self
      def from_url(url)
        url = Wiki::URL(url)
        new(url.path[10..-1].split(':'))
      end
    end
  end
  def self.Path(url)
    Path.from_url(Wiki::URL(url))
  end

  def self.URL(url)
    return url if url.kind_of?(Addressable::URI)
    Addressable::URI.parse(url)
  end
end
