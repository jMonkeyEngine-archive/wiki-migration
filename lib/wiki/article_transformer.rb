module Wiki
  class ArticleTransformer
    include Import[:logger, :build_path]

    def call(input)
      doc = input.fetch(:body)
      doc.css('a.media').each(&method(:fix_media_link))
      doc.css('a.wikilink1').each(&method(:fix_wiki_link))
      Right(Page.new({
                         title: Try { doc.at_css('.sectionedit1').text }.value,
                         body: doc.to_xml.strip,
                         path: input.fetch(:path)
                     }))
    end

    def Params(input)
      return {} if input.nil?
      return input if input.kind_of?(Hash)
      return Params(input.query) if input.kind_of?(Addressable::URI)
      if input.kind_of?(String)
        return Params(URL(input))
      end
      raise "cannot convert #{input.inspect} to Params"
    end

    def URL(url)
      return url if url.kind_of?(Addressable::URI)
      Addressable::URI.parse(url)
    end

    private
    def fix_media_link(a)
      result = Try {
        url = Addressable::URI.parse(a.get('href'))
        url.host = 'wiki.jmonkeyengine.org'
        url.scheme = 'http'
        params = Params(url)

        if params.key?('media')
          media_url = Addressable::URI.parse(params['media'][0])
        else
          media_url = Addressable::URI.parse(a.at_css('img').get('src'))
        end

        logger.debug("media_url #{media_url}")

        filename = Pathname(media_url.path).basename.to_s.tr(':', '-')
        resource_path = build_path.join('resources', filename)


        media_url.scheme = url.scheme
        media_url.host = url.host
        logger.debug("downloading #{media_url}")
        response = follow_redirects(http.get(media_url))


        new_path = "/resources/#{filename}"

        a.set('href', new_path)
        a.css('img').each do |img|
          img.set('src', new_path)
        end
        resource_path.write(response.to_s)
      }
      if result.exception
        logger.error("could not transform #{a.to_xml}")
        logger.error(result.exception)
      end
    end

    def follow_redirects(response)
      while response.status == 301 || response.status == 302
        logger.debug("following redirect to #{response[:location]}")
        response = http.get(response[:location])
      end
      response
    end

    def http
      HTTP.timeout(:global, read: 2, write: 1, connect: 2)
    end

    def fix_wiki_link(a)
      result = Try {
        url = a.get('href')
        return if url.start_with?('#')
        new_url = wiki_url2filename(url)
        logger.debug("rewrite wiki #{a.text.inspect} link #{url} --> #{new_url}")
        a.set('href', new_url)
      }
      if result.exception
        logger.error("failed to rewrite wiki link #{a.to_xml}")
        logger.error(result.exception)
      end
    end

    def wiki_url2filename(url)
      url = URL(url)
      url.path = '/' + url.path[10..-1].tr(':', '-') + '.html'
      url.to_s
    end
  end
end