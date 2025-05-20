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

    # Make sure all arguments are numeric
    if(!is.numeric(exposure)) {
        stop("Argument `exposure` should be numeric.")
    }

    if(!is.numeric(alpha)) {
        stop("Argument `exposure` should be numeric.")
    }

    if(!is.numeric(lambda)) {
        stop("Argument `exposure` should be numeric.")
    }

    # Make sure alpha and lambda are single values
    if(length(alpha) > 1) {
        stop("Argument `alpha` contains more than 1 value.")
    }

    if(length(lambda) > 1) {
        stop("Argument `lambda` contains more than 1 value.")
    }

    if(length(alpha) == 0) {
        stop("Argument `alpha` has length 0.")
    }

    if(length(lambda) == 0) {
        stop("Argument `lambda` has length 0.")
    }
    
    # Actual computation
    return(exposure^alpha / (lambda^alpha + exposure^alpha))
}