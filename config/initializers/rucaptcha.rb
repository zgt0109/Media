RuCaptcha.configure do
  # 生成多少个字符
  self.len = 4

  # 字体大小
  self.font_size = 35

  # Image width, default: 180
  self.width = 90
  # Image height, default: 48
  self.height = 40

  # 开启文件缓存，并设定每个进程最大生成的验证码数量限制，达到限制以后会反复利用之前的缓存文件
  # 当 Rails 进程重启以后，又会重新生成，并清理之前的文件缓存 (`Rails.root.join('tmp/cache/rucaptcha')` 里面)
  # 设置 0 关闭缓存, 默认 100
  self.cache_limit = 100

  # 文字扭曲度，调整这个可以提高阅读难度，默认 0.4 范围 [0.0 - 1.0]
  self.implode = 0
end