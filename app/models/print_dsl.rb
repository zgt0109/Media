class PrintDsl                                                                                                                                                                                 
  attr_reader :result, :pre_width, :line                                                                                                                                                       
                                                                                                                                                                                               
  def initialize(&block)                                                                                                                                                                       
    instance_eval(&block)                                                                                                                                                                      
  end                                                                                                                                                                                          


  private                                                                                                                                                                                      
                                                                                                                                                                                               
  def method_missing(name, *args, &block)                                                                                                                                                      
    if name.to_s == 'newline'                                                                                                                                                                  
      @line = ""                                                                                                                                                                              
      if block_given?                                                                                                                                                                          
        instance_eval(&block)                                                                                                                                                                  
      end                                                                                                                                                                                      
      @result ||= ""                                                                                                                                                                          
      @result << @line << "\n"                                                                                                                                                               
    end     

    if name.to_s == 'text_left'                                                                                                                                                                     
      blank_number = args[1].to_i   
      string = args[0]                                             
      pre_width ||= 0                                                                                                                                                                         
      pre_width += get_length(@line)      
      blank_number = blank_number - pre_width       
      blank_number = blank_number / 12                                                                                                                                                         
      if blank_number < 0                                                                                                                                                                      
        raise "#{string} is bigger than blank"  
      end                                                                                                                                                                                      
      @line << "#{ ' ' * blank_number }#{string}"                                                                                                                                              
    end                          

    if name.to_s == 'text_right'      
      pre_width ||= 0                                                                                                                                                         
      pre_width += get_length(@line)
      target_width = args[1].to_i
      string = args[0]
      blank_number = target_width - pre_width - get_length(string)
      blank_number = blank_number / 12                     
      if blank_number < 0

      end
      @line << "#{ ' ' * blank_number}#{string}"
    end
                                                                                                                                                                                               
  end    

                 
  def is_single? char
    %w( 1 2 3 4 5 6 7 8 9 0 - = 
        q w e r t y u i o p [ ]
        a s d f g h j k l ; '
        z x c v b n m , . /
        _ + { } | : " < > ?
      ).include? char.downcase
  end

  def get_length string
    total_length = 0
    string.each_char do |c|
      if c == ' '
        total_length += 12
      else
        if is_single? c
          total_length += 12
        else
          total_length += 24
        end
      end
    end
    total_length
  end

end                                                                                                                                                                                            
       