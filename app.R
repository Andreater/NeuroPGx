# Libraries ----
source("libraries.R")
# Scripts ----
source("core.R")
source("mypl1.R")
source("mypl2.R")
source("suggestion.R")

# User interface ----
ui <- dashboardPage(dashboardHeader(title = "NeuroPGx"),
                    dashboardSidebar(fileInput(inputId = "file",
                                               label   = "Load Data",
                                               accept  = c(".csv", ".tsv", ".xlsx"))
                    ),
                    dashboardBody(fluidRow(tabBox(title  = "About",
                                                  id     = "tabset2",
                                                  tabPanel(title = "Workflow",
                                                           width = 6,
                                                           status = "info",
                                                           fluidRow(column(width = 6, align = "center", tags$img(src = "Workflow image.svg")),
                                                                    column(width = 6, h4("How to use"),
                                                                                      p(style="text-align: justify;",
                                                                                      "Please upload an input file using the browse button on the sidebar.
                                                                                         Refer to the sample input files in the samples directory to prepare your input file.",br(), 
                                                                                        "The software will run even if you miss genotype info for some of the five core genes.",br()),
                                                                                        p(style="text-align: justify;",
                                                                                          "Export the results using the download buttons below each result box.")))),
                                                  tabPanel(title  = "Software Description",
                                                           width  = 6,
                                                           status = "info",
                                                           p(style="text-align: justify;",
                                                             "NeuroPGx software performed the automated identification of all possible diplotypes
                                                             compatible with genotypes at each CYP gene included in the virtual NeuroPGx Panel.
                                                             Basing on population characteristics, the software selects the most likely diplotype-phenotype.
                                                             Otherwise, all possible diplotype-phenotype combinations were identified and reported in the output file.",br(),
                                                             "The NeuroPGx software output files provide information about:",
                                                             tags$ol(
                                                                 tags$li("the genotypes at evaluated SNPs."), 
                                                                 tags$li("the main diplotypes at CYP genes and corresponding metabolization phenotypes."), 
                                                                 tags$li("the list of possible (rare) diplotypes and corresponding metabolization phenotypes."))),
                                                           p(tags$a(href="https://cpicpgx.org/", "CPIC guidelines"),
                                                             "(last accession: 30 May 2021)", br(),
                                                             tags$a(href="https://www.pharmgkb.org/page/dpwg", "DPWG guidelines"),
                                                             "(last accession: 30 May 2021)"))),
                                           box(title  = "Samples",
                                               status = "primary",
                                               width  = 6,
                                               withSpinner(DTOutput(outputId = "sample")))),
                                  fluidRow(box(title  = "Assigned Diplotypes",
                                               status = "success",
                                               width  = 6,
                                               withSpinner(DTOutput(outputId = "ac")),
                                               uiOutput(outputId = "download_button")),
                                           tabBox(title  = "Plots",
                                                  id     = "tabset1",
                                                  tabPanel(title = "Phenotype", withSpinner(plotOutput(outputId = "phn1"))),
                                                  tabPanel(title = "EHR", withSpinner(plotOutput(outputId = "ehr1"))))),
                                  fluidRow(box(title  = "Suggested drug w/o interactions",
                                               status = "info",
                                               width  = 6,
                                               withSpinner(DTOutput(outputId = "plain")),
                                               uiOutput(outputId = "download_plain")),
                                           box(title  = "Suggested drug with interactions",
                                               status = "info",
                                               width  = 6,
                                               withSpinner(DTOutput(outputId = "interaction")),
                                               uiOutput(outputId = "download_interaction")))
                    ),
                    skin = "green"
)

# Server logic ----
server <- function(input, output) {
    # Sample input
    data <- reactive({
        req(input$file)
        
        ext <- tools::file_ext(input$file$name)
        switch(ext,
               xlsx = read.xlsx(input$file$datapath),
               csv  = vroom::vroom(input$file$datapath, delim = ","),
               tsv  = vroom::vroom(input$file$datapath, delim = "\t"),
               validate("Invalid file; Please upload a .xlsx, .csv or .tsv file"))
    })
    
    # Sample preview
    output$sample <- renderDT({data()}, options = list(pageLength = 5), filter = "top")
    
    # Output production
    ac <- reactive({diplo_assign(input = data(), pheno = pheno, frq = frq, altab = altab)})
    
    ## Drug list
    drug.list <- reactive({pharm_sum(data = ac(), 
                                     comb_drugs  = comb_drugs,
                                     diplo_drugs = diplo_drugs,
                                     pheno_drugs = pheno_drugs)})
    
    # Output head with loading screen
    output$ac <- renderDT({ac()}, 
                          options = list(pageLength = 5), 
                          filter  = "top")
    
    output$plain <- renderDT({drug.list()[[1]]},
                             options = list(pageLength = 5), 
                             filter  = "top")
    
    output$interaction <- renderDT({drug.list()[[2]]},
                                   options = list(pageLength = 5), 
                                   filter  = "top")
    
    # Download buttons
    output$download_button <- renderUI({
        req(ac())
        downloadButton(outputId = "download_item", 
                       label    = "Download .csv") })
    
    output$download_plain <- renderUI({
        req(drug.list())
        downloadButton(outputId = "download_item_plain", 
                       label    = "Download .csv") })
    
    output$download_interaction <- renderUI({
        req(drug.list())
        downloadButton(outputId = "download_item_interaction", 
                       label    = "Download .csv") })
    
    # Download operation
    output$download_item <- downloadHandler(filename    = function() {paste("data-",Sys.Date(), ".csv", sep = "")},
                                            content     = function(file) {write.csv(ac(), file, row.names = FALSE)},
                                            contentType = ".csv")
    
    output$download_item_plain <- downloadHandler(filename    = function() {paste("plain-",Sys.Date(), ".csv", sep = "")},
                                                  content     = function(file) {write.csv(drug.list()[[1]], file, row.names = FALSE)},
                                                  contentType = ".csv")
    
    output$download_item_interaction <- downloadHandler(filename    = function() {paste("interaction-",Sys.Date(), ".csv", sep = "")},
                                                        content     = function(file) {write.csv(drug.list()[[2]], file, row.names = FALSE)},
                                                        contentType = ".csv")
    
    # Pheno summary plot
    pl1 <- reactive({pheno_sum(data = ac())})
    
    # Show plot
    output$phn1 <- renderPlot({pl1()})
    
    # EHR summary plot
    pl2 <- reactive({ehr_sum(data = ac())})
    
    # Show plot
    output$ehr1 <- renderPlot({pl2()})
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
