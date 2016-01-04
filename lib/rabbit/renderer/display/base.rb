require "rabbit/renderer/base"
require "rabbit/renderer/display/hook-handler"

module Rabbit
  module Renderer
    module Display
      module Base
        include Renderer::Base
        include HookHandler

        def initialize(*args, &block)
          @drawable = nil
          @size = nil
          self.size_dirty = true
          @default_size_ratio = nil
          @size_ratio = nil
          @configure_event_signal_id = nil
          @window_state_event_signal_id = nil
          super
        end

        def width
          refresh_size
          if @size
            @size.logical_width
          else
            nil
          end
        end

        def height
          refresh_size
          if @size
            @size.logical_height
          else
            nil
          end
        end

        def size
          refresh_size
          @size
        end

        def redraw
          widget.queue_draw
        end

        def attach_to(window, container=nil)
          @window = window
          @container = container || @window

          set_configure_event
          set_window_state_event
        end

        def detach
          unless @window.destroyed?
            if @configure_event_signal_id
              @window.signal_handler_disconnect(@configure_event_signal_id)
              @configure_event_signal_id = nil
            end
            if @window_state_event_signal_id
              @window.signal_handler_disconnect(@window_state_event_signal_id)
              @window_state_event_signal_id = nil
            end
          end

          @window = nil
          @container = nil
        end

        def toggle_whiteout
          super
          update_menu
        end

        def toggle_blackout
          super
          update_menu
        end

        def make_layout(text)
          attrs, text = Pango.parse_markup(text)
          layout = create_pango_layout(text)
          layout.set_attributes(attrs)
          layout
        end

        def create_pango_context
          context = widget.create_pango_context
          set_font_resolution(context)
          context
        end

        def create_pango_layout(text)
          layout = widget.create_pango_layout(text)
          set_font_resolution(layout.context)
          layout
        end

        def update_title
          @canvas.update_title(@canvas.slide_title)
        end

        def draw_slide(slide, simulation)
          set_size_ratio(slide.size_ratio || @default_size_ratio)

          if simulation
            super
          else
            save_context do
              translate_context(@size.logical_margin_left,
                                @size.logical_margin_top)
              super
            end

            unless @size.have_logical_margin?
              return
            end

            margin_background = make_color("black")
            if @size.have_logical_margin_x?
              draw_rectangle(true,
                             0,
                             0,
                             @size.logical_margin_left,
                             @size.real_height,
                             margin_background)
              draw_rectangle(true,
                             @size.real_width - @size.logical_margin_right,
                             0,
                             @size.logical_margin_right,
                             @size.real_height,
                             margin_background)
            end
            if @size.have_logical_margin_y?
              draw_rectangle(true,
                             0,
                             0,
                             @size.real_width,
                             @size.logical_margin_top,
                             margin_background)
              draw_rectangle(true,
                             0,
                             @size.real_height - @size.logical_margin_bottom,
                             @size.real_width,
                             @size.logical_margin_bottom,
                             margin_background)
            end
          end
        end

        private
        def set_drawable(drawable)
          @drawable = drawable
          w = @drawable.width
          h = @drawable.height
          @default_size_ratio = w.to_f / h.to_f
          @size_ratio = @default_size_ratio
          set_size(w, h)
        end

        def set_size(w, h)
          @size = Size.new(w, h, @size_ratio)
        end

        def set_size_ratio(ratio)
          return if @size.ratio == ratio

          w = @size.real_width
          h = @size.real_height
          @size_ratio = ratio
          @size = Size.new(w, h, @size_ratio)
        end

        def refresh_size
if !@size_dirty and @drawable.width > 800 and @drawable.height > 600
p [__method__, self.class, @drawable.width, @drawable.height]
end
          return unless @size_dirty

          @size = Size.new(@drawable.width,
                           @drawable.height,
                           @size.ratio)
          self.size_dirty = false
        end

        def set_configure_event
          id = @window.signal_connect("configure_event") do |widget, event|
puts "signal_connect: configure_event #{self.class} #{event.width} #{event.height} #{__FILE__}"
            configured(event.x, event.y, event.width, event.height)
            false
          end
          @configure_event_signal_id = id
        end

        def configured(x, y, w, h)
puts "configured: #{x} #{y} #{w} #{h}"
          self.size_dirty = true
        end

        def set_window_state_event
          id = @window.signal_connect("window_state_event") do |widget, event|
puts "signal_connect: window_state_event #{__FILE__}"
            window_state_changed(event)
            false
          end
          @window_state_event_signal_id = id
        end

        def window_state_changed(event)
          self.size_dirty = true
        end

        def queue_draw
          widget.queue_draw
        end
      end
    end
  end
end
