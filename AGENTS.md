# Contributor Guidelines

- Specs mirror file structure under `lib`. For example, `lib/image_util/image/buffer.rb` has a spec at `spec/image/buffer_spec.rb`.
- Use `autoload` for loading internal files. Avoid `require` and `require_relative`.
- Start every Ruby file with `# frozen_string_literal: true`.
- Prefer double-quoted strings except in specs and the gemspec.
- Use RSpec's `should` syntax instead of `expect`.
- For one-line methods, use the `def name = expression` style.
- After adding new features or modifying existing ones, change documentation accordingly (especially README and especially CHANGELOG).
- Specs target at least 80% coverage as enforced by SimpleCov.
- The library aims to remain lightweight and portable.
