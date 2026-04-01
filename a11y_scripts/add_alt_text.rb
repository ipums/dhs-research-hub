#!/usr/bin/env ruby

require "pathname"

POSTS_DIR = Pathname.new("posts")

unless POSTS_DIR.directory?
  warn "Could not find posts/ directory"
  exit 1
end

def filename_to_alt(path)
  stem = File.basename(path, File.extname(path))

  cleaned = stem
              .tr("-_", " ")
              .gsub(/\s+/, " ")
              .strip

  cleaned.empty? ? "TODO: image" : "TODO: #{cleaned} image"
end

def add_alt_to_markdown_images(text)
  text.gsub(/!\[(.*?)\]\(([^)]+)\)(\{[^}]*\})?/m) do |match|
    bracket_text = Regexp.last_match(1)
    path         = Regexp.last_match(2)
    attributes   = Regexp.last_match(3)

    # Preserve any image that already has explicit fig-alt
    if attributes && attributes.include?("fig-alt=")
      next match
    end

    alt = filename_to_alt(path)

    if attributes
      new_attributes = attributes.sub(/\}$/, %( fig-alt="#{alt}"}))
      %(![#{bracket_text}](#{path})#{new_attributes})
    else
      %(![#{bracket_text}](#{path}){fig-alt="#{alt}"})
    end
  end
end

def add_alt_to_hex_calls(text)
  text.gsub(/hex\("([^"]+)"(.*?)\)/) do |match|
    pkg  = Regexp.last_match(1)
    rest = Regexp.last_match(2)

    # Preserve any hex() call that already has alt
    next match if rest.include?("alt =") || rest.include?("alt=")

    alt = %(TODO: Hex logo for the #{pkg} R package)
    %(hex("#{pkg}"#{rest}, alt = "#{alt}"))
  end
end

def add_fig_alt_to_include_graphics_chunks(text)
  lines = text.lines
  output = []
  i = 0

  while i < lines.length
    line = lines[i]

    if line =~ /^```+\{r\b.*\}\s*$/
      chunk_lines = [line]
      i += 1

      while i < lines.length
        chunk_lines << lines[i]
        break if lines[i] =~ /^```\s*$/
        i += 1
      end

      chunk_text = chunk_lines.join

      has_include_graphics =
        chunk_text.match?(/(?:knitr::)?include_graphics\(\s*["'][^"']+["']\s*\)/)

      has_fig_alt =
        chunk_text.match?(/^\s*#\|\s*fig-alt\s*:/)

      if has_include_graphics && !has_fig_alt
        image_path = chunk_text[/((?:knitr::)?include_graphics\(\s*["']([^"']+)["']\s*\))/, 2]
        alt = filename_to_alt(image_path)
        chunk_lines.insert(1, %(#| fig-alt: "#{alt}"\n))
      end

      output << chunk_lines.join
    else
      output << line
    end

    i += 1
  end

  output.join
end

checked_count = 0
updated_count = 0

POSTS_DIR.glob("**/*.qmd").each do |path|
  checked_count += 1

  content = path.read
  updated = content.dup

  updated = add_alt_to_markdown_images(updated)
  updated = add_alt_to_hex_calls(updated)
  updated = add_fig_alt_to_include_graphics_chunks(updated)

  if updated != content
    path.write(updated)
    updated_count += 1
    puts "Updated #{path}"
  else
    puts "No changes needed for #{path}"
  end
end

puts
puts "Done."
puts "Checked: #{checked_count}"
puts "Updated: #{updated_count}"
