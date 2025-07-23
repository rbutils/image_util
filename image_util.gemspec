# frozen_string_literal: true

require_relative "lib/image_util/version"

Gem::Specification.new do |spec|
  spec.name = "image_util"
  spec.version = ImageUtil::VERSION
  spec.authors = ["hmdne"]
  spec.email = ["54514036+hmdne@users.noreply.github.com"]

  spec.summary = 'Simple pixel buffers with SIXEL and codec helpers'
  spec.description = 'Lightweight Color and Image classes for manipulating pixels. Provides SIXEL output plus FFI bindings for libpng, libturbojpeg and libsixel.'
  spec.homepage = "https://github.com/rbutils/image_util"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  
  spec.metadata['source_code_uri'] = 'https://github.com/rbutils/image_util'
  
  spec.metadata['changelog_uri'] = 'https://github.com/rbutils/image_util/blob/master/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://github.com/rbutils/image_util#readme'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/rbutils/image_util/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", "~> 1.16"
  spec.add_dependency "base64"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
