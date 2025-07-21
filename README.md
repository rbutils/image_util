# ImageUtil

ImageUtil provides a minimal in-memory image container and a set of utilities for handling raw pixel data in Ruby. It is aimed at small scripts and tools that need to manipulate images without relying on heavy external dependencies.

Features include:

* Representation of images with arbitrary dimensions.
* Support for 8, 16 or 32 bit components and RGB or RGBA color values.
* A `Color` helper class capable of parsing numbers, arrays and HTML style strings.
* Conversion of an image to PAM or SIXEL for quick previews in compatible terminals.
* Built-in SIXEL encoder that works without ImageMagick.
* Convenience methods for iterating over pixel locations and setting values.
* Overlaying colors with the `+` operator which blends using the alpha channel.
* Automatic format detection when reading images from strings or files.
* Alternate pixel views for interpolated or rounded coordinates.

## Installation

ImageUtil is available on RubyGems:

```bash
gem install image_util
```

Alternatively add it to your `Gemfile`:

```ruby
gem "image_util"
```

Run `bundle install` afterwards.

You can also build and install the gem manually:

```bash
git clone https://github.com/rbutils/image_util.git
cd image_util
bundle exec rake install
```

## Usage

```ruby
require 'image_util'

# create a 4×4 image using 8‑bit RGBA colors
i = ImageUtil::Image.new(4, 4)

# set the top‑left pixel to red
i[0, 0] = ImageUtil::Color[255, 0, 0]

# display the image in a SIXEL-capable terminal
puts i.to_sixel
```

Images can also be iterated over or modified using ranges:

```ruby
# fill an area with blue
i[0..1, 0..1] = ImageUtil::Color['#0000ff']

# iterate over every pixel
i.each_pixel do |pixel|
  # pixel is an ImageUtil::Color instance
end

# paste one image into another
target = ImageUtil::Image.new(8, 8) { ImageUtil::Color[0] }
source = ImageUtil::Image.new(2, 2) { ImageUtil::Color[255, 0, 0, 128] }
target.paste!(source, 3, 3, respect_alpha: true)

# draw a diagonal line
i.draw_line!([0, 0], [3, 3], ImageUtil::Color['red'], view: ImageUtil::View::Rounded)
```

`View::Interpolated` provides subpixel access while `View::Rounded` snaps
coordinates to the nearest pixel. These views are useful for drawing
operations like the example above.

### Reading and Writing Images

```ruby
# detect format automatically when loading from a file
img = ImageUtil::Image.from_file("photo.png")

# save using a specific codec
img.to_file("out.jpg", :jpeg)

# convert directly to a string
data = img.to_string(:png)
```

### Filters

```ruby
# reduce palette to 32 colors
dithered = img.dither(32)

# composite two images without altering the originals
result = base.paste(other, 10, 10)

# apply a background color to an RGBA image
flattened = img.background(ImageUtil::Color[255, 255, 255])
```

### Working with Views

```ruby
# access using fractional coordinates
interp = img.view(ImageUtil::View::Interpolated)
interp[1.2, 2.8] = ImageUtil::Color[0, 0, 255]

# round coordinates instead
rounded = img.view(ImageUtil::View::Rounded)
color = rounded[1.6, 0.3]
```

### Codecs

ImageUtil includes a small registry of codecs for converting images to and from
common formats such as PNG, JPEG and SIXEL. The library ships with pure Ruby
encoders and FFI wrappers around `libpng`, `libturbojpeg` and `libsixel` when
available.

```ruby
png = ImageUtil::Codec.encode(:png, i)
back = ImageUtil::Codec.decode(:png, png)

File.open("img.pam", "wb") do |f|
  ImageUtil::Codec.encode_io(:pam, i, f)
end
```

You can read images from files without specifying the format:

```ruby
image = ImageUtil::Image.from_file("picture.jpg")
```

Use `ImageUtil::Codec.supported?(format)` to check if a particular format is
available. Unsupported formats raise `ImageUtil::Codec::UnsupportedFormatError`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`rake spec` to execute the tests. You can also run `bin/console` for an
interactive prompt for experimenting with the library.

## Contributing

Bug reports and pull requests are welcome on GitHub at
<https://github.com/rbutils/image_util>.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
