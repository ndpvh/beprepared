# Load required functions and variables
devtools::load_all()
source(file.path("environments.R"))

# Do a simulation
set.seed(1)
results <- viralpredped::simulate(
    "demo",
    environments[["supermarket_1"]],
    iterations = 1000,
    save_gif = TRUE,
    output_config = data.frame(
        Suppress = FALSE,
        Path = file.path("results", "output"),
        AerosolContaminationWriteInterval = 1,
        AerosolContaminationPrecision = 17,
        DropletContaminationWriteInterval = 1,
        DropletContaminationPrecision = 17,
        SurfaceContaminationWriteInterval = 1,
        SurfaceContaminationPrecision = 17
    )
)

# Compute the infection rate through the functions provided by Colin and Busra.
viralpredped:::infection_risk(results)
