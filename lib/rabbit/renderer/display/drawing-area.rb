require 'rabbit/renderer/engine'
require 'rabbit/renderer/display/drawing-area-base'

module Rabbit
  module Renderer
    module Display
      class DrawingArea
        include Renderer::Engine::Cairo
        include DrawingAreaBase

        class << self
          def priority
            100
          end
        end

        def size_dirty=(x)
          trace_ivar_set(:@size_dirty, x)
        end

        private
        def init_color
          super
          init_engine_color
        end

        def trace_ivar_set(ivar, x)
          puts "#{ivar} is set #{x.inspect} for #{self.class} at #{caller[1]} called from #{caller[2]}"
          instance_variable_set(ivar, x)
        end
      end
    end
  end
end
