# Imports from other packages
#' @importFrom magrittr %>%

py <- reticulate::import_from_path("module", path = "./inst/python")

devtools::load_all(file.path("dependencies", "predped"))