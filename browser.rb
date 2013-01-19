require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'sinatra/streaming'
require 'uri'

require './configuration'
require './handle'
require './flac'
require './folder'

class Browser < Sinatra::Base

  def get_folder(params)
    folder_path = params[:splat].first
    full_path = File.join(Configuration.archive_path, folder_path)
    Folder.new(full_path)
  end

  def get_flac(params)
    flac_path = params[:splat].first
    full_path = File.join(Configuration.archive_path, flac_path)
    Flac.new(full_path)
  end


  get '/' do
    redirect "/browse"
  end

  get '/browse/?*' do
    @folder = get_folder(params)
    haml :browse
  end

  get '/listen/*' do
    @flac = get_flac(params)
    haml :listen
  end

  get '/stream/*' do
    @flac = get_flac(params)

    content_type "application/ogg"
    stream do |out|
      @flac.stream_ogg_vorbis do |data|
        out << data
      end
    end
  end

  get '/flac/*' do
    @flac = get_flac(params)
    content_type "audio/flac"
    attachment @flac.name
    @flac.flac_data
  end

  get '/mp3/*' do
    @flac = get_flac(params)
    content_type "audio/mpeg"
    attachment @flac.mp3_name
    @flac.mp3_data
  end

  get '/ogg_vorbis/*' do
    @flac = get_flac(params)
    content_type "application/ogg"
    attachment @flac.ogg_vorbis_name
    @flac.ogg_vorbis_data
  end

end
