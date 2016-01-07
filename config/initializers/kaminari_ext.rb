module Kaminari
  module Helpers
    class Paginator
      def render(&block)
        instance_eval(&block) if @options[:total_pages] >= 1
        @output_buffer
      end
    end
  end
end