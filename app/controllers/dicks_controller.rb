class DicksController < ApplicationController
  SUCKR = ImageSuckr::GoogleSuckr.new
  MAX_RETRIES = ENV.fetch('SEARCH_MAX_RETRIES', 5).to_i

  def show
    retries = 0
    begin
      url = SUCKR.get_image_url search_query
      image = MiniMagick::Image.open url
      image.resize "#{params[:width]}x#{params[:height]}!"
      tmp_file = Rails.root.join "tmp/#{url.split('/').last}"
      image.write tmp_file.to_s

      send_data tmp_file.read, {
        disposition: 'inline', 
        filename:    url.split('/').last, 
        type:        image.mime_type
      }
    rescue OpenURI::HTTPError => e
      retries += 1
      retry unless retries >= MAX_RETRIES 
      raise e
    end
  end

  private

  def search_query
    {
      'q'       => params[:q] || 'dicks OR penis OR cock OR shlong', 
      'imgtype' => params[:imgtype] || 'photo',
      'imgsz'   => image_size_mapping(params[:width], params[:height]),
      'safe'    => 'off', # definitely
    }.tap do |query|
      query['as_filetype']   = params[:as_filetype] if params[:as_filetype].present?
      query['as_sitesearch'] = params[:as_sitesearch] if params[:as_sitesearch].present?
      query['imgcolor']      = params[:imgcolor] if params[:imgcolor].present?
    end
  end

  # https://developers.google.com/image-search/v1/jsondevguide?csw=1#json_args
  def image_size_mapping(width, height)
    case [width, height].max.to_i when 1..100
      'icon'
    when 101..300
      'medium'
    when 301..500
      'large'
    when 501..800
      'xlarge'
    when 801..1000
      'xxlarge'
    else
      'huge'
    end
  end
end
