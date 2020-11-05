class Handle

  def name
    @path.split("/").last
  end

  def encode(path)
    path.split("/").map do |string|
      URI.encode_www_form_component(string)
    end.join("/")
  end

  def path_suffix
    @path.sub(/^#{Configuration.archive_path}/, "")
  end

  def encoded_path_suffix
    URI.encode_www_form_component(path_suffix).gsub("%2F", "/")
  end

  def parent_browse_path
    "/browse#{encode(parent_path)}"
  end

  def parent_path
    sub_path = @path.sub(/^#{Configuration.archive_path}/, "")
    sub_path.split("/")[0..-2].join("/")
  end

  def parent_name
    parent_path.split("/").last || "root"
  end

end
