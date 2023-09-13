config <- readRDS("~/GitHub/R-cometsAnalytics/Tutorial/catutorial.rds")
config$`01-quickstart.Rmd` <- "01-DataPreparation.Rmd"
config$`02-stepbystep.Rmd` <- "02-ConductingCohortAnalyses.Rmd"
config$`03-manual.Rmd` <- "03-ConductingAdvancedAnalyses.Rmd"

saveRDS(config,"~/Github/R-cometsAnalytics/Tutorial/catutorial.rds")