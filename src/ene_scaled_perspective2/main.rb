# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/scaled_plane_tool"

    # Reload extension.
    #
    # @param clear_console [Boolean] Whether console should be cleared.
    # @param undo [Boolean] Whether last oration should be undone.
    #
    # @return [void]
    def self.reload(clear_console = true, undo = false)
      # Hide warnings for already defined constants.
      verbose = $VERBOSE
      $VERBOSE = nil
      Dir.glob(File.join(PLUGIN_ROOT, "**/*.{rb,rbe}")).each { |f| load(f) }
      $VERBOSE = verbose

      # Use a timer to make call to method itself register to console.
      # Otherwise the user cannot use up arrow to repeat command.
      UI.start_timer(0) { SKETCHUP_CONSOLE.clear } if clear_console

      Sketchup.undo if undo

      nil
    end

    unless @loaded
      @loaded = true

      menu = UI.menu("Plugins")
      toolbar = UI::Toolbar.new(EXTENSION.name)

      cmd = UI::Command.new(EXTENSION.name) { ScaledPlaneTool.activate }
      cmd.set_validation_proc { ScaledPlaneTool.command_state }
      cmd.tooltip = EXTENSION.name
      cmd.status_bar_text = EXTENSION.description
      cmd.large_icon = cmd.small_icon = "#{PLUGIN_ROOT}/images/icon.svg"
      menu.add_item(cmd)
      toolbar.add_item(cmd)

      toolbar.restore
    end
  end
end
