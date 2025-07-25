## Unreleased
- Rename `dither!` to `palette_reduce!`
- Rename `#set_each_pixel_by_location` to `#set_each_pixel_by_location!` since it's mutable
- Rename `color_length` to a more appropriate name `channels`
- Thor based CLI with a `support` command that lists codec support, default
  format handlers and detected terminal features
- Replace `palette_reduce!` implementation with a much faster one
- Terminal detection for graphic protocols
- Support Kitty graphics protocol
- Transform filter with rotate and flip operations
- Fallback PNG codec via chunky_png
- ImageMagick codec can now read and write `gif` and `apng` including animations
- Redimension filter to change image dimensions
- Sixel and Kitty codecs accept 1D images
- `Pam.encode` no longer accepts `fill_to`; Sixel codecs pad images using the
  redimension filter
- Add `BitmapFont` with a sample hand crafted font, add `bitmap_text` generator.
- `Color#*` can now accept another `Color` to multiply channels
- Add `Colors` filter with `color_multiply!` and alias `*`
- `bitmap_text` accepts multiline strings and supports colorization
- `bitmap_text` supports left, center and right alignment
- Add `BitmapText` filter for overlaying text onto images
- `bitmap_text` filter now always respects an alpha channel when pasting text
- Open ImageMagick codec pipes in binary mode for Windows compatibility
- Format inference from file extension in `Image#to_file`
- ImageMagick codec now reads PAM frames using the Pam codec
- Force 8-bit output when decoding through ImageMagick to avoid 1-bit images on Windows

## [0.2.0] - 2025-07-21
- Ruby Sixel encoder now sets pixel aspect ratio metadata to display correctly in Windows Terminal
- Support for all CSS color names
- Range assignments with images now resize the image before pasting
- Circle drawing filter
- ImageMagick codec can encode and decode `png`, `jpeg` and `sixel`

## [0.1.0] - 2025-07-21

- Initial release
- Drop support for Ruby 3.1
- Native SIXEL encoder
- Background filter
- Format auto-detection using magic numbers
- Faster 1D paste using direct buffer copy
- Libsixel encoder with default palette
- JPEG support via libturbojpeg
- PNG support via libpng
- Dither filter for palette reduction
- Paste and Draw filters for compositing and drawing
- Rounded and interpolated pixel views
- `Image#view` helper for custom access
