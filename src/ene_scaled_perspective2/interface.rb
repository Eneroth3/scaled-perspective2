# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/vendor/scale"
    ### Sketchup.require "#{PLUGIN_ROOT}/observers" # TODO: Set up view observer.

    # User interface for handling scaled perspectives.
    module Interface
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
          height:          260,
          left:            200,
          top:             100
        )
      end
      private_class_method :create_dialog

      def self.update_dialog
        @dialog.execute_script("") # TODO: Set values.
      end
      private_class_method :update_dialog
    end
  end
end
