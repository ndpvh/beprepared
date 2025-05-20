#' Create a heatmap
#'
#' @details
#' Returns a heatmap created through \code{ggplot2}. Used to display the spread
#' of contamination through space. For simplicity sake, makes use of the same 
#' argument as the \code{\link[predped]{plot-method}} of \code{predped}, allowing
#' us to simply use one set of arguments for all plots simultaneously. 
#'
#' @param data Data.frame containing values for \code{X}, \code{Y}, and \code{Z}
#' where \code{X} and \code{Y} denote the coordinates in 2D space and \code{Z}
#' denotes the value assigned to this cell.
#' @param heatmap.fill Character vector containing two colors to use as 
#' extremes for the heatmap. If \code{dark_mode = TRUE}, the first of these 
#' colors is changed to \code{"black"}. Defaults to 
#' \code{c("white", "cornflowerblue")}.
#' @param Z.label Character denoting the label of the variable \code{Z} to be 
#' used in the legend. Defaults to \code{"Z"}.
#' @param Z.limits Numeric vector containing the limits of the heatmap in the 
#' Z dimension. Defaults to the minimum and maximum value of \code{Z} in the 
#' \code{data}.
#' @param X.limits,Y.limits Numeric vector containing the limits of the heatmap
#' in the X and Y dimensions, serving as limits to the plotted figure. Defaults 
#' to the minimum and maximum value of \code{X} and \code{Y} in the \code{data}.
#' @param shape.fill Character denoting the fill color of the setting in which 
#' the agents are running around. Defaults to \code{"grey"} when 
#' \code{dark_mode = FALSE} and to \code{"black"} otherwise.
#' @param shape.color Character denoting the color of the boundary of the 
#' setting in which agents are walking around. Defaults to \code{"black"} when 
#' \code{dark_mode = FALSE}, and to \code{"white"} otherwise.
#' @param shape.linewidth Numeric denoting the width of the boundary of the 
#' setting in which agents are walking around. Defaults to \code{1}.
#' @param plot.title Character denoting the title fo the plot. Defaults to an 
#' empty string.
#' @param plot.title.size Numeric denoting the text size of the plot title.
#' Defaults to \code{10}.
#' @param plot.title.hjust Numeric denoting the position of the plot title, with
#' \code{0} coding for left, \code{1} for right, and \code{0.5} for the middle.
#' Defaults to \code{0.5}.
#' @param axis.title.size Numeric of the text size of the axis title. Defaults
#' to \code{10}.
#' @param axis.text.size Numeric denoting the text size of the axis text.
#' Defaults to \code{8}.
#' @param legend.position Character denoting where the legend should be located.
#' Defaults to \code{"right"}.
#' @param legend.title.size Numeric denoting the size of the legend title.
#' Defaults to the size of \code{axis.title.size}.
#' @param legend.text.size Numeric denoting the size of the legend text. 
#' Defaults to the size of \code{axis.text.size}.
#' @param dark_mode Logical that can toggle the default colorpallette of predped's
#' dark mode. Defaults to \code{FALSE}.
#' @param ... Additional arguments that remain unused, but allow for the use 
#' of the same set of arguments across plotting functions.
#'
#' @return Heatmap
#'
#' @export
heatmap <- function(data, 
                    heatmap.fill = c("white", "salmon"),
                    Z.label = "Z",
                    Z.limits = range(data$Z),
                    X.limits = range(data$X),
                    Y.limits = range(data$Y),
                    shape.color = "black",
                    shape.fill = "grey",
                    shape.linewidth = 1,
                    plot.title = " ",
                    plot.title.size = 10,
                    plot.title.hjust = 0.5, 
                    axis.title.size = 10,
                    axis.text.size = 8,
                    legend.position = "bottom",
                    legend.title.size = axis.title.size,
                    legend.text.size = axis.text.size,
                    dark_mode = FALSE,
                    ...) {

    # If dark_mode = TRUE, we need to change the colors of the heatmap.
    if(dark_mode) {
        heatmap.fill[1] <- ifelse(heatmap.fill[1] == "white", "black", heatmap.fill[1])
        shape.color <- "white"
        shape.fill <- "grey"
    }

    # Add some small jitter whenever there is no variation. Otherwise will make
    # for jumpy visualizations.
    if(sd(data$Z, na.rm = TRUE) == 0) {
        if(Z.limits[1] == Z.limits[2]) {
            Z.limits <- c(1e-3, 1e-3)
        }
    }

    # Create the plot itself
    plt <- ggplot2::ggplot(
        data = data,
        ggplot2::aes(
            x = X, 
            y = Y,
            fill = Z
        )
    ) +
        ggplot2::annotate(
            "polygon",
            x = c(X.limits[1], X.limits[1], X.limits[2], X.limits[2]),
            y = c(Y.limits[1], Y.limits[2], Y.limits[2], Y.limits[1]),
            fill = shape.fill
        ) +
        ggplot2::geom_tile() +
        ggplot2::scale_fill_gradient(
            low = heatmap.fill[1],
            high = heatmap.fill[2],
            limits = Z.limits,
            oob = scales::squish
        ) +
        ggplot2::labs(
            title = plot.title,
            x = "x",
            y = "y",
            fill = Z.label
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
            panel.background = ggplot2::element_rect(fill = "black"),
            panel.border = ggplot2::element_rect(
                fill = NA,
                linewidth = shape.linewidth, 
                color = shape.color
            ),
            panel.grid.major = ggplot2::element_blank(),
            panel.grid.minor = ggplot2::element_blank(),
            axis.title = ggplot2::element_text(size = axis.title.size),
            axis.text = ggplot2::element_text(size = axis.text.size),
            plot.title = ggplot2::element_text(
                size = plot.title.size,
                hjust = plot.title.hjust
            ),
            legend.position = legend.position,
            legend.title = ggplot2::element_text(size = legend.title.size),
            legend.text = ggplot2::element_text(size = legend.text.size)
        ) +
        ggplot2::coord_fixed()

    return(plt)
}