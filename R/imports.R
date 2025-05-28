# Imports from other packages
#' @importFrom magrittr %>%

# Preferred method, but unreliable
# reticulate::virtualenv_create("r-reticulate")
# .onLoad <- function(...) {
#     reticulate::py_require(system.file("python", "module", package = "beprepared"))
#     python_functions <<-reticulate::import_from_path(
#         "module",
#         system.file("python", package = "beprepared"),
#         delay_load = TRUE
#     )
# }

# Unpreferred method, but reliable
reticulate::source_python(file.path("inst", "python", "module.py"))


# devtools::install(file.path("dependencies", "predped"))
devtools::load_all(file.path("dependencies", "predped"))