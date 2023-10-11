## Application: Data munging from SoftMax Pro ELISA reader output

## Author: Anna Bird

packages = c("shiny", "shinythemes",
             "readr", "tidyverse",
             "writexl", "readxl", 
             "patchwork", "scales",
             "strex")

## Now load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = shinytheme("simplex"),

    # Application title
    titlePanel("ELISA data cleaner"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          helpText("App Instructions:
                     1) Upload SoftMaxPro ELISA reader output
                     2) Check graph to see if OD and conc are linearly related
                     3) Download data"),
          br(),
          helpText("Note: If you have 2+ data tables from 2+ plates, 
                   paste tables stacked vertically into one file for import"),         
          br(),         
          
            fileInput("file",
                      "Upload file\n(.csv, .txt, or .xlsx)",
                      #multiple = TRUE,
                      accept=c(".xlsx", ".csv", "text/csv")),
            # br(),
            # helpText(" Download format"),
            # radioButtons("type", "Format type:",
            #              choices = c("Excel (CSV)", "Text (TSV)", "Text (space sep)", "Doc")),
            br(),
            helpText(" Click the dwnload button to dwnload dataset"),
            downloadButton('downloadData', 'Download')
            
        ),

        # Show a plot of the generated distribution
        mainPanel(          
          plotOutput("plot"),            
          helpText(" Cleaned data table below. Variable 'Condition_ID\' was extracted from the Unknowns list. Condition_ID can be used to join ELISA data w/ metadata."),
          tableOutput('table')
        )
    )
)
df <- read_excel("Sample_ELISA_data.xlsx")
# Define server logic required to draw a histogram
server <- function(input, output) {

    data <- reactive({
      file1 <- input$file
    if(is.null(file1)) {
      return()
    } else { 
                if (any(str_detect(file1, ".xlsx$"))) {
                df <- read_excel(file1$datapath) 
              } else if (any(str_detect(file1, ".csv$"))) {
                df <- read_csv(file1$datapath)   
              } else if (any(str_detect(file1, ".txt$"))) {
                df <- read_tsv(file1$datapath)  
              } 
      
      df %>%
        tidyr::fill(Sample, AvgConc, SD, CV, Dilution, AdjConc) %>%
        filter(!Sample %in% "Sample") %>%
        mutate("Condition_ID" = as.character(strex::str_extract_numbers(Sample, decimals = TRUE))) %>%
        mutate_at(., vars(Condition_ID, OD, Conc), as.numeric) %>%
        mutate_at(., vars(Dilution), as.factor) %>%
        mutate("unadj. conc" = Conc) %>%
        mutate("unadj. conc" = ifelse(is.na(Conc) & OD < 0.1, 0, `unadj. conc`) ) %>%
        mutate("unadj. conc" = ifelse(is.na(Conc) & OD > 0.6, NA, `unadj. conc`) %>% round(., 5)) %>%
        mutate(`AnalyteConc` = `unadj. conc`*as.numeric(as.character(Dilution))) %>%
        select(-c(AvgConc, SD, AdjConc)) %>%
        arrange(Condition_ID) %>%
        select(Condition_ID, Sample, everything())
      
      }
    })
    
  output$plot <- renderPlot({
    ggplot(data = data()) +
      geom_point(size = 2.5, alpha = 0.7, shape = 21, color = "black",
                 mapping = aes(x = OD, y = Conc, fill=factor(Dilution))) +
      scale_y_continuous() +
      scale_x_log10() +
      scale_y_log10() +
      labs(title = "Concentration vs. OD",
           subtitle = "Check that data are linearly related\ni.e. where change of OD predicts change of conc.",
           x = "log10 OD",
           y = "log10 conc \n(unadjusted for dilution factor)",
           fill = "Dilution\nfactor") +
      scale_fill_viridis_d()

    p.1 <- data() %>%
      filter(`CV` != "Range?") %>%
      mutate_at(vars(CV, OD), as.numeric) %>%
      ggplot(., aes(CV/100, OD)) +
      geom_point(color = "dodgerblue4") +
      geom_text(aes(label = ifelse(CV > 20, Condition_ID, "")),
                hjust = 1.2,
                vjust = 0.5) +
      labs(title = "Note assay conditions with high CV",
           subtitle = "Point tags indicate \'Condition_ID\'. Points with \nthe same Condition_ID are replicates.",
           x = "coef. of var.") +
      scale_x_continuous(labels = percent_format())

    p.2 <- ggplot(data = data()) +
      geom_point(size = 2.5, alpha = 0.7, shape = 21, color = "black",
                 mapping = aes(x = OD, y = Conc, fill=factor(Dilution))) +
      scale_y_continuous() +
      scale_x_log10() +
      scale_y_log10() +
      labs(title = "Concentration vs. OD",
           subtitle = "Check that data are linearly related\ni.e. OD predicts conc. for data \nwithin assay detection range",
           x = "log10 OD",
           y = "log10 conc \n(unadjusted for dilution factor)",
           fill = "Dilution\nfactor") +
      scale_fill_viridis_d()

    p.1 + p.2


    })

    
  output$dataset <- renderTable({
    if(is.null(data())) {return ()}
    input$file

  })
    
  output$table <- renderTable({   # show data set based on ui selection and data match in server/dataInput()
    if(is.null(data())){return ()}
    data()
  })
    
  output$downloadData <- downloadHandler(
    
    filename = function() {
      paste0(str_remove(input$file, ".xlsx"), "_D2.xlsx")
    },

    content = function(file) {

      write_xlsx(data(),
                  file)
      
    }
    
    
  )
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
