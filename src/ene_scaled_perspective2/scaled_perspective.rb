# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/vendor/scale"

    # Low level functionality for scaled perspectives.
    module ScaledPerspective
      # Scale that applies at a chosen position in view.
      @scale ||= Scale.new("1:100")

      # Point scale applies at.
      @target ||= nil

      # Get scale for view.
      #
      # @return [Scale]
      def self.scale
        @scale
      end

      # Set scale for view.
      #
      # @param scale [Scale]
      def self.scale=(scale)
        @scale = scale
      end

      # Get point scale applies at.
      #
      # @return [Geom::Point3d, nil]
      def self.target
        @target
      end

      # Set point scale applies at.
      #
      # @param target [Geom::Point3d, nil]
      def self.target=(target)
        @target = target
      end

      # Calculate distance image needs to be viewed at for perspective to be
      # correct.
      #
      # @return [Length, nil]
      def self.viewing_distance
        return unless @target

        (target_distance * @scale.factor).to_l
      end

      # Adjust camera position and field of view for perspective to be correct
      # at given viewing distance from image, while retaining the extents of the
      # target plane.
      #
      # @param viewing_distance [Length]
      def self.viewing_distance=(viewing_distance)
        multiply_plane_extents(self.viewing_distance / viewing_distance)
        self.target_distance = viewing_distance / @scale.factor
      end

      # Calculate height exported image must have for scale to apply.
      #
      # @return [Length]
      def self.image_height
        # REVIEW: Change to image_dimension and add an
        # imagde_dimension_is_height? getter to account for views where
        # fov_is_height? ?

        (target_plane_height * @scale.factor).to_l
      end

      # Adjust field of view for a new size of the scaled view, while retaining
      # the scale and viewing distance.
      #
      # @param image_height [Length]
      def self.image_height=(image_height)
        multiply_plane_extents(image_height / self.image_height)
      end

      # Private

      def self.multiply_plane_extents(factor)
        camera.fov =
          Math.atan(Math.tan(camera.fov.degrees / 2) * factor).radians * 2
      end
      private_class_method :multiply_plane_extents

      def self.target_plane_height
        # REVIEW: Currently width if fov_is_height? is false.
        # TODO: Support parallel projection.
        target_distance * Math.tan(camera.fov.degrees / 2) * 2
      end
      private_class_method :target_plane_height

      def self.target_distance
        camera.eye.distance_to_plane(target_plane)
      end
      private_class_method :target_distance

      def self.target_distance=(target_distance)
        eye = camera.eye.project_to_plane(target_plane)
                    .offset(camera.direction.reverse, target_distance)

        camera.set(eye, eye.offset(camera.direction), camera.up)
      end
      private_class_method :target_distance=

      def self.target_plane
        [@target, camera.direction]
      end
      private_class_method :target_plane

      def self.camera
        Sketchup.active_model.active_view.camera
      end
      private_class_method :camera
    end
  end
end
