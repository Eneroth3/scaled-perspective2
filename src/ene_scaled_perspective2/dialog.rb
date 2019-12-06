# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/scaled_perspective"
    ### Sketchup.require "#{PLUGIN_ROOT}/observers" # TODO: Set up view observer.

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
        # TODO: Add other callbacks.
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

      # TODO: Let user enter values.
      # When entering value in one field, don't update and overwrite as user is
      # writing. Only update other fields.
      # User feedback when invalid values are entered.

      def self.update_dialog
        @dialog.execute_script(
          "scale = #{ScaledPerspective.scale.to_s.to_json};"\
          "viewDistance = #{ScaledPerspective.viewing_distance.to_s.to_json};"\
          "imageHeight = #{ScaledPerspective.image_height.to_s.to_json};"\
          "canSetViewDistance =#{ScaledPerspective.can_set_viewing_distance?};"\
          "canSetImageHeight = #{ScaledPerspective.can_set_image_height?};"\
          "updateForm();"
        )
      end
      private_class_method :update_dialog
    end
  end
end
