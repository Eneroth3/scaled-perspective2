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

        # TODO: Add Mac support (uses different exporter settings).
        # TODO: Rely on style for extensions, profiles etc.
        model.export(
          path,
          height_units: Length::Millimeter, # TODO: Inches if imperial.
          window_height: ScaledPerspective.image_height.mm # FIXME: Not honored. Instead value from last export is used.
        )

        # Some kind of feedback after export.
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
    end
  end
end
