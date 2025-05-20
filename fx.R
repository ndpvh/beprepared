################################################################################
# fx.R                                                                         #
#                                                                              #
# PURPOSE: Define a special function that should be used within a given        #
#          environment. Mostly used to handle goal assignment for agents who   #
#          are walking around and those who are "working" in that environment  #
#          (e.g., cashiers).                                                   #
################################################################################

fx <- list()





################################################################################
# SUPERMARKETS
################################################################################

# In Supermarket 1, there is nothing special to account for.
fx[["supermarket 1"]] <- \(x) x

# Create a wait-goal. This goal is used whenever a customer or cashier is 
# waiting to be interacted with.
wait_goal <- function(x) {
    return(
        predped::goal(
            id = "wait",
            position = x, 
            counter = 1000,
            path = matrix(0, nrow = 1, ncol = 2)
        )
    )
}

# Define a single function that will handle all goals within the necessary 
# supermarket environments. This is the same for Supermarket 2 and all 
# subsequent supermarkets that make use of cashiers.
#
# We create several different functions that will help in managing the customer/
# cashier relationship while keeping an overview. We start with the customer
update_customer <- function(agent,
                            stage,
                            vars,
                            positions) {

    ############################################################################
    # PRELIMINARY STUFF

    # Get some relevant variables from the agent
    agent_id <- predped::id(agent)
    agent_status <- predped::status(agent)
    agent_goal <- predped::current_goal(agent)

    # Check whether a customer's number of items is included in the necessary 
    # variable. If not, add it.
    if(!(agent_id %in% names(vars[["items"]]))) {
        vars[["items"]][agent_id] <- length(predped::goals(agent)) + 1
    }

    # Check whether the customer is in the "stage" list. If not, add them
    # to it at stage -1.
    if(!(agent_id %in% names(vars[["stage_customer"]]))) {
        vars[["stage_customer"]][agent_id] <- -1
        stage <- -1
    }

    # Get the cashier-id of this agent and their queue. Included here to reduce
    # spaghetti code, but note that this only exists whenever the customer has
    # moved past stage 0. Before that, this will be empty.
    cashier <- ifelse(
        agent_goal@id == "wait", 
        predped::goals(agent)[[1]]@id, 
        agent_goal@id
    )
    cashier <- stringr::str_split(cashier, pattern = " ")[[1]]
    cashier <- paste0(cashier[2:3], collapse = " ")

    queue <- vars[["in_line"]][[cashier]]



    ############################################################################
    # HANDLE THE DIFFERENT CASES BASED ON THE STAGE OF THE CUSTOMER

    # Stage -1: Still doing their purchases. 
    #
    # At this stage, we:
    #   - Check for whether the agent has done their purchases. If so, then 
    #     they will be assigned a cash register and move on to the next stage.
    if(stage == "-1") {
        # Check whether the customer is done with what their buying. Only 
        # when they want to exit should we change things for them.
        if(agent_goal@id == "goal exit") {
            # Once moving to a next stage, we determine which cash register 
            # to go to and give the customer two new goals, namely to check
            # in and out of the cash register. Goals bear the names of the 
            # cashier in charge.
            idx <- sample(1:6, 1)

            predped::current_goal(agent) <- predped::goal(
                id = paste("checkin cashier", idx),
                position = vars[["checkin"]][[idx]],
                counter = vars[["checkin_time"]](vars[["items"]][agent_id])
            )
            predped::goals(agent) <- list(
                predped::goal(
                    id = paste("checkout cashier", idx),
                    position = vars[["checkout"]][[idx]],
                    counter = vars[["checkout_time"]](vars[["items"]][agent_id])
                )
            )

            # Make the agent plan their next move, as they have to go through
            # the cash register.
            predped::status(agent) <- "plan"

            # Add this agent to the customer-list for the relevant 
            # cashier. This allows them to create the necessary goal
            vars[["customers"]][[paste("cashier", idx)]] <- c(
                vars[["customers"]][[paste("cashier", idx)]],
                agent_id
            )

            # Update the stage of this agent
            vars[["stage_customer"]][agent_id] <- "0"
        }

    # Stage 0: Moving to the cash register. 
    #
    # At this stage, we:
    #   - Check whether the agent has arrived at the cash register
    #   - Check whether they can immediately complete their goals or whether
    #     they have to wait their turn
    #   - Update to stage 1, signalling that the cashier can scan the 
    #     products
    } else if(stage == "0") {
        # When they are checking in, they should be completing a goal. 
        # Hence check for their status and for the id of their goal, which
        # should contain "checkin" in there
        if(agent_status == "completing goal") {
            # If the current goal tells them to wait their turn, then we 
            # have to check whether it is their turn or not. If they are not
            # next in queue, then we update the location of their queue
            if(agent_goal@id == "wait") {
                if(which(agent_id %in% queue) == 1) {
                    predped::current_goal(agent)@done <- TRUE

                } else {
                    turn <- which(queue == agent_id)
                    predped::current_goal(agent)@position <- positions[queue[turn - 1]]
                }

            # If their current goal tells them to check in, then that means
            # that they have started putting their items on the belt. They
            # have thus moved up a stage.
            } else if(grepl("checkin", agent_goal@id, fixed = TRUE)) {
                vars[["stage_customer"]][agent_id] <- "1"

                # Add this agent to the queue of the cashier if they're 
                # not already in it
                if(!(agent_id %in% queue)) {
                    vars[["in_line"]][[cashier]] <- c(
                        agent_id,
                        vars[["in_line"]][[cashier]]                               
                    )
                }
            }
        
        # When they are not completing a goal, it might be that they are just
        # arriving at the registry. Here, it is important to check whether 
        # someone is already being served or not. If not, then they are the
        # next customer in line. If there are others, then this customer will
        # have to wait in the queue.
        } else {
            # First, get the distance of agent to cash register. If within 
            # 5 meters, then they can start looking at the queue. Importantly,
            # they should not already be queuing
            dist_to_register <- 
                (positions[agent_id, 1] - positions[cashier, 1])^2 +
                (positions[agent_id, 2] - positions[cashier, 2])^2

            if((dist_to_register <= 5^2) & (agent_goal@id != "wait")) {
                # If there is a queue, we will give the agent the goal to 
                # wait behind the last person in the queue.
                if(length(queue) > 0) {
                    predped::goals(agent) <- append(
                        agent_goal, 
                        predped::goals(agent)
                    )
                    predped::current_goal(agent) <- wait_goal(
                        positions[queue[length(queue)], ]
                    )

                    # Add this agent to the queue of the cashier
                    if(!(agent_id %in% vars[["in_line"]][[cashier]])) {
                        vars[["in_line"]][[cashier]] <- c(
                            vars[["in_line"]][[cashier]], 
                            agent_id
                        )
                    }
                }                    
            }
        }

    # Stage 1: The customer is checking in
    #
    # At this stage, we:
    #   - Check whether the agent is done putting the items on the belt, at 
    #     which point we update to stage 2.
    } else if(stage == "1") {
        if(grepl("checkout", agent_goal@id, fixed = TRUE)) {
            vars[["stage_customer"]][agent_id] <- "2"

            # At this stage, we also need to invoke that the agents wait 
            # for the cashier to end scanning the products. We do this 
            # by giving the customers a waiting goal a bit further down the
            # line (at the position of their checkout goal).
            predped::goals(agent) <- list(agent_goal)
            predped::current_goal(agent) <- wait_goal(agent_goal@position)
        }

    # Stage 2: The customer is waiting for the cashier to end their goal.
    #
    # At this stage, we:
    #   - Check whether the cashier is done scanning the products, at 
    #     which point we update to stage 3.
    } else if(stage == "2") {
        if(vars[["stage_cashier"]][cashier] == "2") {
            vars[["stage_customer"]][agent_id] <- "3"

            # At this stage, we also need to invoke that the waiting period
            # is over.
            predped::current_goal(agent)@done <- TRUE
        }

    # Stage 3: The customer is doing the checkout.
    #
    # At this stage, we:
    #   - Check whether the customer is done with checking out, at which 
    #     point we update to stage 4.
    } else if(stage == "3") {
        if(agent_goal@id == "goal exit") {
            vars[["stage_customer"]][agent_id] <- "4"
        }
    }

    return(
        list(
            "agent" = agent,
            "vars" = vars
        )
    )
}

# Now we move on to the cashiers. 
update_cashier <- function(agent, 
                           stage,
                           vars,
                           positions) {
    
    ############################################################################
    # PRELIMINARY STUFF

    # Get some relevant variables from the agent
    agent_id <- predped::id(agent)
    agent_status <- predped::status(agent)
    agent_goal <- predped::current_goal(agent)



    ############################################################################
    # HANDLE THE DIFFERENT CASES BASED ON THE STAGE OF THE CUSTOMER

    # Stage 0: The cashier is waiting for a customer to come in.
    #
    # At this stage, we:
    #   - Check whether customers are coming to stand in line
    #   - Update the cashier's goals accordingly
    #   - Check whether a customer is loading up their products, at which 
    #     point we update to stage 1.
    if(stage == "0") {
        # First invoke that the cashier is waiting for customers instead of 
        # moving/rerouting/...
        if(agent_status != "completing goal") {
            predped::current_goal(agent) <- wait_goal(
                vars[["scanning"]][[agent_id]]
            )
            predped::status(agent) <- "completing goal"
        }

        # Check whether the first person in line with this cashier has moved 
        # to either checkin in or waiting for this cashier to scan the 
        # products. If so, then we will have to move on to the next stage
        customer <- vars[["in_line"]][[agent_id]][1]
        if(is.null(customer)) {
            # Nothing to do, nothing to see

        } else if(vars[["stage_customer"]][customer] %in% c("1", "2")) {
            vars[["stage_cashier"]][agent_id] <- "1"

            # Make sure to create a goal for scanning this customers products.
            predped::current_goal(agent) <- predped::goal(
                id = customer,
                position = vars[["scanning"]][[agent_id]],
                counter = vars[["scanning_time"]](vars[["items"]][customer]),
                path = vars[["scanning"]][[agent_id]] %>%
                    matrix(nrow = 1, ncol = 2)
            )
            predped::status(agent) <- "completing goal"

            # Add a wait goal to the cashier's goal list. They will 
            # automatically switch to this goal once they are done, allowing
            # us to easily condition on it in the next stage
            predped::goals(agent) <- list(
                wait_goal(vars[["scanning"]][[agent_id]])
            )
        }

    # Stage 1: The cashier is scanning the products.
    #
    # At this stage, we:
    #   - Check whether the cashier is done scanning, at which point we
    #     move to stage 2
    } else if(stage == "1") {
        if(agent_goal@id == "wait") {
            vars[["stage_cashier"]][agent_id] <- "2"
        }

    # Stage 2: The cashier is waiting for the customer to pay.
    #
    # At this stage, we:
    #   - Check whether the customer is done paying, at which point we
    #     update the goals of the cashier and move them back to stage 0
    } else if(stage == "2") {
        customer <- vars[["in_line"]][[agent_id]][1]
        if(vars[["stage_customer"]][customer] == "4") {
            vars[["stage_cashier"]][agent_id] <- "0"

            # Remove this customer from the list of people standing in line.
            # Allows the cashier to create new scanning goals for the next 
            # customers.
            vars[["in_line"]][[agent_id]] <- vars[["in_line"]][[agent_id]][-1]
        }
    }

    return(
        list(
            "agent" = agent,
            "vars" = vars
        )
    )
}

fx[["supermarket 2: free flow"]] <- function(state) {
    ############################################################################
    # PRELIMINARIES

    # Initiate the variables you need for bookkeeping purposes.
    if(state@iteration == 0) {
        predped::variables(state) <- list(
            # Will contain agent id's to denote who has already paid and who 
            # didn't pay yet. Will help in determining whether the agent still
            # needs to pass the cash register or not.
            "paid" = c(),

            # Will help with determining at which stage the agent is in the 
            # payment process. Either 0 (not yet checked in), 1 (checking in),
            # 2 (waiting for checkout), 3 (checking out), and 4 (done)
            "stage_customer" = c(),
            "stage_cashier" = c(
                "cashier 1" = "0",
                "cashier 2" = "0",
                "cashier 3" = "0",
                "cashier 4" = "0",
                "cashier 5" = "0",
                "cashier 6" = "0"
            ),

            # Will contain customer id's that have been assigned to a given 
            # cashier. Allows the cashier to make the relevant goals.
            "customers" = list(
                "cashier 1" = c(),
                "cashier 2" = c(),
                "cashier 3" = c(),
                "cashier 4" = c(),
                "cashier 5" = c(),
                "cashier 6" = c()
            ),
            "in_line" = list(
                "cashier 1" = c(),
                "cashier 2" = c(),
                "cashier 3" = c(),
                "cashier 4" = c(),
                "cashier 5" = c(),
                "cashier 6" = c()
            ),

            # Will contain agent id's and the number of goals they have at the 
            # beginning of the simulation. Will be used to realistically model
            # how long they will spend at the cash registers. This time is 
            # defined in seconds.
            "items" = c(),
            "checkin_time" = \(x) 2 * sum(rlnorm(x, 1, 0.25)),                             # 3sec to put stuff on belt
            "scanning_time" = \(x) 2 * (rlnorm(1, 3, 0.25) + sum(rlnorm(x, 1, 0.25))),     # 20sec to converse, 3sec to scan stuff
            "checkout_time" = \(x) 2 * (10 + sum(rlnorm(x, 1, 0.25))),                     # 10sec to pay, 3sec to put away stuff

            # Will help with assigning the goal to pass by the cash register to 
            # pay.
            "checkin" = list(
                "surface: cash register 1" = c(21, 0.62),
                "surface: cash register 2" = c(21, 1.85),
                "surface: cash register 3" = c(21, 3.15),
                "surface: cash register 4" = c(21, 4.33),
                "surface: cash register 5" = c(21, 5.59),
                "surface: cash register 6" = c(21, 6.79)
            ),

            "scanning" = list(
                "cashier 1" = c(21.9, 0.59),
                "cashier 2" = c(21.9, 1.89),
                "cashier 3" = c(21.9, 3.06),
                "cashier 4" = c(21.9, 4.36),
                "cashier 5" = c(21.9, 5.53),
                "cashier 6" = c(21.9, 6.86)
            ),

            "checkout" = list(
                "surface: cash register 1" = c(22, 0.62),
                "surface: cash register 2" = c(22, 1.85),
                "surface: cash register 3" = c(22, 3.15),
                "surface: cash register 4" = c(22, 4.33),
                "surface: cash register 5" = c(22, 5.59),
                "surface: cash register 6" = c(22, 6.79)
            )
        )
    }

    # Read the variables of the state
    vars <- predped::variables(state)

    # Get all positions of the agents
    positions <- sapply(
        state@agents, 
        predped::position
    ) %>%
        t()
    rownames(positions) <- sapply(state@agents, predped::id)



    ############################################################################
    # CASHIER - CUSTOMER INTERACTION

    # Loop over all agents to determine what they should do next
    agent_list <- predped::agents(state)
    for(i in seq_along(agent_list)) {
        agent_id <- agent_list[[i]]@id

        # Check whether the agent in question is a customer or a cashier. Both
        # Will be handled in another way.
        #
        # Case of the customer
        if(!grepl("cashier", agent_id, fixed = TRUE)) {
            result <- update_customer(
                agent_list[[i]],
                vars[["stage_customer"]][agent_id],
                vars,
                positions
            )

            
        # Case of the cashier
        } else {
            result <- update_cashier(
                agent_list[[i]],
                vars[["stage_cashier"]][agent_id],
                vars,
                positions
            )
        }

        agent_list[[i]] <- result$agent
        vars <- result$vars
    }

    # Update the necessary lists
    predped::agents(state) <- agent_list
    predped::variables(state) <- vars

    return(state)
}

fx[["supermarket 2: restricted"]] <- fx[["supermarket 2: free flow"]]