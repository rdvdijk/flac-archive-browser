class Folder < Handle

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def browse_path
    "/browse#{encode(path_suffix)}"
  end

  def folders
    @folders ||= begin
                   Dir.chdir(@path)
                   Dir.glob("*/").map do |dir|
                     Folder.new(File.join(@path, dir))
                   end
                 end
  end

  def folders?
    folders.any?
  end

  def flacs
    @flacs ||= begin
                 Dir.chdir(@path)
                 Dir.glob("*.flac").map do |flac|
                   Flac.new(File.join(@path, flac))
                 end
               end
  end

  def flacs?
    flacs.any?
  end

end
