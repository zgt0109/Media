# -*- encoding : utf-8 -*-
module    

  # WinwemediaLog::Base.logger('dir_name', 'testing message')
  class Base < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file(dir)
      # file_name = Time.now.strftime('%Y%m%d-%H')
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/#{dir}/"
      unless Dir.exists? log_dir
        FileUtils.mkdir_p log_dir
        Rails.logger.info "****************** mkdir #{log_dir} ********************"
      end
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.logger(dir, msg)
      logfile = self.get_file(dir)
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class WeixinLog < Logger
    def self.get_file
      # file_name = Time.now.strftime('%Y%m%d-%H')
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/weixin_logs/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}"
      logfile.flush
      logfile.close
    end
  end

  class PrintLog < Logger
    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/print_logs/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}"
      logfile.flush
      logfile.close
    end
  end

  class Alipay < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      # file_name = Time.now.strftime('%Y%m%d-%H')
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/alipay/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class Weixinpay < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/weixinpay/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class Weixinpayv2 < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/Weixinpayv2/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class Weixinredpacketpay < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/Weixinredpacketpay/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class Bind < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m')
      log_dir =  Rails.root.to_s + "/public/logs/bind/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"

      # file_name = "#{Time.now.strftime('%Y%m%d')}.txt"
      # file = Rails.root.to_s + "/public/logs/bind.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class WeixinApi < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/weixin/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class BqqApi < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/biz_qq/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg)
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class JobLog < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/job/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg, op='unknow')
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class ErrorLog < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/error/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg, op='unknow')
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class VipCardApi < Logger
    def format_message(serverity, timestamp, progname, msg)
      "[#{timestamp.to_formatted_s(:db)}] #{msg}"
    end

    def self.get_file
      file_name = Time.now.strftime('%Y%m%d')
      log_dir =  Rails.root.to_s + "/public/logs/vip_user/"
      FileUtils.mkdir_p log_dir unless Dir.exists? log_dir
      file = log_dir + "#{file_name}.txt"
      File.open(file, 'a')
    end

    def self.add(msg, op='unknow')
      logfile = self.get_file
      log = self.new(logfile)
      log.info "#{msg}\n\n"
      logfile.flush
      logfile.close
    end
  end

  class Payment < Logger
    def self.logger
      logger_path = "#{Rails.root}/public/logs/error/payment"
      unless Dir.exists? logger_path
        FileUtils.mkdir_p logger_path
      end
      file_name = Time.now.strftime('%Y%m%d')
      ActiveSupport::BufferedLogger.new(Rails.root.join("#{logger_path}/#{file_name}.txt"))
    end
  end

end
