module Wiki
  class Page
    include Anima.new(:title, :body, :path)

    def to_s
      "#{self.class.name}(#{title.inspect})"
    end
  end
end