#!/usr/bin/env ruby

require "pathname"
require "cgi"
require "nokogiri"

SITE_DIR = Pathname.new("docs")

unless SITE_DIR.directory?
  warn "Could not find rendered site directory: #{SITE_DIR}"
  exit 1
end

HEX_ALT_MAP = {
  "Rlogo" => "R programming language logo",
  "ipumsr" => "Hex logo for the ipumsr R package",
  "tidyverse" => "Hex logo for the tidyverse collection of R packages",
  "sf" => "Hex logo for the sf R package for spatial vector data",
  "terra" => "Hex logo for the terra R package for raster and vector spatial data"
}.freeze

def filename_to_alt(path)
  filename = File.basename(path.to_s)
  stem = File.basename(filename, File.extname(filename))

  cleaned = stem
              .tr("_-", " ")
              .gsub(/\b\d+\b/, "")
              .gsub(/\s+/, " ")
              .strip

  cleaned.empty? ? "Image" : "#{cleaned} image"
end

def alt_for_src(src)
  decoded_src = CGI.unescapeHTML(src.to_s)

  if decoded_src.include?("/images/hex/") || decoded_src.include?("images/hex/")
    pkg = File.basename(decoded_src, File.extname(decoded_src))
    return HEX_ALT_MAP[pkg] || "Hex logo for the #{pkg} R package"
  end

  filename_to_alt(decoded_src)
end

total_files = 0
total_imgs  = 0

SITE_DIR.glob("**/*.html").each do |path|
  html = path.read
  doc = Nokogiri::HTML5(html)

  updated = 0

  doc.css("img").each do |img|
    next if img["alt"] && !img["alt"].strip.empty?

    src = img["src"]
    next unless src

    img["alt"] = alt_for_src(src)
    updated += 1
  end

  next if updated.zero?

  path.write(doc.to_html)
  total_files += 1
  total_imgs += updated
  puts "Updated #{path} (#{updated} image#{updated == 1 ? '' : 's'})"
end

puts
puts "Done. Updated #{total_imgs} image#{total_imgs == 1 ? '' : 's'} in #{total_files} HTML file#{total_files == 1 ? '' : 's'}."
