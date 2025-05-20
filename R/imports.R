# Imports from other packages
#' @importFrom magrittr %>%

reticulate::source_python(file.path("inst", "python", "imports.py"))
reticulate::source_python(file.path("inst", "python", "utility.py"))
reticulate::source_python(file.path("inst", "python", "translate.py"))
reticulate::source_python(file.path("inst", "python", "run_model.py"))

devtools::load_all(file.path("dependencies", "predped"))