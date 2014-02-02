class DicksController < ApplicationController
  SUCKR = ImageSuckr::GoogleSuckr.new
  DICKS_QUERY = 'dicks penises cocks'

  def show
    url = SUCKR.get_image_url search_query
    image = MiniMagick::Image.open url
    image.resize "#{params[:width]}x#{params[:height]}!"

    send_data image.to_blob, {  
      disposition: 'inline', 
      filename: url.split('/').last, 
      type: image.mime_type
    }
  end

  private

  def search_query
    {
      'q'       => params[:q] || DICKS_QUERY, 
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
