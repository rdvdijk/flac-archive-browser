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
                   Dir.glob("*/").sort.map do |dir|
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
                 Dir.glob("*.flac").sort.map do |flac|
                   Flac.new(File.join(@path, flac))
                 end
               end
  end

  def flacs?
    flacs.any?
  end

  def info_file
    Dir.chdir(@path)
    txt_files = Dir.glob("*.txt").sort_by(&:length)
    File.read(txt_files.first)
  end

end
