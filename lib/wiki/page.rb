module Wiki
  class Page
    include Anima.new(:title, :body, :path, :format)

    def to_s
      "#{self.class.name}(#{title.inspect})"
    end
  end
end
