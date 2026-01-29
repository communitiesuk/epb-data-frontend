module Helper
  module Assets
    def self.path(default_path)
      return default_path unless ENV["ASSETS_VERSION"]

      "/static/#{ENV['ASSETS_VERSION']}#{default_path}"
    end

    def self.inline_svg(path, attrs = {})
      file_path = File.expand_path(File.join(__dir__, "/../../public", path(path)))
      return unless File.exist?(file_path)

      svg = File.read(file_path)
      return svg if attrs.nil? || attrs.empty?

      attrs_str = attrs.map { |k, v| %(#{k}="#{Rack::Utils.escape_html(v.to_s)}") }.join(" ")

      # Injects attributes into the first <svg ...> tag
      svg.sub(/<svg(\s|>)/) { |m| %(<svg #{attrs_str}#{m[4..]}) }
    end

    def self.data_uri_svg(path)
      svg_content = inline_svg path
      return if svg_content.nil?

      "data:image/svg+xml;utf8,#{svg_content.gsub('"', "'").gsub('#', '%23')}"
    end

    def self.setup_cache_control(context)
      return unless ENV["ASSETS_VERSION"]

      context.set :static_cache_control, [:public, { max_age: 604_800 }] # cache for one week
    end
  end
end
