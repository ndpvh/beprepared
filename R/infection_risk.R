# Author: Busra Atamer Balkan, Colin Teberg
# Updated by Niels Vanhasbroeck 

#' Compute an agent's infection risk
#' 
#' @param data Results coming from the \code{\link[beprepared]{simulate}} 
#' function. Should in the least contain the agent characteristics under 
#' \code{"agents"} and the exposure of the agents under \code{"agent_exposure"}.
#' @param time_step Numeric denoting the time between each iteration. Defaults 
#' to \code{0.5} (the same as in \code{\link[predped]{simulate,predped-method}}).
#' @param average_emission Numeric denoting the average emission of a virus 
#' through exposure (air and droplet). Defaults to \code{10^6}.
#' @param surface_exposure_ratio Numeric denoting a person's exposure to surfaces
#' per time unit. Defaults to \code{0.01}.
#' @param fx Function that will translate contamination exposure to risk. 
#' By default uses the \code{\link[beprepared]{hill_function}}.
#' @param ... Additional arguments passed on to \code{fx}.
#' 
#' @return Data.frame containing the agent and their exposure/risk
#' 
#' @export
infection_risk <- function(data, 
                           time_step = 0.5, 
                           average_emission = 10^6, 
                           surface_exposure_ratio = 0.01, 
                           fx = hill_function,
                           ...) {

    # Get the id's of the agents who have a viral load different than 0.
    agents <- data$agents %>% 
        dplyr::filter(viral_load > 0) %>% 
        dplyr::select(id) %>% 
        unlist() %>% 
        as.character()

    # Retrieve the exposure for each of the agents, excluding those who are 
    # already infectious. Additionally get the maximal load for surfaces out of 
    # the equation.
    agent_exposure <- data$agent_exposure %>% 
        dplyr::filter(!(Agent %in% agents))

    infectious_surface <- data$agent_exposure %>% 
        dplyr::select(`Accumulated Contamination Load Surface`) %>% 
        max()

    # Create a summary of the exposure risk by summing up the exposures at each
    # tick. Use these risk summaries to then compute the total exposure risk.
    risk_summary <- agent_exposure %>% 
        dplyr::group_by(Agent) %>% 
        dplyr::summarize(
            exposure_aerosol = sum(`Contamination Load Aerosol`, na.rm = TRUE), 
            exposure_droplet = sum(`Contamination Load Droplet`, na.rm = TRUE),
            exposure_surface = sum(`Accumulated Contamination Load Surface`, na.rm = TRUE)
        ) %>% 
        # Total exposure
        dplyr::mutate(
            exposure_surface = exposure_surface * time_step * surface_exposure_ratio,
            total_exposure = (exposure_aerosol + exposure_droplet) * average_emission
        ) %>% 
        # Risk of infection
        dplyr::mutate(risk_of_infection = fx(total_exposure, ...))

    return(risk_summary)
}
