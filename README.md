# ImageUtil

ImageUtil is a lightweight Ruby library focused on manipulating images directly in memory. Its primary goal is to help scripts visualize data right in the terminal by supporting SIXEL output alongside common image formats. The API is still evolving and should be considered unstable until version 1.0.

## Creating an Image

```ruby
require 'image_util'

# 40×40 RGBA image
img = ImageUtil::Image.new(40, 40)
```

An optional block receives pixel coordinates and should return something that can be converted to a color. Dimensions of more than two axes are supported.

```ruby
img = ImageUtil::Image.new(4, 4) { |x, y| ImageUtil::Color[x * 64, y * 64, 0] }
```

## Color Values

`ImageUtil::Color.from` accepts several inputs:

- Another `Color` instance
- Arrays of numeric components (`[r, g, b]` or `[r, g, b, a]`)
- Numbers (used for all RGB channels)
- Symbols or strings containing basic color names (`:red`, `'blue'`)
- Hex strings like `'#abc'`, `'#aabbcc'` or `'#rrggbbaa'`

Values outside `0..255` are clamped and floats are interpreted as fractions of 255.

Note that whenever the library expects a color, it may be given in any form accepted by this function (also available as `ImageUtil::Color[]`).

## Pixel Access

Pixels can be accessed with integer coordinates or ranges. Subimages are returned when ranges are used.

```ruby
img[0, 0] = '#ff0000'
patch = img[0..1, 0..1]
```

Iteration helpers operate on arbitrary ranges:

```ruby
img.each_pixel { |pixel| puts pixel.inspect }
```

## Filters

The main `Image` class mixes in several mutating filters, all of which also provide non-bang versions that return new images.

### Background

```ruby
flattened = img.background('#ffffff')
```

### Paste

```ruby
base.paste!(overlay, 10, 5, respect_alpha: true)
```

### Draw

```ruby
img.draw_line!([0, 0], [39, 39], :red, view: ImageUtil::View::Rounded)
```

### Resize

```ruby
thumbnail = img.resize(20, 20)
```

### Dither

```ruby
reduced = img.dither(16)
```

## SIXEL Output

Images can be previewed in compatible terminals:

```ruby
puts img.to_sixel
```


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
