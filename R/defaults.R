#' Add default columns to a data.frame
#' 
#' @param x Data.frame that serves as input
#' @param def Data.frame that contains the defaults
#' 
#' @return Data.frame that is filled with the values in \code{x} and/or \code{def}
#' 
#' @export 
defaults <- function(x, 
                     def) {

    # If x is NULL, return the defaults themselves
    if(is.null(x)) {
        return(def)
    }

    # If x has no rows, return the defaults themselves
    if(nrow(x) == 0) {
        return(def)
    }

    # Get all names in the default data.frame
    cols <- colnames(def)

    # Check whether x has less rows than def (only the case when agents can be 
    # sick or not). If so, then we replicate the number of rows in x with def
    if(nrow(x) < nrow(def)) {
        x <- do.call(
            "rbind",
            replicate(nrow(def), x, simplify = FALSE)
        )
    }

    # Loop over these columns, check whether they are present in x and, if not, 
    # add them to it
    for(i in cols) {
        if(!(i %in% colnames(x))) {
            x[, i] <- def[, i]
        }
    }

    # If probabilities are a part of this, scale them down so they sum to 1
    if("prob" %in% cols) {
        x$prob <- x$prob / sum(x$prob)
    }

    return(x[, cols])
}

#' @export 
default_env <- data.frame(
   decay_rate_air = 1.51, 
   decay_rate_droplet = 0.3, 
   decay_rate_surface = 0.262,
   air_exchange_rate = 0.2, 
   droplet_to_surface_transfer_rate = 18.18
)

#' @export 
default_surf <- data.frame(
   prob = 1, 
   transfer_efficiency = 0.5,
   touch_frequency = 15,
   surface_decay_rate = 0.969
)

#' @export 
default_item <- data.frame(
   prob = 1,
   transfer_efficiency = 0.7, 
   surface_ratio = 0.5,
   surface_decay_rate = 0.274
)

#' @export 
default_agent <- data.frame(
    prob = rep(1/2, 2),
    viral_load = c(1, 0), 
    contamination_load_air = c(0, 0), 
    contamination_load_droplet = c(0, 0), 
    contamination_load_surface = c(1, 0),
    emission_rate_air = rep(0.53, 2), 
    emission_rate_droplet = rep(0.47, 2), 
    pick_up_air = c(2.3, 30), 
    pick_up_droplet = c(2.3, 30),
    wearing_mask = c(0, 0)
)

#' @export 
default_env_config <- data.frame(
   AirCellSize = 500,
   MobilityCellSize = 100,
   AgentReach = 500,
   SimulationTimeStep = 1/(120 * 30),
   HandwashingContaminationFraction = 0.3,
   HandwashingEffectDuration = 0.5,
   MaskEmissionAerosolReductionEfficiency = 0.4,
   MaskEmissionDropletReductionEfficiency = 0.04,
   MaskAerosolProtectionEfficiency = 0.4,
   MaskDropletProtectionEfficiency = 0.04,
   CleaningInterval = 1,
   Diffusivity = 23,
   WallAbsorbingProportion = 0.0,
   CoughingRate = 121,
   CoughingFactor = 1,
   CoughingAerosolPercentage = 1.0,
   CoughingDropletPercentage = 1.0,
   SurfaceExposureRatio = 0.01
)

#' @export 
default_output_config <- data.frame(
   Suppress = FALSE,
   Path = file.path("output"),
   AerosolContaminationWriteInterval = 1,
   AerosolContaminationPrecision = 17,
   DropletContaminationWriteInterval = 1,
   DropletContaminationPrecision = 17,
   SurfaceContaminationWriteInterval = 1,
   SurfaceContaminationPrecision = 17
)