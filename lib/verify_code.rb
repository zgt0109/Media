# -*- encoding : utf-8 -*-
require 'RMagick'

class VerifyCode
  include Magick

  attr_reader :code, :code_image
  
  def initialize(len=4)
    # if Rails.env.production?
    #   self.generate_code_tencent(len)
    # else
    #   self.generate_code(len)
    # end
    self.generate_code(len)
  end

  def generate_code_tencent(len=4)
    chars =('1'..'8').to_a
    code_array=[]
    1.upto(len){code_array << chars[rand(chars.length)]}
    granite = Magick::ImageList.new('xc:#EDF7E7')
    canvas  = Magick::ImageList.new
    canvas.new_image(25*len, 32, Magick::TextureFill.new(granite))
    text = Magick::Draw.new
    #text.font_family=['times', 'sans', 'fixed', 'Verdana'].sort{rand}.pop
    text.pointsize = 25
    cur =0

    code_array.each { |c|

      text.annotate(canvas,0,1,cur,0,c){
        self.rotation= 3
        self.font_weight = BoldWeight
        self.fill = 'red'
      }
      cur += 18
    }
    @code=code_array.join
    @code_image = canvas.to_blob{
      self.format="JPG"
    }
  end
  
  # For server web1.winwemedia.com web2.winwemedia.com
  def generate_code(length = 4)
    text_size = 33
    rand_height = 4
    colors = ['#FF0000', '#3300CC', '#FF3300', '#b50000', '#373000', '#f000f0', '##336600']
    # validbglinecolors = ['#ABEFAB', '#FF99FF', '#CCCCFF', '#66FF66', '#CCFF33']
    validbglinecolors = ['#FFFFFF']*5
    validchars = (0..9).to_a
    dist = (5..15).to_a
    step = 10
    chars = []
    text_size_space = text_size * 0.8
    text_size_step = text_size * 0.6
    length.times {|x|
      chars << validchars[rand(validchars.size).ceil - 1].to_s
    }
   
    bglinecolor = validbglinecolors[rand(validbglinecolors.size).ceil - 1]
    image = Image.new(length * text_size_step + 10, text_size * 1.2, HatchFill.new('white', bglinecolor, dist[rand(dist.size - 1)]))
    text = Draw.new
    #使用字体文件和直接使用字体，或者不写font, font_family两个属性都是如图所示结果，linux下无字显示
    text.font = "fonts/" + ['times.ttf', 'arial.ttf', 'verdana.ttf', 'artro.ttf'].sort{rand}.pop
    #text.font_family = ['times', 'sans', 'fixed', 'Verdana'].sort{rand}.pop
    text.font_weight = BoldWeight
    text.text(0,0, ' ')
   
    chars.each {|char|
      text.annotate(image,0 , 0, step,  28, char) {
        self.rotation = dist[rand(dist.size - 1).ceil]
        self.fill = colors[rand(colors.size - 1).ceil]
        self.pointsize = text_size - validchars[rand(rand_height).ceil]
      }
      step += text_size_step - rand(5)
    }
    text.draw(image)
   
    @code = chars.join#chars.to_s()
    @code_image = image.to_blob{ self.format="JPG" }
  end

end
