# References ----
load(file = "data/reference/drugs.rdata")

####Fix reference issues####
comb_drugs$Outcome = comb_drugs$Outcome %>% stringr::str_remove_all(pattern = "[\r\n]") %>% stringr::str_squish()

####Preprocess data####
pharm_sum <- function(data, comb_drugs, diplo_drugs, pheno_drugs) {
  data = data %>% 
    mutate(Phenotype1 = case_when(Phenotype == "Intermediate Metabolizer" ~ "IM",
                                  Phenotype == "Poor Metabolizer" ~ "PM",
                                  Phenotype == "Normal Metabolizer" ~ "NM",
                                  Phenotype == "Rapid Metabolizer" ~ "RM"))
  
  sample.list = split(data, f = data$Sample)
  
  ####Combined output####
  combined = vector(mode = "list", length = length(sample.list))
  
  # Create combinations for each sample
  for (subject in 1:length(sample.list)) {
    grid = expand.grid(sample.list[[subject]]$Gene,
                       sample.list[[subject]]$Gene,
                       sample.list[[subject]]$Phenotype1,
                       sample.list[[subject]]$Phenotype1) %>% 
      distinct() %>% 
      mutate(gene_index  = ifelse(Var1 == Var2, "discard", "keep"),
             pheno_index = ifelse(Var3 == Var4, "discard", "keep")) %>% 
      unite(col = "Combined_genes", c("Var1", "Var2"), sep = "_") %>% 
      unite(col = "Combined_phenotype", c("Var3", "Var4"), sep = "_") %>% 
      filter(gene_index == "keep" & pheno_index == "keep") %>% 
      dplyr::select(-c(gene_index, pheno_index)) %>% 
      mutate(Sample = names(sample.list)[subject])
    
    grid = inner_join(grid, comb_drugs, by = c("Combined_genes", "Combined_phenotype"))
    grid = grid[1:(nrow(grid)/2) ,] # It removes half of the dataset to get rid of duplicates from expand.grid Watch out
    
    combined[[subject]] = grid %>%
      dplyr::select(Sample, everything()) %>% 
      arrange(Combined_genes, Combined_phenotype, Drug, Source)
  }
  
  # Final combined Dataframe
  combined = combined %>% 
    reduce(bind_rows) %>% 
    filter(Outcome != "not available") %>% 
    rename(Gene = Combined_genes,
           Phenotype = Combined_phenotype)
  
  rm(subject, grid, comb_drugs, sample.list)
  
  ####Plain Output####
  
  ## Diplo_data from Diplo_drugs
  diplo_data = inner_join(data, diplo_drugs, by = c("Gene", "Diplotype"))
  
  diplo_data = diplo_data %>% 
    dplyr::select(Sample, Gene, Diplotype, Drug, Source, Outcome) %>% 
    rename(Phenotype = Diplotype)
  
  ## Pheno_data from Pheno_drug
  pheno_data = inner_join(data, pheno_drugs, by = c("Gene", "Phenotype1"))
  
  pheno_data = pheno_data %>% 
    dplyr::select(Sample, Gene, Phenotype1, Drug, Source, Outcome) %>% 
    rename(Phenotype = Phenotype1)
  
  plain = bind_rows(pheno_data, diplo_data)
  
  plain = plain %>% 
    filter(Outcome != "not available") %>%
    arrange(Sample, Gene, Drug)
  
  rm(data, diplo_data, diplo_drugs, pheno_data, pheno_drugs)
  
  drug.list = list(plain = plain, combined = combined)
  
  return(drug.list)
}
