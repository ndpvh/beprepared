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