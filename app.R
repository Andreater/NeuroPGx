# Libraries ----
source("libraries.R")
# Scripts ----
source("core.R")
source("mypl1.R")
source("mypl2.R")

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
                                                  tabPanel(title = "EHR", withSpinner(plotOutput(outputId = "ehr1")))
                                           )
                                  )
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
    
    # Output head with loading screen
    output$ac <- renderDT({ac() 
    }, options = list(pageLength = 5), 
       filter  = "top")
    
    # Download button for output
    output$download_button <- renderUI({
        req(ac())
        downloadButton(outputId = "download_item", 
                       label    = "Download .csv") })
    
    # Download operation
    output$download_item <- downloadHandler(filename    = function() {paste("data-",Sys.Date(), ".csv", sep = "")},
                                            content     = function(file) {write.csv(ac(), file)},
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