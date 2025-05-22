# Imports from other packages
#' @importFrom magrittr %>%

reticulate::virtualenv_create("r-reticulate")
.onLoad <- function(...) {
    reticulate::py_require(system.file("python", "module", package = "beprepared"))
    py <<-reticulate::import_from_path(
        "module",
        system.file("python", package = "beprepared"),
        delay_load = TRUE
    )
}

devtools::install(file.path("dependencies", "predped"))