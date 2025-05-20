devtools::load_all()
source(file.path("environments.R"))
source(file.path("initial_agents.R"))
source(file.path("fx.R"))

my_model <- predped::predped(
    setting = environments[["supermarket 2: free flow"]],
    archetypes = "BaselineEuropean"
)


start_time <- Sys.time()
Rprof(interval = 0.001)
set.seed(1)
trace <- predped::simulate(
    my_model,
    iterations = 1000,
    goal_number = 1,
    add_agent_after = 5,
    fx = fx[["supermarket 2: free flow"]],
    # initial_agents = trace[[100]]@agents,
    initial_agents = initial_agents[["supermarket 2: free flow"]],
    space_between = 0.3
)
stop_time <- Sys.time()
Rprof(NULL)
summaryRprof()

stop_time - start_time

saveRDS(trace, "test.gif")


plots <- predped::plot(trace, dark_mode = TRUE)
gifski::save_gif(
    lapply(plots, \(x) print(x)),
    file.path("test.gif"),
    delay = 1/10,
    progress = FALSE
)
