# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/scaled_perspective"

    # Export scaled perspective to PDF.
    module PDFExport
      # Export current view to a pdf.
      def self.export
        model = Sketchup.active_model
        path = pdf_save_panel(model.path)
        return unless path

        model.export(
          path,
          Sketchup.platform == :platform_win ? win_settings : mac_settings
        )

        open_file(path)
      end

      # Private

      def self.pdf_save_panel(su_path)
        filename = "#{File.basename(su_path, '.skp')}.pdf"
        dirname = File.dirname(su_path)

        path = UI.savepanel("Export PDF", dirname, filename)
        return unless path

        path.end_with?(".pdf") ? path : "#{path}.pdf"
      end
      private_class_method :pdf_save_panel

      def self.win_settings
        # REVIEW: Set profile, sections etc properties explicitly from model
        # style instead of using the exporter's defaults?
        {
          # Exporter appears to only support inches
          # (or use other identifiers that these constants).
          height_units:  Length::Inches,
          # Exporter appears to only accept floats.
          window_height: ScaledPerspective.image_height.to_f
        }
      end
      private_class_method :win_settings

      def self.mac_settings
        # Not tested. Assuming dimensions are in inches and width is set to
        # match viewport aspect ratio.
        # See https://forums.sketchup.com/t/does-the-pdf-exporter-even-accept-
        #     settings/110582/3
        {
          imageHeight: 200.mm.to_f
          ### imageWidth: 200.mm.to_f
        }
      end
      private_class_method :mac_settings

      # Open file in the default program.
      #
      # @param path [String]
      def self.open_file(path)
        # TODO: Copied from LayoutExport. Define only once!
        if Sketchup.platform == :platform_win
          UI.openURL(path)
        else
          system("open #{path.inspect}")
        end
      end
      private_class_method :open_file
    end
  end
end
