class WebsitePreviewPicWorker
  include Sidekiq::Worker
  sidekiq_options :queue => 'website_preview_pic', :retry => false, :backtrace => true

  def perform(options = {})
    # WebsiteMenu.generate_preview_pic(options)
    
    options = HashWithIndifferentAccess.new(options)
    puts "******* Starting options #{options}"

    if options[:website_id]
      website = Website.where(id: options[:website_id]).first
      website_menus = website.try(:website_menus)
    elsif options[:website_menu_id]
      website_menu = WebsiteMenu.where(id: options[:website_menu_id]).first
      if website_menu
        website_menus = [ website_menu ]
        website = website_menu.website
        options[:website_id] = website_menu.website_id
      else
        website_menus = []
        website = nil
      end
    else
      puts "require website_id or website_menu_id"
      return
    end

    puts "******* website #{website.id} website_menu: #{website_menus.count}"
      
    if website
      pic_dir =  Rails.root.to_s + "/public/uploads/preview_pic/website_menu/#{website.id}/"
      unless Dir.exists? pic_dir
        FileUtils.mkdir_p pic_dir
        Rails.logger.info "****************** mkdir #{pic_dir} ********************"
      end

      host = Settings.mhostname

      if options[:website_id]
        # website.update_attributes(preview_pic: '')
        file_name = "logo.jpg"
        pic = pic_dir + file_name
        url = [ host, website.supplier_id ].join('/')
        puts " website options: url:#{url} pic:#{pic}"

        begin
          if system("wkhtmltoimage --no-stop-slow-scripts --javascript-delay 5000 --width 260 --crop-w 260 --crop-h 400 #{url} #{pic}")
            website.update_attributes(preview_pic: file_name)
            puts "******** website pic ok"
          end
        rescue => error
          puts "generate url #{url} error: #{error}"
        end
      end

      website_menus.each do |website_menu|
        # website_menu.update_attributes(preview_pic: '')
        if website_menu.has_children?
          file_name = "#{website_menu.id}.jpg"
          pic = pic_dir + file_name
          url = [ host, website.supplier_id, 'channel', website_menu.id ].join('/')
          puts "website_menu options: url:#{url} pic:#{pic}"

          begin
            if system("wkhtmltoimage --no-stop-slow-scripts --javascript-delay 5000 --width 260 --crop-w 260 --crop-h 400 #{url} #{pic}")
              website_menu.update_attributes(preview_pic: file_name)
              puts "website_menu pic ********"
            end
          rescue => error
            puts "generate url #{url} error: #{error}"
          end
        end
      end

    end # end of website
  end

end
