`%||%` <- function(x, y) {
  if (is_null(x)) y else x
}

theme_dhs_base <- function() {
  ggplot2::`%+replace%`(
    ggplot2::theme_minimal(),
    ggplot2::theme(
      text = ggplot2::element_text(family = "cabrito", size = 10), 
      plot.title = ggplot2::element_text(
        hjust = 0,
        size = 18, 
        color = "#00263A", # IPUMS navy
        margin = ggplot2::margin(b = 7)
      ), 
      plot.subtitle = ggplot2::element_text(
        size = 12, 
        hjust = 0,
        color = "#00000099",
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = 10,
        hjust = 1,
        color = "#00000099",
        margin = ggplot2::margin(t = 5)
      ),
      legend.position = "bottom",
      legend.title.position = "top",
      legend.title = ggplot2::element_text(size = 10, hjust = 0.5),
      legend.key.height = ggplot2::unit(7, "points"),
      legend.key.width = ggplot2::unit(45, "points"),
      legend.ticks = ggplot2::element_line(color = "white", linewidth = 0.2),
      legend.ticks.length = ggplot2::unit(1, "points"),
      legend.frame = ggplot2::element_rect(
        fill = NA, 
        color = "#999999", 
        linewidth = 0.2
      )
    )
  )
}

theme_dhs_map <- function(show_scale = TRUE, continuous = TRUE) {
  if (show_scale) {
    scale <- annotation_scale(
      aes(style = "ticks", location = "br"), 
      text_col = "#999999",
      line_col = "#999999",
      height = unit(0.2, "cm")
    )
  } else {
    scale <- NULL
  }
  
  if (continuous) {
    guide <- guides(
      fill = guide_colorbar(draw.llim = FALSE, draw.ulim = FALSE)
    )
  } else {
    guide <- guides(
      fill = guide_colorsteps(draw.llim = FALSE, draw.ulim = FALSE)
    )
  }
  
  list(scale, guide)
}

# renv does not appear to install proj along with sf.
#
# Adding either the global sf installation location (which includes a `proj`
# directory) or an external installation of PROJ to the search path appears to
# resolve the issue.
#
# However, this means that other users will have to both have an renv sf installation
# as well as a global sf installation.
#
# Not yet sure of a better way to enable this, but going to keep this for now.
#
# TODO: Add this to developer walkthrough if we need devs to handle proj
# installation themselves.
set_proj_search_paths <- function(path = NULL) {
  # path to global sf installation
  path <- path %||% "/Users/robe2037/Library/R/x86_64/4.3/library/sf/proj"
  
  # OR: path to direct PROJ installation
  # "/opt/homebrew/Cellar/proj/9.3.0/share/proj"
  
  sf_proj_search_paths(paths = c(sf_proj_search_paths(), path))
}

# Get the hex sticker for a package (e.g. for images within aside tags)
# Must be included in `images/hex` and recorded in `images/hex/inventory.csv`
hex <- function(pkg){
  inventory <- readr::read_csv(
    here::here("images/hex/inventory.csv"), 
    show_col_types = FALSE,
    progress = FALSE
  )
  
  if(pkg %in% inventory$package){
    inventory <- dplyr::filter(inventory, package == pkg)
    
    htmltools::div(
      class = "hex",
      htmltools::a(
        href = inventory$url,
        class = "hex",
        htmltools::img(
          src = file.path("../../images/hex", paste0(pkg, ".png")),
          class = "hex-img"
        )
      ),
      htmltools::p(
        class = "hex-cap",
        paste("©", inventory$owner, paste0("(", inventory$license, ")"))
      )
    )
  } else {
    rlang::abort(c(
      paste0("The `", pkg, "` package has no available hex logo"),
      "i" = "Consider downloading one to `images/hex`",
      "i" = "If you do, please add it to `images/hex/inventory.csv`" 
    ))
  }
}
