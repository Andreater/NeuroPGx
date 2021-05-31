# References ----
altab = readRDS(file = "data/reference/altab.RDS")
frq   = readRDS(file = "data/reference/frq.RDS")
pheno = readRDS(file = "data/reference/pheno.RDS")

# Diplo assignment ----
diplo_assign <- function(input, altab, frq, pheno) {
  #####Input preparation####
  
  # arrangiato e omessi i na
  input = input %>%
    mutate(Genotype = ifelse(Genotype == "-/-", "del/del", Genotype)) %>% # This string deals with deletions
    arrange(Sample, Gene, rsID) %>% 
    na.omit()
  
  # splittato in funzione del gene
  input.list = split(input, f = input$Gene) 
  
  # Sample names
  samp.names = unique(input.list$CYP2B6$Sample)
  
  ####altab preparation####
  for (gene in 1:length(altab)) {
    # qui bisognerà costruire un loop per mettere in long format tutti i codici con i relativi alleli uno alla volta
    temp = 
      altab[[gene]] %>% 
      pivot_longer(cols = starts_with("rs"), names_to = "rsID", values_to = "Al") %>% 
      na.omit() 
    
    # qui viene calcolato il numero di alleli necessari all'assegnazione del codice
    temp = temp %>% 
      group_by(Allele) %>% 
      mutate(nSNP = n()) %>%
      ungroup()
    
    # store the result
    altab[[gene]] = temp
  }
  
  rm(temp, gene)
  
  ####Mapping to allele table####
  # Temporary objects for storing genotype infos (homo/hete) and possible aplotypes codes
  aplo.list = vector(mode = "list", length = length(input.list))
  het.list  = vector(mode = "list", length = length(input.list))
  names(aplo.list) = names(input.list)
  names(het.list)  = names(input.list)
  
  ## Manual check of samples // do this on input list
  # gene   = 5
  # sample = 1
  
  # This loop coded all the possible codes based on genotype and saved genotype infos
  for (gene in 1:length(input.list)) {
    prova = input.list[[gene]] %>%
      mutate(homo = ifelse(word(Genotype, sep = "/") == word(Genotype, start = 2, sep = "/"), "homo", "het"))
    
    code = prova %>% 
      separate(col = Genotype, into = c("Al1", "Al2")) %>% 
      left_join(altab[[gene]], by = c("Gene", "rsID")) %>%
      na.omit() %>%  
      arrange(Sample, rsID, Allele)
    
    code = code %>% 
      mutate(code = case_when(homo == "homo" & Al1 == Al ~ 1,
                              homo == "het" & Al1 == Al ~ 1,
                              homo == "het" & Al2 == Al ~ 1,
                              TRUE ~ 0)) %>% 
      group_by(Sample, Gene, Allele) %>% 
      summarise(n    = sum(code),
                nSNP = mean(nSNP)) %>% 
      filter(n == nSNP) %>% 
      ungroup()
    
    aplo.list[[gene]] = code %>% mutate(index = NA_character_)
    het.list[[gene]]  = prova
  }
  
  # Get back to a single dataframe
  aplo = aplo.list %>% reduce(bind_rows)
  
  # cleaning
  rm(prova, gene, code)
  ####Creating Diplotypes####
  # Split in a coded.list based on Sample and Gene // MAYBE WE SHOULD ADD THE DIVISION BY RSID?
  diplo.list = split(aplo, f = list(aplo$Sample, aplo$Gene))
  
  for (i in 1:length(diplo.list)) {
    # Build a dataframe with each possibile combination by sample and gene
    temp = unite(do.call(expand.grid, rep(list(diplo.list[[i]][["Allele"]]), 2)), col = Diplotype, Var1, Var2, sep = "/")
    
    # Build a temp dataframe with name and gene repeated n times (nrows of temp)
    temp1 = data.frame(Sample     = rep(diplo.list[[i]]$Sample[1], nrow(temp)),
                       Gene       = rep(diplo.list[[i]]$Gene[1], nrow(temp)))
    
    # Bind them again
    diplo.list[[i]] = bind_cols(temp1, temp)
  }
  
  rm(temp, temp1, i, aplo, aplo.list)
  ####Filtering Diplotypes####
  diplo = diplo.list %>% reduce(bind_rows)
  #rm(diplo.list)
  
  het = het.list %>% reduce(bind_rows)
  #rm(het.list)
  
  altab = altab %>%
    reduce(bind_rows) %>% 
    dplyr::select(-nSNP)
  
  het = het %>%  
    dplyr::select(Sample, Gene, rsID, homo) %>% 
    distinct()
  
  diplo = left_join(diplo, het, by = c("Sample", "Gene"))
  
  diplo = diplo %>% 
    dplyr::select(Sample, Gene, rsID, homo, Diplotype) %>% 
    separate(col    = Diplotype,
             into   = c("Aplo1", "Aplo2"),
             remove = FALSE,
             sep    = "/") %>% 
    pivot_longer(cols = c("Aplo1", "Aplo2"),
                 names_to = "junk",
                 values_to = "Allele")
  
  diplo = left_join(diplo, altab, by = c("Gene", "rsID", "Allele"))
  
  # Reconstruct Genotype
  diplo = diplo %>%
    dplyr::select(-c(junk)) %>% 
    group_by(Sample, Gene, Diplotype, rsID) %>% 
    mutate(Genotype = paste(lag(Al), Al)) %>% 
    filter(str_detect(Genotype, "NA", negate = TRUE)) %>% 
    ungroup()
  
  # Filter at SNP level
  diplo = diplo %>% 
    dplyr::select(-c(Allele, Al)) %>% 
    mutate(index = case_when(homo == "het"  & word(Genotype, start = 1) == word(Genotype, start = 2) ~ "Discard",
                             homo == "het"  & word(Genotype, start = 1) != word(Genotype, start = 2) ~ "Keep",
                             homo == "homo" & word(Genotype, start = 1) == word(Genotype, start = 2) ~ "Keep",
                             TRUE ~ "Other")) 
  # Filter at Gene level
  diplo = diplo %>% 
    group_by(Sample, Gene, Diplotype) %>% 
    mutate(index2 = ifelse("Discard" %in% index, "Disc", "k")) %>% 
    ungroup()
  
  # Filtering
  diplo = diplo %>% 
    filter(index2 == "k")
  ####Phenotype Assignation####
  # Inner filtering during the innerjoin
  diplo = inner_join(diplo, pheno, by = c("Gene", "Diplotype")) %>%
    arrange(Sample, Gene, Diplotype) %>%
    filter(Diplotype_Phenotype_summary != "Indeterminate")
  
  # remove duplicate rows
  diplo = diplo %>% 
    dplyr::select(-c(index, index2, Genotype, homo, rsID)) %>% 
    distinct()
  ####Diplotypes frequencies estimation####
  for (i in 1:length(frq)) {
    # Build a dataframe with each possibile combination by sample and gene
    temp = unite(do.call(expand.grid, rep(list(frq[[i]][["Allele"]]), 2)), col = Diplotype, Var1, Var2, sep = "/", remove = FALSE)
    
    # Frequencies for diplotype
    temp = temp %>% 
      dplyr::rename(Al1 = Var1,
                    Al2 = Var2) %>% 
      pivot_longer(cols = c("Al1", "Al2"),
                   names_to = "junk",
                   values_to = "Allele") %>% 
      dplyr::select(-junk) %>% arrange(Diplotype)
    
    # Bind with frequencies
    temp = left_join(frq[[i]], temp, by = "Allele") %>% arrange(Diplotype)
    
    # Obtain the frequencies for diplotype
    temp = temp %>% 
      group_by(Diplotype, Gene) %>% 
      summarise(EUR = round(EUR * lag(EUR),2), .groups = 'drop')
    
    # Sort the result
    frq[[i]] = temp
  }
  
  rm(temp,  i)
  
  frq = frq %>% 
    reduce(bind_rows) 
  
  # THIS STRING REMOVES DIPLOTYPE WITOUTH KNOWN FREQUENCIES IN THE POPULATION OF INTEREST
  # IF YOU WANT TO TAKE A LOOK WITH THE NA PLESE USE LEFT_JOIN
  diplo = inner_join(diplo, frq, by = c("Gene", "Diplotype"))
  
  # Correcting some problems with presentation
  diplo = diplo %>% mutate(Diplotype_Phenotype_summary =  str_replace_all(Diplotype_Phenotype_summary,
                                                                          c("CYP2B6"  = "", 
                                                                            "CYP2C19" = "",
                                                                            "CYP2D6"  = "",
                                                                            "CYP3A5"  = "",
                                                                            "CYP2C9"  = "")) %>% str_squish()) %>% 
    rename(Phenotype = Diplotype_Phenotype_summary)
  
  diplo = diplo %>% 
    mutate(EHR_Priority = str_remove_all(EHR_Priority, " "))
  ####Assigned diplotype summarization####
  ac = diplo %>% 
    group_by(Sample, Gene) %>% 
    arrange(-EUR) %>% 
    mutate(MP  = row_number(),
           EUR = ifelse(EUR > 1, 1, EUR)) %>% 
    arrange(Sample, Gene, MP) %>% 
    filter(MP == 1) %>% 
    dplyr::select(-MP) %>% 
    ungroup()
}