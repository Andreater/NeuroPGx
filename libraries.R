options(warn=-1) # this disables warning
####Libraries####
cra.pack = c("shinydashboard", "shiny", "DT", "tidyverse", "openxlsx", "shinycssloaders", "vroom", "ggplot2")

for(p in cra.pack){
  if(!require(p, character.only = TRUE, warn.conflicts = FALSE, quietly = TRUE)) install.packages(p, quiet = TRUE)
  suppressPackageStartupMessages(library(p,character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE))
}

rm(p, cra.pack)



