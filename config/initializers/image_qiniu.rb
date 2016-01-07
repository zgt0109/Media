class ImageQiniu

  attr_accessor :key, :key_prefix

  def initialize(key = nil, key_prefix: nil)
    @key = key
    @key_prefix = key_prefix
  end

  def to_s
    return key if key.to_s =~ /\Ahttp/
    qiniu_image_url("#{key_prefix}#{key}")
  end

  def method_missing(name,*args)
    self
  end

end