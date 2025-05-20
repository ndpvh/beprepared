#' Discretize space
#' 
#' Takes in a vector of continuous data and then assigns the observed positions
#' to a cell in a grid based on the discretization \code{dx} parameter. This 
#' function is needed to translate the continuous positions that \code{predped} 
#' provides to discrete cells that \code{QVEmod} uses. 
#' 
#' Output consists of the indices of the cells that the continuous position lies 
#' in. Note that indexing starts at 0 instead of 1 (following Python indexing).
#' 
#' @param x Numeric vector containing values to be discretized.
#' @param min_x Value to add to \code{x} so that it starts at 0. Needed to ensure
#' that those values of \code{x} that are minimal are assigned to cell 0. 
#' Defaults to the minimum of \code{x}.
#' @param dx Numeric denoting the size of a cell. Defaults to \code{0.1}.
#' 
#' @return Integer vector containing indices of the cells in which \code{x} can 
#' be attributed.
#' 
#' @export
discretize <- function(x, 
                       min_x = min(x),
                       dx = 0.1) {
    x %>% 
        `+` (min_x) %>% 
        `/` (dx) %>% 
        floor() %>% 
        as.integer() %>% 
        return()
}

#' Transform object to segments
#' 
#' Takes in an instance of the \code{\link[predped]{object-class}} and returns 
#' a data.frame of segment points for this object. Used for translation purposes
#' from \code{predped} to \code{QVEmod}.
#' 
#' @param object Instance of the \code{\link[predped]{object-class}} to be 
#' segmentized
#' @param discretize Logical denoting whether the positions should be discretized.
#' If \code{TRUE}, segments will refer to indices of cells instead of absolute 
#' continuous positions in space. Defaults to \code{TRUE}.
#' @param origin X- and y-coordinate that represents the bottom-left corner of 
#' the space in which the object is located. Allows for accurate discretization.
#' Ignored if \code{discretize = FALSE}. Defaults to \code{c(0, 0)}.
#' @param dx Numeric denoting the size of a cell. Ignored if 
#' \code{discretize = FALSE}. Defaults to \code{0.1}.
#' 
#' @return Data.frame containing the beginning (\code{"x1"} and \code{"y1"}) and
#' end coordinates (\code{"x2"} and \code{"y2"}) of the object.
#' 
#' @export
segmentize <- function(object, 
                       discretize = TRUE,
                       origin = c(0, 0),
                       dx = 0.1) {
                        
    # Create the segments
    object <- object %>% 
        predped::points() %>% 
        as.data.frame() %>% 
        setNames(c("x", "y")) %>% 
        dplyr::mutate(
            x1 = x,
            y1 = y,
            x2 = x[c(2:length(x), 1)], 
            y2 = y[c(2:length(y), 1)]
        ) %>% 
        dplyr::select(-x, -y)

    # Discretize if needed
    if(discretize) {
        object <- object %>% 
            dplyr::mutate(
                x1 = discretize(
                    x1, 
                    min_x = origin[1],
                    dx = dx
                ),
                y1 = discretize(
                    y1, 
                    min_x = origin[2],
                    dx = dx
                ),
                x2 = discretize(
                    x2, 
                    min_x = origin[1],
                    dx = dx
                ),
                y2 = discretize(
                    y2, 
                    min_x = origin[2],
                    dx = dx
                )
            )
    }
        
    return(object)
}