# ImageUtil

ImageUtil provides a minimal in-memory image container and a set of utilities for handling raw pixel data in Ruby. It is aimed at small scripts and tools that need to manipulate images without relying on heavy external dependencies.

Features include:

* Representation of images with arbitrary dimensions.
* Support for 8, 16 or 32 bit components and RGB or RGBA color values.
* A `Color` helper class capable of parsing numbers, arrays and HTML style strings.
* Conversion of an image to PAM or SIXEL for quick previews in compatible terminals.
* Convenience methods for iterating over pixel locations and setting values.
* Overlaying colors with the `+` operator which blends using the alpha channel.

## Installation

The gem is not yet published on RubyGems. To use it, add the repository to your `Gemfile`:

```ruby
gem 'image_util', git: 'https://github.com/rbutils/image_util.git'
```

Then run `bundle install`.

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
```

### Codecs

ImageUtil includes a small registry of codecs for converting images to and from
common formats.

```ruby
png = ImageUtil::Codec.encode(:png, i)
back = ImageUtil::Codec.decode(:png, png)

File.open("img.pam", "wb") do |f|
  ImageUtil::Codec.encode_io(:pam, i, f)
end
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
