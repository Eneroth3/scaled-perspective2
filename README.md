Set up scaled perspective by selecting a plane for scale to apply at.
The plane is perpendicular to the camera direction,
so typically you start by aligning the view to a section plane or a face
where you want the scale to apply.

The extension can export the view as PDF or send it to LayOut.
You can also use SketchUp's native 2D Graphic Export or a render the view,
but then you need to manually size the resulting image to the correct height
for the scale to apply.

Supports scales such as 1:100, 1% or 1"=100".

[Eneroth Precise Pan Tool](https://extensions.sketchup.com/pl/content/eneroth-precise-pan-tool)
may be used to control the exact vanishing point of the perspective,
e.g. when producing consistent views.

Activated from **Extensions > Eneroth Scaled perspective²**.

Source code available at [GitHub](https://github.com/Eneroth3/scaled-perspective2).

## Known Issues

On Mac the PDF isn't exported to scale but to an arbitrary size.
Instead you can use SketchUp's native PDF exporter and manually set image height
in the export options to the same height Eneroth Scaled Perspectives² uses.
