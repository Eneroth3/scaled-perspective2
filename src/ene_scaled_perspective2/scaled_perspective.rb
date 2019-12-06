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

      # Get point scale applies at. May be nil.
      #
      # @return [Geom::Point3d, nil]
      def self.target
        @target
      end

      # Set point scale applies at. May be nil.
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
        return unless can_set_viewing_distance?

        (target_distance * @scale.factor).to_l
      end

      # Adjust camera position and field of view for perspective to be correct
      # at given viewing distance from image, while retaining the extents of the
      # target plane.
      #
      # @param viewing_distance [Length]
      def self.viewing_distance=(viewing_distance)
        raise "Cannot be set in current state." unless can_set_viewing_distance?

        multiply_plane_extents(self.viewing_distance / viewing_distance)
        self.target_distance = viewing_distance / @scale.factor
      end

      # Calculate height exported image must have for scale to apply.
      #
      # @return [Length, nil]
      def self.image_height
        return unless can_set_image_height?

        (target_plane_height * @scale.factor).to_l
      end

      # Adjust field of view for a new size of the scaled view, while retaining
      # the scale and viewing distance.
      #
      # @param image_height [Length]
      def self.image_height=(image_height)
        raise "Cannot be set in current state." unless can_set_image_height?

        multiply_plane_extents(image_height / self.image_height)
      end

      # Check whether viewing distance can be set. In parallel projection or
      # without a defined target the viewing distance cannot be set.
      #
      # @return [Boolean]
      def self.can_set_viewing_distance?
        camera.perspective? && !!@target
      end

      # Check whether image height can be set. In perspective mode without a
      # defined target the image height cannot be set.
      #
      # @return [Boolean]
      def self.can_set_image_height?
        !camera.perspective? || !!@target
      end

      # Private

      def self.multiply_plane_extents(factor)
        if camera.perspective?
          camera.fov =
            Math.atan(Math.tan(camera.fov.degrees / 2) * factor).radians * 2
        else
          camera.height *= factor
        end
      end
      private_class_method :multiply_plane_extents

      def self.target_plane_height
        if camera.perspective?
          # TODO: When fov_is_height? is false, corerct for it.
          target_distance * Math.tan(camera.fov.degrees / 2) * 2
        else
          camera.height
        end
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
