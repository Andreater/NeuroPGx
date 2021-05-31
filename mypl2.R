ehr_sum <- function(data) {
  data %>% 
  ggplot() +
    aes(x = Sample, fill = EHR_Priority) +
    geom_bar() +
    scale_fill_hue(direction = 1) +
    coord_flip() +
    labs(title = "",
         y     = "",
         fill  = "") +
    theme_bw() +
    theme(axis.text.x = element_blank(),
          axis.ticks.x = element_blank()) +
    facet_wrap(vars(Gene))
}