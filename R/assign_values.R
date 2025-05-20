#' Assign values for QVEmod's parameters
#' 
#' @param id Vector containing the different id's to assign the values to.
#' @param parameters Data.frame containing several columns that denote the parameters 
#' to assign to the QVEmod classes. Should contain a column \code{prob} which 
#' contains the probability with which to assign the parameters in that row 
#' to a given \code{id}.
#' 
#' @return Data.frame containing the \code{id}s and their assigned values for 
#' the \code{QVEmod} classes.
#' 
#' @export
assign_values <- function(id, 
                          parameters) {

    # Check whether there is a column "prob" in the data
    if(is.null(parameters$prob)) {
        stop("Parameters data.frame should contain a column `prob` to be able to assign values")
    }

    # Rescale the probabilities to sum to 1
    parameters$prob <- parameters$prob / sum(parameters$prob)

    # Sample the indices/parameters to be used and assigned to the indices
    idx <- sample(
        1:nrow(parameters),
        length(id),
        replace = TRUE, 
        prob = parameters$prob
    )

    # Delete the prob column from the parameters data.frame
    parameters <- dplyr::select(parameters, -prob)

    # Combine id's with the parameters in one big dataframe
    parameters <- cbind(id, parameters[idx, ]) %>% 
        as.data.frame() %>% 
        setNames(c("id", colnames(parameters)))

    return(parameters)
}
