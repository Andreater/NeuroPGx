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
                    dashboardBody(fluidRow(box(title  = "How it works",
                                               width  = 6,
                                               status = "info",
                                               "Box content Probably infos"),
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
                                            content     = function(file) {write.csv(ac(), file)},
                                            contentType = ".csv")
    
    output$download_item_plain <- downloadHandler(filename    = function() {paste("plain-",Sys.Date(), ".csv", sep = "")},
                                                  content     = function(file) {write.csv(drug.list()[[1]], file)},
                                                  contentType = ".csv")
    
    output$download_item_interaction <- downloadHandler(filename    = function() {paste("interaction-",Sys.Date(), ".csv", sep = "")},
                                                        content     = function(file) {write.csv(drug.list()[[2]], file)},
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