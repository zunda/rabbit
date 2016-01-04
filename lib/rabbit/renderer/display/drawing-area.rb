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

        def initialize(*args)
          super
          trace_var :@size_dirty, proc{|v|
            puts "@size_dirty is now #{v.inspect} at @{caller[0]}"
          }
          trace_var :@size, proc{|v|
            puts "@size is now #{v.inspect} at @{caller[0]}"
          }
        end

        private
        def init_color
          super
          init_engine_color
        end
      end
    end
  end
end
