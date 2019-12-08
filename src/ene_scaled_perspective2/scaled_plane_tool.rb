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

        # No need o pick a plane in parallel projection.
        unless Sketchup.active_model.active_view.camera.perspective?
          Dialog.show
          return
        end

        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def deactivate(view)
        super
        view.invalidate

        # As #draw is used kind of like a view observer, deactivating the tool
        # makes the dialog stop updating.
        Dialog.hide
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def draw(view)
        # No need o pick a plane in parallel projection.
        return unless view.camera.perspective?

        draw_plane if @ip_picked.valid? || @ip_pick.valid?

        @ip_pick.draw(view)
        @ip_picked.draw(view)

        view.tooltip = @ip_pick.tooltip

        # HACK: Probably not idiomatic but using Tool#draw as a view observer
        # to update dialog.
        Dialog.on_view_change if Dialog.visible?
      end

      def getExtents
        bb = Sketchup.active_model.bounds
        bb.add(plane_corners) if @ip_picked.valid? || @ip_pick.valid?

        bb
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onCancel(_reason, view)
        # No need o pick a plane in parallel projection.
        return unless view.camera.perspective?

        @ip_picked.clear
        ScaledPerspective.target = nil
        view.invalidate
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onLButtonDown(_flags, _x, _y, view)
        # No need o pick a plane in parallel projection.
        return unless view.camera.perspective?

        return unless @ip_pick.valid?

        @ip_picked.copy!(@ip_pick)
        ScaledPerspective.target = @ip_pick.position
        view.invalidate
        Dialog.show
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def onMouseMove(_flags, x, y, view)
        # No need o pick a plane in parallel projection.
        return unless view.camera.perspective?

        @ip_pick.pick(view, x, y)
        view.invalidate
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def resume(view)
        # No need o pick a plane in parallel projection.
        return unless view.camera.perspective?

        view.invalidate
        update_status_text
      end

      # @api
      # @see https://ruby.sketchup.com/Sketchup/Tool.html
      def suspend(view)
        # No need o pick a plane in parallel projection.
        return unless view.camera.perspective?

        view.invalidate
      end

      private

      def draw_plane
        # TODO: Draw fancy checkered pattern.
        view = Sketchup.active_model.active_view
        points = plane_corners
        view.drawing_color = COLOR
        view.draw(GL_QUADS, points)
      end

      def plane_corners
        view = Sketchup.active_model.active_view
        points = Array.new(4) do |i|
          Geom.intersect_line_plane(view.pickray(view.corner(i)), plane)
        end

        points.values_at(0, 1, 3, 2)
      end

      # Only valid if at leas one InputPoint is valid.
      # If a point has been selected, use it. Otherwise use point being picked.
      def plane
        view = Sketchup.active_model.active_view
        point = @ip_picked.valid? ? @ip_picked.position : @ip_pick.position

        [point, view.camera.direction]
      end

      def update_status_text
        Sketchup.status_text = "Pick plane for scale to apply at."
      end
    end
  end
end
