# Author: Busra Atamer Balkan, Colin Teberg
# Updated on January 30, 2024 

# Code for curating and calculating the risk summary data
# for the SSO experiments


library(dplyr)
library(tidyr)
options(digits=22)


get_risk_of_infection <- function(infectious_agent_ids=c('A_1'), nr_of_replications=1, average_emission=10^6, 
                                  time_step=1/120, surfaceExposureRatio=0.01, lambda_50=10**(6.8), 
                                  alpha=0.332, experiment_dir="/output") {
  # Define dose-response function --------------------------------------------------
  Hill.function <- function(exposure, alpha, lambda){
    (( exposure) ^alpha)/(lambda^alpha + ( exposure)^alpha)
  }
  
  analysis_dir <- getwd()
  experiment <- paste(analysis_dir, experiment_dir, sep="")
  
  # get list of replications ------------------------------------------------
  replicationNrList <- list.files (path = experiment)
  
  # set working directory for experiments -----------------------------------
  setwd(experiment)
  
  # read the exposures for each replication for each agent, and excludes the 
  # infectious agent in each replication ------------------------------------
  i = 1
  agent_exposure <- data.frame()
  for (i in 1:nr_of_replications) {
    if (nr_of_replications > 1) {
      setwd(replicationNrList[i])
    }
    agent_exposure_temp <- read.csv("agent_exposure.csv")
    infectious_surface_i <- max(agent_exposure_temp$Accumulated.Contamination.Load.Surface)
    agent_exposure_temp <- agent_exposure_temp %>% 
      mutate(replicationNr = replicationNrList[i])
    agent_exposure_i <- assign(paste0("agent_exposure_", replicationNrList[i]), agent_exposure_temp)
    agent_exposure_i <- filter(agent_exposure_i, ! Agent %in% infectious_agent_ids)
    agent_exposure <- rbind(agent_exposure,agent_exposure_i)
    setwd(experiment)
  }
  
  # pivot the agent_exposure data by summing up the exposures from each route
  # and create riskSummary data frame ---------------------------------------
  agent_exposure %>% 
    group_by(replicationNr, Agent) %>% 
    summarise(ExposureA = sum(`Contamination.Load.Aerosol`), 
              ExposureD = sum(`Contamination.Load.Droplet`),
              ExposureF = sum(`Accumulated.Contamination.Load.Surface`)*time_step*surfaceExposureRatio) -> riskSummary
  
  #calculate Total Exposure -------------------------------------------------
  riskSummary <- riskSummary %>% mutate(TotalExposure = (ExposureA+ExposureD)*average_emission)
  
  # risk calculation for each agent
  riskSummary <- riskSummary %>% 
    mutate(RiskOfInfection = Hill.function(exposure = TotalExposure, alpha = alpha, lambda = lambda_50))
  
  infectionRisk <- riskSummary[, c('Agent', 'RiskOfInfection')]
  return(infectionRisk)
  
}

setwd('/home/colin/src/smallscalecorona')
risk = get_risk_of_infection(c('H_1'))
write.csv(risk, 'risk_of_infection.csv', row.names=FALSE)
