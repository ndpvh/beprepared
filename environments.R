################################################################################
# environments.R                                                               #
#                                                                              #
# PURPOSE: Define some environment to use in the simulations. Put in a list    #
#          for simplicity sake.                                                #
#                                                                              # 
#          Some things to take into account when trying to translate to        # 
#          QVEmod:                                                             # 
#             - They distinguish between surfaces and barriers, where barriers # 
#               block any contaminants, while surfaces allow them to pass      # 
#               through (and may themselves contain contaminants). To          # 
#               distinguish between both, we will use "surface" in the "id"    # 
#               of an object to more accurately represent the space.           # 
#             - They distinguish between items and fixtures, both of which     # 
#               fall under the surfaces category. Items are single points in   # 
#               space while (to my current understanding) fixtures are objects # 
#               in space.                                                      #
#             - They only allow for horizontal or vertical barriers.           #
################################################################################

environments <- list() 





################################################################################
# UTILITY FUNCTIONS
################################################################################

cash_register <- function(center, 
                          flipped = FALSE, 
                          orientation = 0) {

    # Create the default cash register. 
    points <- rbind(
        c(0, 0),
        c(0, 0.62),
        c(2, 0.62),
        c(2, 0),
        c(1.505, 0),
        c(1.505, 0.61), 
        c(0.905, 0.61),
        c(0.905, 0)
    )

    # Determine whether the cash register should be flipped. This means that the 
    # space where the cashier sits is put at a different location. The flipping 
    # happens vertically.
    if(flipped) {
        points[,2] <- max(points[,2]) - points[,2]
    }

    # Center the points around (0, 0). Needed for the rotation to take effect.
    points[,1] <- points[,1] - 1
    points[,2] <- points[,2] - 0.31

    # Determine whether the cash register should be rotated to some degree. 
    R <- matrix(
        c(cos(orientation), sin(orientation), -sin(orientation), cos(orientation)),
        nrow = 2,
        ncol = 2
    )

    points <- t(R %*% t(points)) 

    # Move the cash register to the center indicated by the user.
    points[,1] <- points[,1] + center[1]
    points[,2] <- points[,2] + center[2]

    return(points)
}



################################################################################
# SUPERMARKETS
################################################################################

# Supermarket 1: The typical supermarket environment that we have always used.
environments[["supermarket_1"]] <- predped::background(
    shape = predped::rectangle(
        center = c(20, 12.5),
        size = c(40, 25)
    ), 
    objects = list(
        # Bottom left
        predped::rectangle(
            center = c(12, 4),
            size = c(12, 1.2)
        ),
        predped::rectangle(
            center = c(12, 7),
            size = c(12, 1.2)
        ),

        # Top left
        predped::rectangle(
            center = c(12.5, 14),
            size = c(13, 1.2)
        ),
        predped::rectangle(
            center = c(12.5, 17),
            size = c(13, 1.2)
        ),
        predped::rectangle(
            center = c(12.5, 20),
            size = c(13, 1.2)
        ),

        # Top right
        predped::rectangle(
            center = c(29, 11),
            size = c(14, 1.2)
        ),
        predped::rectangle(
            center = c(29, 14),
            size = c(14, 1.2)
        ),
        predped::rectangle(
            center = c(29, 17),
            size = c(14, 1.2)
        ),
        predped::rectangle(
            center = c(29, 20),
            size = c(14, 1.2)
        ),
        predped::rectangle(
            center = c(29, 23),
            size = c(14, 1.2)
        ),

        # Bottom right
        predped::rectangle(
            center = c(27, 4),
            size = c(12, 1.2)
        ),
        predped::rectangle(
            center = c(27, 7),
            size = c(12, 1.2)
        ),

        # Other
        predped::rectangle(
            center = c(20, 1.2 / 2), 
            size = c(32, 1.2)
        ),
        predped::rectangle(
            center = c(38, 4),
            size = c(1.2, 4)
        ),
        predped::rectangle(
            center = c(39.4, 7.5 + 8.75), 
            size = c(1.2, 25 - 7.5)
        ),
        predped::polygon(
            points = cbind(
                c(0, 0, 16, 16, 1.2, 1.2),
                c(19.5, 25, 25, 22.5, 22.5, 19.5)
            )
        ),
        predped::rectangle(
            center = c(1, 14.5),
            size = c(2, 1.2),
            interactable = TRUE
        ),
        predped::polygon(
            points = cbind(
                c(0, 0, 17, 17, 1.2, 1.2), 
                c(3.5, 11.6, 11.6, 10.4, 10.4, 3.5)
            )
        )
    ),
    entrance = c(0, 0.5),
    exit = c(0, 13)
)



# Supermarket 2
#
# Based on a floor plan found online of the Albert Heijn Delft In contrast
# to Supermarket 1, this supermarket has a cash register.
environments[["supermarket 2: free flow"]] <- predped::background(
    shape = predped::polygon(
        points = rbind(
            c(0, 0),
            c(0, 17.5),
            c(22.5, 17.5),
            c(22.5, 13.5),
            c(24.5, 11.5),
            c(24.5, 11.5),
            c(24.5, 0)
        )
    ),
    # Objects in the environment
    objects = list(
        # Cash registers. Importantly, left some space for potential cashiers 
        # who need to interact with the costumers.
        #
        # To ensure that agents won't step into the way of other agents at these 
        # registers, we create some spacers.
        predped::polygon(
            id = "surface: cash register 1",
            points = cash_register(
                c(21.5, 0.31), 
                flipped = FALSE,
                orientation = 0
            ),
            forbidden = 1:8
        ),
        predped::rectangle(
            id = "spacer cash registers 1 and 2",
            center = c(21.5, 1.24),
            size = c(2, 0.02),
            forbidden = 1:4
        ),
        predped::polygon(
            id = "surface: cash register 2",
            points = cash_register(
                c(21.5, 2.17), 
                flipped = TRUE,
                orientation = 0
            ),
            forbidden = 1:8
        ),

        predped::polygon(
            id = "surface: cash register 3",
            points = cash_register(
                c(21.5, 2.79), 
                flipped = FALSE,
                orientation = 0
            ),
            forbidden = 1:8
        ),
        predped::rectangle(
            id = "spacer cash registers 3 and 4",
            center = c(21.5, 3.72),
            size = c(2, 0.02),
            forbidden = 1:4
        ),
        predped::polygon(
            id = "surface: cash register 4",
            points = cash_register(
                c(21.5, 4.65), 
                flipped = TRUE,
                orientation = 0
            ),
            forbidden = 1:8
        ),

        predped::polygon(
            id = "surface: cash register 5",
            points = cash_register(
                c(21.5, 5.27), 
                flipped = FALSE,
                orientation = 0
            ),
            forbidden = 1:8
        ),
        predped::rectangle(
            id = "spacer cash registers 5 and 6",
            center = c(21.5, 6.20),
            size = c(2, 0.02),
            forbidden = 1:4
        ),
        predped::polygon(
            id = "surface: cash register 6",
            points = cash_register(
                c(21.5, 7.13), 
                flipped = TRUE,
                orientation = 0
            ),
            forbidden = 1:8
        ),
        

        # Entrance. Consists of two one-way streets and a few walls that ensure
        # they have to pass through the cash registers.
        predped::polygon(
            points = rbind(
                c(19.5, 14),
                c(20, 14),
                c(20, 10),
                c(21, 9),
                c(21, 7.44),
                c(20.5, 7.44),
                c(20.5, 9),
                c(19.5, 10)
            ),
            forbidden = 1:8
        ),
        predped::rectangle(
            center = c(19.75, 16.5),
            size = c(0.5, 2),
            forbidden = 1:4
        ),
        predped::rectangle(
            center = c(19.75, 14.75),
            size = c(0.5, 0.05),
            forbidden = 1:4
        ),


        # Walls and beams. Break the flow of the customer
        predped::circle(
            center = c(11, 10.8),
            radius = 0.2,
            forbidden = matrix(c(0, 2 * pi), nrow = 1)
        ),
        predped::circle(
            center = c(11, 9.4),
            radius = 0.2,
            forbidden = matrix(c(0, 2 * pi), nrow = 1)
        ),
        predped::circle(
            center = c(11, 8.2),
            radius = 0.2,
            forbidden = matrix(c(0, 2 * pi), nrow = 1)
        ),
        predped::circle(
            center = c(11, 6.8),
            radius = 0.2,
            forbidden = matrix(c(0, 2 * pi), nrow = 1)
        ),
        predped::circle(
            center = c(11, 5.4),
            radius = 0.2,
            forbidden = matrix(c(0, 2 * pi), nrow = 1)
        ),


        # Top half: These consist of several irregular forms due to the produce 
        # they sell, such as the bakery, the deli, and vegetables
        predped::rectangle(
            id = "bakery 1",
            center = c(4.65, 17.3),
            size = c(4.3, 0.4),
            forbidden = 1:3
        ),
        predped::polygon(
            id = "bakery 2",
            points = rbind(
                c(2, 16.7),
                c(2.5, 16.7),
                c(2.5, 13.7),
                c(0.7, 13.7),
                c(0.7, 14.2),
                c(2, 14.2)
            ),
            forbidden = c(1, 4:6)
        ),
        predped::rectangle(
            id = "bakery 3",
            center = c(0.2, 11),
            size = c(0.4, 5),
            forbidden = c(1:2, 4)
        ),
        predped::rectangle(
            id = "bakery 4",
            center = c(5, 14.8),
            size = c(2.1, 0.8)
        ),

        predped::rectangle(
            id = "meat 1",
            center = c(10.3, 17.3),
            size = c(5, 0.4),
            forbidden = 1:3
        ),
        predped::rectangle(
            id = "meat 2",
            center = c(8.8, 15.2),
            size = c(3.8, 0.9)
        ),
        predped::rectangle(
            id = "meat 3",
            center = c(10.5, 13.1),
            size = c(3.4, 0.9)
        ),

        predped::polygon(
            id = "deli 1",
            points = rbind(
                c(3, 10.8),
                c(3, 12.4),
                c(3.3, 12.7),
                c(7.4, 12.7),
                c(7.7, 12.4),
                c(7.7, 10.8),
                c(7, 10.8),
                c(7, 12),
                c(3.7, 12),
                c(3.7, 10.8)
            ),
            forbidden = 6:10
        ),
        predped::polygon(
            id = "deli 2",
            points = rbind(
                c(3.3, 9.8),
                c(3.3, 10.2),
                c(5, 10.2),
                c(5, 11.6),
                c(5.8, 11.6),
                c(5.8, 10.2),
                c(7.5, 10.2),
                c(7.5, 9.8)
            ),
            forbidden = 1:7
        ),

        predped::rectangle(
            id = "ready to eat",
            center = c(16.6, 17.3),
            size = c(6.8, 0.4),
            forbidden = 1:3
        ),

        predped::rectangle(
            id = "fruit and vegetables 1",
            center = c(15.95, 15.2),
            size = c(3.9, 1.1)
        ),
        predped::rectangle(
            id = "fruit and vegetables 2",
            center = c(16, 13.1),
            size = c(4, 1.1)
        ),
        predped::rectangle(
            id = "fruit and vegetables 3",
            center = c(15.8, 11.3),
            size = c(0.4, 0.4)
        ),
        predped::rectangle(
            id = "fruit and vegetables 4",
            center = c(16.9, 11.3),
            size = c(0.4, 0.4)
        ),
        predped::rectangle(
            id = "fruit and vegetables 5",
            center = c(18, 11.3),
            size = c(0.4, 0.4)
        ),
        predped::rectangle(
            id = "fruit and vegetables 6",
            center = c(19.2, 10.5),
            size = c(0.4, 1.2),
            forbidden = 2:4
        ),

        predped::rectangle(
            id = "unknown purpose 1",
            center = c(1.5, 11),
            size = c(0.6, 0.9)
        ),
        predped::rectangle(
            id = "unknown purpose 2",
            center = c(12.4, 15.2),
            size = c(0.9, 1.3)
        ),
        predped::rectangle(
            id = "unknown purpose 3",
            center = c(9.45, 11.3),
            size = c(0.9, 0.6)
        ),
        predped::rectangle(
            id = "unknown purpose 4",
            center = c(12.55, 11.3),
            size = c(0.9, 0.6)
        ),
        predped::rectangle(
            id = "unknown purpose 5",
            center = c(14.35, 11.3),
            size = c(0.9, 0.6)
        ),


        # Lower half: Mostly consists of the typical aisles.
        predped::rectangle(
            id = "dairy",
            center = c(0.2, 3.6),
            size = c(0.4, 7.2),
            forbidden = c(1:2, 4)
        ),

        predped::polygon(
            id = "drinks 1",
            points = rbind(
                c(0.4, 0),
                c(0.4, 0.4),
                c(6.6, 0.4),
                c(6.6, 1.7),
                c(7, 1.7),
                c(7, 0.4),
                c(10.7, 0.4),
                c(10.7, 1.7),
                c(11.1, 1.7),
                c(11.1, 0.4),
                c(11.7, 0.4),
                c(11.7, 0)
            ),
            forbidden = c(1, 11:12)
        ),
        predped::rectangle(
            id = "drinks 2",
            center = c(2.3, 2.15),
            size = c(0.4, 1.7)
        ),
        predped::rectangle(
            id = "drinks 3",
            center = c(3.8, 2.15),
            size = c(0.4, 1.7)
        ),
        predped::rectangle(
            id = "drinks 4",
            center = c(5.3, 2.15),
            size = c(0.4, 1.7)
        ),
        predped::rectangle(
            id = "drinks 5",
            center = c(8.3, 2.15),
            size = c(0.4, 1.7)
        ),
        predped::rectangle(
            id = "drinks 6",
            center = c(9.8, 1.8),
            size = c(0.4, 0.8)
        ),
        predped::rectangle(
            id = "drinks 7",
            center = c(6.8, 2.6),
            size = c(0.4, 0.8)
        ),
        predped::rectangle(
            id = "drinks 8",
            center = c(9.8, 2.95),
            size = c(0.5, 0.5)
        ),

        predped::rectangle(
            id = "left aisle 1",
            center = c(6.1, 4.7),
            size = c(8, 0.4)
        ),
        predped::rectangle(
            id = "left aisle 2",
            center = c(6, 6.2),
            size = c(8.2, 0.4)
        ),
        predped::rectangle(
            id = "left aisle 3",
            center = c(6.1, 7.6),
            size = c(8, 0.4)
        ),
        predped::rectangle(
            id = "left aisle 4",
            center = c(4.1, 9),
            size = c(4, 0.4)
        ),
        predped::polygon(
            id = "left aisle 5",
            points = rbind(
                c(7.5, 9.8),
                c(7.9, 9.8),
                c(7.9, 9.2),
                c(10.1, 9.2),
                c(10.1, 8.8),
                c(7.5, 8.8)
            )
        ),
        predped::rectangle(
            id = "left aisle 6",
            center = c(9.45, 10),
            size = c(1.3, 0.4)
        ),

        predped::rectangle(
            id = "freezer 1",
            center = c(13.7, 0.2),
            size = c(3, 0.4),
            forbidden = c(1, 3:4)
        ),
        predped::rectangle(
            id = "freezer 2",
            center = c(18.6, 0.2),
            size = c(3, 0.4),
            forbidden = c(1, 3:4)
        ),
        predped::rectangle(
            id = "freezer 3",
            center = c(17.1, 1.8),
            size = c(3.4, 0.8)
        ),
        predped::rectangle(
            id = "freezer 4",
            center = c(15.7, 3.3),
            size = c(6.8, 0.4)
        ),

        predped::rectangle(
            id = "right aisle 1",
            center = c(15.4, 4.7),
            size = c(7.1, 0.4)
        ),
        predped::rectangle(
            id = "right aisle 2",
            center = c(15.1, 6.2),
            size = c(6.5, 0.4)
        ),
        predped::rectangle(
            id = "right aisle 3",
            center = c(15.2, 7.6),
            size = c(6.8, 0.4)
        ),
        predped::rectangle(
            id = "right aisle 4",
            center = c(14.9, 9),
            size = c(6.1, 0.4)
        ),
        predped::rectangle(
            id = "right aisle 5",
            center = c(15.4, 10),
            size = c(7.2, 0.4)
        )

    ),

    # One-directional flow. Limited to cash registers and entrances in this free
    # flow version
    limited_access = list(
        # Cash registers
        predped::segment(
            from = c(22.5, 7.44),
            to = c(22.5, 0)
        ),

        # Entrance
        predped::segment(
            from = c(19.5, 14),
            to = c(19.5, 15.5)
        ),

        # Forbidden regions throughout the store
        predped::segment(
            from = c(2.5, 17.1),
            to = c(2.5, 16.7)
        ),
        predped::segment(
            from = c(0.7, 13.7),
            to = c(0.4, 13.5)
        ),
        predped::segment(
            from = c(3.3, 10.2),
            to = c(3.33, 10.8)
        ),
        predped::segment(
            from = c(7.5, 10.8),
            to = c(7.5, 10.2)
        )
    ),

    # Entrances and exits
    entrance = rbind(
        c(20.7, 17.5),
        c(21.8, 17.5)
    )
)

# Also make a unidirectional version of this supermarket.
environments[["supermarket 2: restricted"]] <- environments[["supermarket 2: free flow"]]
la <- predped::limited_access(environments[["supermarket 2: restricted"]])
predped::limited_access(environments[["supermarket 2: restricted"]]) <- append(
    la, 
    list(
        # Navigating the first sections
        predped::segment(
            id = "fruit and vegetables 1, top right",
            from = c(19.5, 15.8),
            to = c(18, 15.8)
        ),
        predped::segment(
            id = "fruit and vegetables 1, top left",
            from = c(12.8, 15.8),
            to = c(14, 15.8)
        ),
        predped::segment(
            id = "fruit and vegetables 1, bottom right",
            from = c(18, 13.6),
            to = c(18, 14.7)
        ),
        predped::segment(
            id = "fruit and vegetables 1, bottom left",
            from = c(14, 13.6),
            to = c(14, 14.7)
        ),
        predped::segment(
            id = "fruit and vegetables 2, top right",
            from = c(18, 13.6),
            to = c(19.5, 13.6)
        ),
        predped::segment(
            id = "fruit and vegetables 2, bottom left",
            from = c(14, 12.5),
            to = c(12, 12.5)
        ),

        predped::segment(
            id = "unknown purpose 1, top left",
            from = c(10.5, 15.8),
            to = c(12, 15.8)
        ),
        predped::segment(
            id = "unknown purpose 1, bottom left",
            from = c(12, 13.6),
            to = c(12, 14.5)
        ),        
        predped::segment(
            id = "unknown purpose 3, top left",
            from = c(12, 12.5),
            to = c(12, 11.75)
        ),
        predped::segment(
            id = "unknown purpose 3, bottom left",
            from = c(12, 11.15),
            to = c(12, 10.15)
        ),

        # Navigating the bakery and deli
        predped::segment(
            id = "meat 2, middle left",
            from = c(6, 15.2),
            to = c(6.9, 15.2)
        ),
        predped::segment(
            id = "meat 3, bottom left",
            from = c(8.8, 12.4),
            to = c(7.7, 12.2)
        ),
        predped::segment(
            id = "meat 3, top left",
            from = c(8.8, 13.6),
            to = c(8.8, 14.5)
        ),
        predped::segment(
            id = "bakery 4, top left",
            from = c(2.5, 15.2),
            to = c(4, 15.2)
        ),
        predped::segment(
            id = "deli 1, top left",
            from = c(3.3, 12.7),
            to = c(2.5, 13.7)
        ),

        # Navigating the aisles
        predped::segment(
            id = "left aisle 4, top middle",
            from = c(3.3, 9.2),
            to = c(3.3, 9.8)
        ),
        predped::segment(
            id = "left aisle 4, bottom right",
            from = c(6.1, 8.8),
            to = c(7.5, 8.8)
        ),
        predped::segment(
            id = "left aisle 3, top left",
            from = c(2.1, 7.8),
            to = c(2.1, 8.8)
        ),
        predped::segment(
            id = "left aisle 3, top right",
            from = c(10.1, 7.8),
            to = c(10.1, 8.8)
        ),
        predped::segment(
            id = "left aisle 2, top left",
            from = c(2.1, 7.4),
            to = c(2.1, 6.4)
        ),
        predped::segment(
            id = "left aisle 2, top right",
            from = c(10.1, 7.4),
            to = c(10.1, 6.4)
        ),
        predped::segment(
            id = "left aisle 1, top left",
            from = c(2.1, 5),
            to = c(2.1, 6)
        ),
        predped::segment(
            id = "left aisle 1, top right",
            from = c(10.1, 5),
            to = c(10.1, 6)
        ),
        predped::segment(
            id = "left aisle 1, bottom left",
            from = c(2.1, 4.6),
            to = c(0.4, 4.6)
        ),
        predped::segment(
            id = "left aisle 1, bottom right",
            from = c(10.1, 4.6),
            to = c(10.1, 2.25)
        ),
        predped::segment(
            id = "drinks 1, right",
            from = c(10, 1.7),
            to = c(10.7, 1.7)
        ),

        predped::segment(
            id = "right aisle 5, bottom left",
            from = c(11.8, 9.8),
            to = c(11.8, 9.2)
        ),
        predped::segment(
            id = "right aisle 5, bottom right",
            from = c(17.95, 9.8),
            to = c(17.95, 9.2)
        ),
        predped::segment(
            id = "right aisle 3, top left",
            from = c(11.85, 7.8),
            to = c(11.85, 8.8)
        ),
        predped::segment(
            id = "right aisle 3, top right",
            from = c(17.95, 7.8),
            to = c(17.95, 8.8)
        ),
        predped::segment(
            id = "right aisle 2, top left",
            from = c(11.85, 7.4),
            to = c(11.85, 6.4)
        ),
        predped::segment(
            id = "right aisle 2, top right",
            from = c(18.35, 7.4),
            to = c(18.35, 6.4)
        ),
        predped::segment(
            id = "right aisle 1, top left",
            from = c(11.85, 5),
            to = c(11.85, 6)
        ),
        predped::segment(
            id = "right aisle 1, top right",
            from = c(18.35, 5),
            to = c(18.35, 6)
        )
    )
)
