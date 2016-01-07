module Wiki
  class MarkdownFormatter
    # @param page [Wiki::Page]
    def call(page)
      Right(page.with(
          body: add_frontmatter(page),
          format: 'markdown'
      ))
    end

    def add_frontmatter(page, layout: 'post')
      <<-TMP
---
layout: #{layout}
title: #{page.title}
---
#{page.body}
      TMP
    end
  end
end
