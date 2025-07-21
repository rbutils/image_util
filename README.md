# ImageUtil::Image

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

## Example

The following gradient is generated with a single line drawn across it. The second image shows the result after dithering down to four colors.

![Gradient](data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAjhJREFUWIXN2C9Qk3Ecx/E33G6PxRnAwgzMwgzOwopQpIhFLFDEIgaxiEEs4n1OLEIQixjEIhYoYhGDWMAgFFaAAgZmYQZmAcsM3nfCNmB/nj/73H1u2/P7PXffe/3unrtnDTnIOQgHCENZn5XsrfWeUENY5P6ISFjUY0I44Dhi/7doPq2g5ylKiPC/L5Emkf0lok0KdKDChHD+/2huEZmfItaiwAYqTF7QEm0V6R8i3qpABirMIUFLrE1sbYhEm3wfqDCNhKFU4xdFakMl1/xsSUFLol2kVkRHu9zAqCpHClqTl8XSigITbMw/so9pxxWx8E0n7vOiJwpau66K+a/+S5YlaO2+LuY++ytZ0YA40NMrZj76N2TZR3ywfTfF9Kw/x12xoLX/tph6771kVYLWgbti8q23klULWgfvi4nX3knWJGgdeijGXnojWbOgdfixGB13X9IVQevIUzHyzF1J1wSto8/F8BP3JF0VtI69EEOP3JF0XdA68UoMPqhd0hNB6+QbMXCvNknPBK1T70T/neolPR8QB6ZnRO+t6ob09IgPdvaD6Omr/Lh9EbTOfRLdNyqT9E3QOv9FdF0rX/LYtzqvsrAoujrF8qJO3Ou7oHXpu0h2qj4FLcurInlJrK/qyD1F/834ndSaSFwQW2squR6ooGV9U8TPi/SmitYCF7RsbYvYOZHZ1qHrdSFoSe+I6FmR3VH+Wt0IWjK7ovmM2N8VUGeCluyeiJwS7Kk+BwTYzwmnQfwFQUal1ERJKbEAAAAASUVORK5CYII=\)

![Dithered](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAUpJREFUWIXN1j1uhDAQhuEXKwpVqHIADpJqj5KDrCzOskfJOVbbpEu1HRUpIissy8/YMwZ/HRYaP5rBwtUAQ916cqa/pdd3detVBXLHAeRGaibkxkVK7KQbP5SIdNOF0pBPQCgLOQuEcpDVa+uHtRf6m1edwpDvy/z6+8d67U0g6JFLOEkWRzyOZtwaHAiBkIasP2M5z3mJ2aTB0589TedFxa+nVNZ/qrdu+xuc5i5EWgDFIx6n6Tz3s9fvLkgSEPZDJgNhHWkxXlACIX8n1UDIizQBwiPSarxgCIQ8nTQFwh9y6wIQE3Pg9QQ/X3ZIc2CIFTIbEGyQpsC506tFZu1giAa5CxDSkbsBIQ1pBpT+PWKRu3YwJAZ5CBDkSBNg6uVAgjysgyFbyMOBsI4sAgjLSDXQ8nI6hyymgyFTZHFAeESqgJbjnSYgfwFXXpE+U0kSIgAAAABJRU5ErkJggg==)

