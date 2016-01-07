class BookTimeRange < ActiveRecord::Base
	belongs_to :book_rule
	# attr_accessible :end_time, :start_time, :status
	before_save :order_time

	def show_time 
		"#{start_time} - #{end_time}"
	end

	def include_time_now
		start_clock, start_minute = self.start_time.split(":")
		end_clock, end_minute     = self.end_time.split(":")
		now_int = parse_time_to_integer(Time.now.strftime('%H:%M'))
		if now_int <=  "#{end_clock}#{end_minute}".to_i && now_int >= "#{start_clock}#{start_minute}".to_i
			return true
		end
		return false
	end

	def generate_order_time is_full
		ret = Array.new

		if self.start_time && self.end_time

		else
			self.start_time = "00:00"
			self.end_time   = "23:59"
		end
		
		start_clock, start_minute = self.start_time.split(":")
		end_clock, end_minute     = self.end_time.split(":")

		start_clock.upto(end_clock) { |x| 

			if  parse_time_to_integer("#{x}:00") >= parse_time_to_integer(start_time) && parse_time_to_integer("#{x}:00") <= parse_time_to_integer(end_time)
				ret << "#{x}:00"
			end
			if  parse_time_to_integer("#{x}:15") >= parse_time_to_integer(start_time) && parse_time_to_integer("#{x}:15") <= parse_time_to_integer(end_time)
				ret << "#{x}:15"
			end
			if  parse_time_to_integer("#{x}:30") >= parse_time_to_integer(start_time) && parse_time_to_integer("#{x}:30") <= parse_time_to_integer(end_time)
				ret << "#{x}:30"
			end
			if  parse_time_to_integer("#{x}:45") >= parse_time_to_integer(start_time) && parse_time_to_integer("#{x}:45") <= parse_time_to_integer(end_time)
				ret << "#{x}:45"
			end
		}

	

		if is_full

		else
			ret.delete_if {|x| 
				parse_time_to_integer(x) <= parse_time_to_integer(Time.now.strftime('%H:%M'))
			}
		end

		ret = ret.uniq

		# if ret && ret.length > 0 
		# 	if (ret[0].split(":")[1].to_i - start_minute.to_i) < 15
		# 		ret.delete_at(0)
		# 	end
		# end
		ret
	end

	private

	def order_time
		if should_switch_time_string(self.start_time, self.end_time)
			self.end_time, self.start_time = self.start_time, self.end_time
		end
	end

	def should_switch_time_string(s_time, e_time)
		ret = false
		s = s_time.split(":")
		d = e_time.split(":")
		if s[0].to_i > d[0].to_i
			ret = true
		elsif (s[0].to_i == d[0].to_i && s[1].to_i >= d[1].to_i)
			ret = true
		end
		ret
	end

	def parse_time_to_integer time # e.g 12:34
		time.split(":").join.to_i
	end

end
