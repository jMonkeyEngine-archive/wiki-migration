module Wiki
  class LoadFile
    include Wiki::Import[:root_path, :logger]

    def call(path)
      logger.info "read #{path}"
      path = Pathname(path)
      path = root_path.join(path) if path.relative?

      Right({
                path: Wiki::Path.new(path.basename(path.extname).to_s.split('-')),
                body: path.read
            })
    rescue Errno::ENOENT => ex
      Left(ex)
    end
  end
end
