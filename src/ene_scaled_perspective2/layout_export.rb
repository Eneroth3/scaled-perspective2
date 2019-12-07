# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/scaled_perspective"

    # Export scaled perspective to LayOut.
    module LayoutExport
      # Message asking user to save model.
      SAVE_MSG =
        "Your model must be saved before sending it to LayOut.\n\n"\
        "Do you want to save your model now?".freeze

      def self.export
        model = Sketchup.active_model
        return unless prompt_save?

        lo_path = prompt_save_path
        return unless lo_path

        # HACK: Set up dummy scene to reference from LO.
        # When API supports it, the camera should be written directly to the
        # LayOut viewport without littering the document.
        #
        # Don't set any particular name to the scene as the user can rename it.
        # TODO: Confirm LO still references the right scene (PID based).
        scene = model.pages.add

        # TODO: If not already saved, show a save panel.
        # FIXME: If model was already saved, then the newly created scene edits
        # it and it is saved without the user's consent to overwrite file.
        model.save

        # TODO: Base on template with reasonable defaults (mm, A4, grid etc).
        doc = Layout::Document.new
        # TODO: Set up bounds based on Scale.image_height and SU viewport ratio.
        # Center on page. How large is page btw?
        bounds = Geom::Bounds2d.new(1, 1, 3, 3)
        viewport = Layout::SketchUpModel.new(model.path, bounds)
        # Scene indexing starts at 1 in LayOut (with 9 being last saved view).
        # TODO: File documentation issue that 1 is the first scene.
        viewport.current_scene = model.pages.to_a.index(scene) +1
        viewport.preserve_scale_on_resize = true
        doc.add_entity(viewport, doc.layers.first, doc.pages.first)

        # TODO: Add text pointing where scale applies.
        # viewport.model_to_paper_point(model_point)

        doc.save(lo_path)
        UI.openURL(lo_path)
        # TODO: Test if it can be opened when there is already an opened document.
        # TODO: Test on Mac.

        Sketchup.status_text = "Opening LayOut..."
      end

      # Private
      # TODO: Mark as private

      def self.prompt_save?
        model = Sketchup.active_model
        return true if !model.path.empty? && !model.modified?

        UI.messagebox(SAVE_MSG, MB_YESNO) == IDYES
      end

      def self.prompt_save_path
        model = Sketchup.active_model
        filename = "#{File.basename(model.path, '.skp')}.layout"
        dirname = File.dirname(model.path)

        path = UI.savepanel("Create LayOut Document", dirname, filename)
        return unless path

        path += ".layout" unless path.end_with?(".layout")

        path
      end
    end
  end
end
