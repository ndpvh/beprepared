# Imports from other packages
#' @importFrom magrittr %>%

path <- system.file("python", package = "beprepared")
py <- reticulate::import_from_path("module", path = path)

devtools::load_all(file.path("dependencies", "predped"))