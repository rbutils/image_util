## Unreleased
- Replace Dither implementation with a much faster one
- Terminal detection for graphic protocols
- Support Kitty graphics protocol
- Rename `color_length` to a more appropriate name `channels`
- Remove redundant `encode_io` and `decode_io` implementations

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
