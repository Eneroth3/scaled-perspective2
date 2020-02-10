# frozen_string_literal: true

require "extensions.rb"

# Eneroth Extensions
module Eneroth
  # Eneroth Scaled Perspective 2
  module ScaledPerspective2
    path = __FILE__.dup.force_encoding("UTF-8")

    # Identifier for this extension.
    PLUGIN_ID = File.basename(path, ".*")

    # Root directory of this extension.
    PLUGIN_ROOT = File.join(File.dirname(path), PLUGIN_ID)

    # Extension object for this extension.
    EXTENSION = SketchupExtension.new(
      "Eneroth Scaled perspective²",
      File.join(PLUGIN_ROOT, "main")
    )

    EXTENSION.creator     = "Eneroth"
    EXTENSION.description = "Set up scaled perspectives."
    EXTENSION.version     = "1.0.1"
    EXTENSION.copyright   = "2020, #{EXTENSION.creator}"
    Sketchup.register_extension(EXTENSION, true)
  end
end
