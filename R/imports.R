# Imports from other packages
#' @importFrom magrittr %>%

# Preferred method, but unreliable
reticulate::virtualenv_create("r-reticulate")
#' @export
.onLoad <- function(...) {
    reticulate::py_require(system.file("python", "module", package = "beprepared"))
    python_functions <<-reticulate::import_from_path(
        "module",
        system.file("python", package = "beprepared"),
        delay_load = TRUE
    )
}

devtools::load_all(system.file("predped", package = "beprepared"))