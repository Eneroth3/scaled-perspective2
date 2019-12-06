# frozen_string_literal: true

require "json"

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/scaled_perspective"

    # Dialog for handling scaled perspective settings.
    module Dialog
      # Show dialog.
      def self.show
        if visible?
          @dialog.bring_to_front
        else
          create_dialog unless @dialog
          @dialog.set_url("#{PLUGIN_ROOT}/dialog.html")
          attach_callbacks
          @dialog.show

          ### Observers.observe_app
          ### @dialog.set_on_closed { Observers.unobserve_app }
        end
      end

      # Hide dialog.
      def self.hide
        @dialog.close
      end

      # Check whether dialog is visible.
      #
      # @return [Boolean]
      def self.visible?
        @dialog && @dialog.visible?
      end

      # Toggle visibility of dialog.
      def self.toggle
        visible? ? hide : show
      end

      # Get SketchUp UI command state for dialog visibility state.
      #
      # @return [MF_CHECKED, MF_UNCHECKED]
      def self.command_state
        visible? ? MF_CHECKED : MF_UNCHECKED
      end

      # Expected to be called when view changes.
      def self.on_view_change
        update_dialog
      end

      # Private

      def self.attach_callbacks
        @dialog.add_action_callback("ready") { update_dialog }
        @dialog.add_action_callback("scale") { |_, v| self.scale = v }
        @dialog.add_action_callback("viewDistance") { |_, v| self.viewing_distance = v }
        @dialog.add_action_callback("imageHeight") { |_, v| self.image_height = v }
      end
      private_class_method :attach_callbacks

      def self.create_dialog
        @dialog = UI::HtmlDialog.new(
          dialog_title:    EXTENSION.name,
          preferences_key: name, # Full module name
          resizable:       false,
          style:           UI::HtmlDialog::STYLE_DIALOG,
          width:           320,
          height:          220,
          left:            200,
          top:             100
        )
      end
      private_class_method :create_dialog

      # Update all dialog fields.
      # Done on show or when view changes.
      def self.update_dialog
        @dialog.execute_script(
          "scaleField.value = #{ScaledPerspective.scale.to_s.to_json};"\
          "viewDistanceField.value = "\
          "#{ScaledPerspective.viewing_distance.to_s.to_json};"\
          "viewDistanceField.disabled = "\
          "#{!ScaledPerspective.can_set_viewing_distance?};"\
          "imageHeightField.value = "\
          "#{ScaledPerspective.image_height.to_s.to_json};"\
          "imageHeightField.disabled = "\
          "#{!ScaledPerspective.can_set_image_height?};"
        )
      end
      private_class_method :update_dialog

      def self.scale=(scale)
        # TODO: Show red border on field if invalid.
        scale = Scale.new(scale)
        return unless scale.valid?
        ScaledPerspective.scale = scale

        @dialog.execute_script(
          "viewDistanceField.value = "\
          "#{ScaledPerspective.viewing_distance.to_s.to_json};"\
          "imageHeightField.value = "\
          "#{ScaledPerspective.image_height.to_s.to_json};"
        )
      end
      private_class_method :scale=

      def self.viewing_distance=(viewing_distance)
        # TODO: Show red border on field if invalid.
        ScaledPerspective.viewing_distance = viewing_distance.to_l

        @dialog.execute_script(
          "imageHeightField.value = "\
          "#{ScaledPerspective.image_height.to_s.to_json};"
        )
      end
      private_class_method :scale=

      def self.image_height=(image_height)
        # TODO: Show red border on field if invalid.
        ScaledPerspective.image_height = image_height.to_l
      end
      private_class_method :image_height=
    end
  end
end
