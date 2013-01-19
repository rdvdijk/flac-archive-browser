require 'ruby-audio'

class Flac < Handle

  attr_reader :path, :out_sound

  def initialize(path)
    @path = path
    @sound_info = RubyAudio::SoundInfo.new(
      :channels => 2,
      :samplerate => 44100,
      :format => RubyAudio::FORMAT_OGG|RubyAudio::FORMAT_VORBIS
    )
    @io = StringIO.new
  end

  def size
    "#{(File.size(@path)/(1024*1024.0)).round(2)} MB"
  end

  def mp3_name
    "#{name}.mp3"
  end

  def ogg_vorbis_name
    "#{name}.ogg"
  end

  def listen_path
    URI.encode "/listen#{path_suffix}"
  end

  def stream_path
    URI.encode "/stream#{path_suffix}"
  end

  def flac_path
    URI.encode "/flac#{path_suffix}"
  end

  def mp3_path
    URI.encode "/mp3#{path_suffix}"
  end

  def vorbis_path
    URI.encode "/ogg_vorbis#{path_suffix}"
  end

  def stream_ogg_vorbis
    out_sound = RubyAudio::Sound.open(@io, 'w', @sound_info)

    RubyAudio::Sound.open(@path) do |sound|
      while buf = sound.read(:short, 64*1024) and buf.real_size > 0
        @io.string = "" # reset output buffer
        out_sound.write(buf)
        yield @io.string
      end
    end
  ensure
    out_sound.close
  end

  def flac_data
    File.read(@path)
  end

  def mp3_data
    %x(flac -s -c -d "#{@path}" | lame --quiet -V0 - -)
  end

  def ogg_vorbis_data
    %x(flac -s -c -d "#{@path}" | oggenc -Q -q 6 -)
  end

end
