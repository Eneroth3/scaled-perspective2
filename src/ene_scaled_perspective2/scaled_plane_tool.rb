# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/tool"
    Sketchup.require "#{PLUGIN_ROOT}/dialog"

    # Tool for picking plane to apply scale to.
    class ScaledPlaneTool < Tool
      # Color to draw plane with.
      COLOR = Sketchup::Color.new(127, 127, 127, 0.6)

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def activate
        super

        @ip_pick = Sketchup::InputPoint.new
        @ip_picked = Sketchup::InputPoint.new

        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def deactivate(view)
        super
        view.invalidate
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def draw(view)
        if @ip_picked.valid?
          draw_plane(@ip_picked.position)
        elsif @ip_pick.valid?
          draw_plane(@ip_pick.position)
        end

        @ip_pick.draw(view)
        @ip_picked.draw(view)

        view.tooltip = @ip_pick.tooltip

        # HACK: Probably not idiomatic but using Tool#draw as a view observer
        # to update dialog.
        # TODO: Close dialog if tool is deactivated? (as it is used as observer)
        # Deactivate tool when dialog closes.
        Dialog.on_view_change if Dialog.visible?
      end

      # TODO: Add getExtents.

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onCancel(_reason, view)
        @ip_picked.clear
        ScaledPerspective.target = nil
        view.invalidate
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onLButtonDown(_flags, _x, _y, view)
        return unless @ip_pick.valid?

        @ip_picked.copy!(@ip_pick)
        ScaledPerspective.target = @ip_pick.position
        view.invalidate
        Dialog.show
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onMouseMove(_flags, x, y, view)
        @ip_pick.pick(view, x, y)
        view.invalidate
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def resume(view)
        view.invalidate
        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def suspend(view)
        view.invalidate
      end

      private

      def draw_plane(point)
        # TODO: Draw fancy checkered pattern.
        view = Sketchup.active_model.active_view
        plane = [point, view.camera.direction]
        points = Array.new(4) do |i|
          Geom.intersect_line_plane(view.pickray(view.corner(i)), plane)
        end
        points[0], points[1] = points[1], points[0]

        view.drawing_color = COLOR
        view.draw(GL_QUADS, points)
      end

      def update_status_text
        Sketchup.status_text = "Pick plane for scale to apply at."
      end
    end
  end
end
