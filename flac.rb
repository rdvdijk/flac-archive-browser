require 'ruby-audio'
require 'flacinfo'
require 'icanhasaudio'

class Flac < Handle

  attr_reader :path, :out_sound

  def initialize(path)
    @path = path

    # OGG/Vorbis
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
    "/listen/#{encoded_path_suffix}"
  end

  def stream_vorbis_path
    "/stream-vorbis/#{encoded_path_suffix}"
  end

  def stream_mp3_path
    "/stream-mp3/#{encoded_path_suffix}"
  end

  def flac_path
    "/flac/#{encoded_path_suffix}"
  end

  def mp3_path
    "/mp3/#{encoded_path_suffix}"
  end

  def vorbis_path
    "/ogg_vorbis/#{encoded_path_suffix}"
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

  def stream_mp3
    encoder = Audio::MPEG::Encoder.new
    encoder.init

    RubyAudio::Sound.open(@path) do |sound|
      while buf = sound.read(:short, 64*1024) and buf.real_size > 0
        input = buffer_to_io(buf)
        encoder.encode_io(input) do |data|
          yield data
        end
      end
    end
  end

  def flac_data
    File.read(@path)
  end

  def mp3_data
    %x(flac -s -c -d "#{@path}" | lame --tt "#{title}" --ta "#{artist}" --tl "#{album}" --tn "#{track_number}" --tg "#{genre}" --ty "#{date}" --tc "#{comment}" --quiet -V0 - -)
  end

  def ogg_vorbis_data
    %x(flac -s -c -d "#{@path}" | oggenc -t "#{title}" -a "#{artist}" -l "#{album}" -N "#{track_number}" -G "#{genre}" -d "#{date}" -c "#{comment}" -Q -q 6 -)
  end

  def title
    flac_info.tags["TITLE"]
  end

  private

  def artist
    flac_info.tags["ARTIST"]
  end

  def album
    flac_info.tags["ALBUM"]
  end

  def track_number
    flac_info.tags["TRACKNUMBER"]
  end

  def genre
    flac_info.tags["GENRE"]
  end

  def date
    flac_info.tags["DATE"]
  end

  def comment
    flac_info.tags["COMMENT"]
  end

  def flac_info
    @flac_info ||= FlacInfo.new(@path)
  end

  # Taken from RustRadio::ShoutcastWriter
  def buffer_to_io(buffer)
    samples = buffer_to_samples(buffer)

    in_buffer = StringIO.new
    in_buffer.write(samples.pack("v*"))
    in_buffer.seek(0)

    in_buffer
  end

  def buffer_to_samples(buffer)
    samples = []
    buffer.each do |left, right|
      samples << left << right
    end
    samples
  end

  private

  def encode(value)
    URI.encode_www_form_component(value)
  end

end
