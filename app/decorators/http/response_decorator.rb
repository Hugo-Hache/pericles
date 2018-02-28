class HTTP::ResponseDecorator < Draper::Decorator
  delegate_all

  def body
    content = object.body.to_s
    return content if content.empty?

    case object.headers[:content_encoding]
    # NOTE: Clément Villain 28/12/17
    # 'deflate' seems to be a nightmare because of different implementations
    # and seems to not be used by webserver
    when 'gzip'
      Zlib::GzipReader.new(StringIO.new(content)).read
    else
      object.body
    end
  end
end