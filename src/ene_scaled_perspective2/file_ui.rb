# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    # Functionality related to files and user interface.
    module FileUI
      # Assure a path ends with a desired extension.
      #
      # @param path [String]
      # @param extension [String]
      #
      # @return [String]
      def self.assure_extension(path, extension)
        return path if path.end_with?(extension)

        "#{path}#{extension}"
      end

      # Open file in the default program.
      #
      # @param path [String]
      def self.open(path)
        if Sketchup.platform == :platform_win
          UI.openURL(path)
        else
          system("open #{path.inspect}")
        end
      end
    end
  end
end
