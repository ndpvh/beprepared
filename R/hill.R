#' Hill function
#' 
#' Hill function as defined by Busra Atamer Balkan and Colin Teberg. Used as 
#' one of the potential dose-response functions when computing infection risk.
#' 
#' @param exposure Numeric denoting the total exposure an agent has had to an 
#' infectious agent, or otherwise the ligand concentration.
#' @param alpha Numeric denoting the Hill coefficient. Defaults to \code{0.332},
#' which was taken from code originally written by the QVEmod developers.
#' @param lambda Numeric denoting the ligand concentration producing half 
#' occupation. Defaults to \code{10^(6.8)}, which was taken from code originally
#' written by the QVEmod developers.
#' 
#' @return Numeric denoting the risk of infection
#' 
#' @export 
hill_function <- function(exposure, 
                          alpha = 0.332, 
                          lambda = 10^(6.8)) {
    
    return(exposure^alpha / (lambda^alpha + exposure^alpha))
}