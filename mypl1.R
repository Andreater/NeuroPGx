pheno_sum <- function(data) {
  data %>% 
    ggplot() +
    aes(x = Sample, fill = Phenotype) +
    geom_bar() +
    scale_fill_manual(values = list(`Intermediate Metabolizer` = "#40C2B3", 
                                    `Normal Metabolizer`       = "#31B425",
                                    `Poor Metabolizer`         = "#F90101", 
                                    `Rapid Metabolizer`        = "#1716C7")) +
    coord_flip() +
    labs(title = "",
         y     = "",
         fill  = "") +
    theme_bw() +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank()) +
    facet_wrap(vars(Gene))
}