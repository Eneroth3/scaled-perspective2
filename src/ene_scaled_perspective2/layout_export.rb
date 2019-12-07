# frozen_string_literal: true

module Eneroth
  module ScaledPerspective2
    Sketchup.require "#{PLUGIN_ROOT}/scaled_perspective"

    # Export scaled perspective to LayOut.
    module LayoutExport
      # Message asking user to save model.
      MSG_CONFIRM_SAVE =
        "Your model will be saved before sending it to LayOut.\n\n"\
        "Continue?".freeze

      # Send current view to a LayOut document.
      def self.export
        model = Sketchup.active_model

        # Saving over the user's file without consent would be unacceptable.
        return unless UI.messagebox(MSG_CONFIRM_SAVE, MB_YESNO) == IDYES

        # Gather all user input before carrying out any action, so no changes
        # are made if the user cancels.
        lo_path = prompt_save_path
        return unless lo_path

        scene_name = "#{ScaledPerspective.scale} View"
        scene = model.pages.add(unique_scene_name(scene_name, model))

        # TODO: If not already saved, show a save panel (but before LO
        # save panel and instead of the prompt).
        model.save

        doc = Layout::Document.new("#{PLUGIN_ROOT}/template.layout")
        viewport = Layout::SketchUpModel.new(model.path, image_bounds(doc))
        # Scene indexing starts at 1 in LayOut (with 0 being last saved view).
        # See https://github.com/SketchUp/api-issue-tracker/issues/399
        viewport.current_scene = model.pages.to_a.index(scene) + 1
        viewport.preserve_scale_on_resize = true
        doc.add_entity(viewport, doc.layers.active, doc.pages.first)

        point2d = viewport.model_to_paper_point(ScaledPerspective.target)
        add_label(doc, ScaledPerspective.scale.to_s, point2d)

        doc.save(lo_path)
        open_file(lo_path)

        Sketchup.status_text = "Opening LayOut..."
      end

      # Private

      def self.prompt_save_path
        model = Sketchup.active_model
        filename = "#{File.basename(model.path, '.skp')}.layout"
        dirname = File.dirname(model.path)

        path = UI.savepanel("Create LayOut Document", dirname, filename)
        return unless path

        path += ".layout" unless path.end_with?(".layout")

        path
      end
      private_class_method :prompt_save_path

      def self.unique_scene_name(basename, model)
        return basename unless model.pages[basename]

        count = 1
        loop do
          name = "#{basename} #{count}"
          return name unless model.pages[name]

          count += 1
        end
      end
      private_class_method :unique_scene_name

      def self.image_bounds(doc)
        model = Sketchup.active_model

        height = ScaledPerspective.image_height
        width = height / model.active_view.vpheight * model.active_view.vpwidth
        left = doc.page_info.width / 2 - width / 2
        top = doc.page_info.height / 2 - height / 2

        Geom::Bounds2d.new(left, top, width, height)
      end
      private_class_method :image_bounds

      def self.add_label(doc, text, position)
        label = Layout::Label.new(
          text,
          Layout::Label::LEADER_LINE_TYPE_SINGLE_SEGMENT,
          position,
          position.offset([20.mm, 20.mm]),
          Layout::FormattedText::ANCHOR_TYPE_TOP_LEFT
        )

        style = label.style
        sub_style = style.get_sub_style(Layout::Style::LABEL_LEADER_LINE)
        sub_style.start_arrow_type = Layout::Style::ARROW_FILLED_TRIANGLE
        sub_style.start_arrow_size = 1
        sub_style.end_arrow_size = 1
        style.set_sub_style(Layout::Style::LABEL_LEADER_LINE, sub_style)
        label.style = style

        doc.add_entity(label, doc.layers.active, doc.pages.first)
      end
      private_class_method :add_label

      # Open file in the default program.
      #
      # @param path [String]
      def self.open_file(path)
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
