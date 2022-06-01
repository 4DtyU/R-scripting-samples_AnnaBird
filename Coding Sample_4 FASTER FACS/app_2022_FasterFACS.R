## Application:   FASTER FACS Shiny App
## Purpose:       Convert raw FlowJo statistical output to plot-ready tables in seconds

## Author: Anna Bird


packages = c("shiny", "shinythemes",
             "readr", "tidyverse",
             "writexl", "jcolors",
             "readxl", "openxlsx",
             "formattable", "knitr",
             "kableExtra")

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

theme_set(theme_bw(base_family = "Helvetica"))
theme_update(strip.background = element_rect(color="white", fill="#FFFFFF", size=0), 
             strip.text = element_text(colour = 'black', size = 12, face = "bold", hjust = 0),
             plot.tag = element_text(color = "ivory", hjust = 1, size = 8))

toGreek <- function(x) {    #use library(stringi) ... 
  
  x <- gsub("alpha", "\u03b1", x) # English to unicode
  x <- gsub("beta", "\u03b2", x)
  x <- gsub("gamma", "\u03b3", x)
  #x <- gsub("delta", "\u03b4", x)
  x <- gsub("epsilon", "\u03b5", x)
  x <- gsub("zeta", "\u03b6", x)
  x <- gsub("ug/mL", "\u03bcg/mL", x) 
  x <- gsub("uL", "\u03bcL", x)
}

toGreekLiteral <- function(x) {   
  
  x <- gsub("ug/mL", "??g/mL", x) 
  x <- gsub("alpha", "??", x)            
  x <- gsub("beta", "??", x)
  x <- gsub("gamma", "??", x)
  #x <- gsub("delta", "??", x)
  x <- gsub("epsilon", "??", x)
  x <- gsub("zeta", "??", x)
  x <- gsub("ug/mL", "??g/mL", x) 
  x <- gsub("uL", "??L", x)
}

greek_fix <- function(df) {
  df <- df %>% dplyr::mutate(across(is.character, toGreek))
  names(df) <- as.list(names(df)) %>% map_chr(., ~ toGreekLiteral(.x))
  df
}

ui <- fluidPage(
  theme = shinytheme("simplex"),

    # Application title
    titlePanel("Faster FACS Stats"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          helpText("Expedite FACS Stats Processing!"),
          br(),
          helpText(p(" Instructions:
                    (1) Upload FlowJo stats & metadata files
                    (2) Download formatted data", style="color:black;text-align:justify"),
                   p("Recommended: View app tabs to check that the DIVA Specimens paired correctly with the metadata",style="color:black;text-align:justify")),         
          br(),         
          
            # fileInput("file",
            #           "Upload file\n(.csv, .txt, or .xlsx)",
            #           #multiple = TRUE,
            #           accept=c(".xlsx", ".csv", "text/csv")),
          
          
          fileInput("flowjo_file",
                    "Choose FlowJo stats file (.xlsx or .csv)",
                    multiple = FALSE,
                    accept=c('.xlsx',
                             'text/csv', 
                             'text/comma-separated-values,text/plain', 
                             '.csv')),
          fileInput("metadata_file",
                    "Choose metadata file (.xlsx or .csv)",
                    multiple = FALSE,
                    accept=c('.xlsx',
                             'text/csv', 
                             'text/comma-separated-values,text/plain', 
                             '.csv')),
            br(),
            helpText("Download data in 3 formats", style="color:black;text-align:justify"),
            downloadButton('downloadData', 'Download')
            
        ),

        # Show a plot of the generated distribution
        mainPanel(          
          tabsetPanel(
            tabPanel("Plots",
                     helpText("If DIVA Specimen layout does not look correct, 
                              DIVA Specimen numbers may not pair correctly with metadata.",style="color:black;text-align:justify"),
                     plotOutput("plot")
                     ),            
            tabPanel("Long format (BI software)",
                     helpText("Data below are in long format, i.e. 1 row = 1 observation. 
                     Variable 'Specimen_ID\' was extracted from the DIVA \'Specimen\' column.",style="color:black;text-align:justify"),
                     tableOutput('table_long')),
            tabPanel("Wide format (Prism)", verbatimTextOutput("summary"),
                     helpText("Variable 'Specimen_ID\' is the DIVA \'Specimen\' number (eg. \'Specimen_038_C9_C09_040.fcs\' becomes Specimen_ID = 38.
                              These numbers were used as a joining variable to pair FACS stats to associated metadata.
                              In the table below, the index \'1,2,3,4...etc. \' in the \'assay_vars\' column indicate technical replicates.",style="color:black;text-align:justify"),
                     tableOutput('table_wide')),
            tabPanel("Detailed Instructions",
                     
                     fluidRow(column(width=2, icon("hand-point-right","fa-5x"),align="center"),
                              column(
                                br(),
                                p("The purpose of this application is to expedite clean-up of FlowJo-exported statistics.",style="color:black;text-align:justify"),
                                p("Inputs include one FlowJo-exported statistics table & one metadata table.
                                  The app will clean and join FACS stats to metadata, converting raw stats into a downloadable table output for either
                                  GraphPad Prism or business intelligence (BI) software (e.g. Tableau, Spotfire).", style="color:black;text-align:justify"),
                                br(),
                                p("Formatting requirements:",style="color:black;text-align:justify"),
                                p("1) EXPERIMENTAL METADATA. Each row of the metadata should correspond 
                                  to one unique assay condition, and each column represents one assay variable (a variable is something 
                                  that varied in the assay, e.g. cell type, stim conc.). Metadata MUST include an simple numeric 
                                  index of assay conditions in the LEFTMOST column (i.e. Condition Index:  1,2,3...). NOTE: if you 
                                  import metadata from an Excel file with multiple sheets, the tab of the desired Excel sheet must be 
                                  labeled \'metadata\'.", style="color:black;text-align:justify"),
                                p("2) FLOWJO STATISTICS. Every sample (DIVA Specimen) must be numbered, such that Specimen ID's can be directly 
                                  paired to associated meta data:  ", style="color:black;text-align:justify"),  
                                p("e.g. This application is designed to pair a sample called \'Specimen_001_B2_B02_001.fcs\' with 
                                metadata Condition_Index = 1. Likewise, \'Specimen_038_C9_C09_040.fcs\' with 
                                metadata Condition_Index = 38.",style="color:black;text-align:justify"),
                                br(),
                                p("Note on output: data are exported in both a \'long format\', (aka tidy format) where one row = one observation, useful in Spotfire, JMP, Tableau. 
                                  Data are also exported in \'wide format\', where samples are side-by-side, suitable for Prism. FMO's are removed.",style="color:black;text-align:justify"),
                                width=8, style="border-radius: 10px")
                     )
                     )

        ))
    )
)


server <- function(input, output) {

    data_flowjo <- reactive({           # define facs stats import function
      flowjo_file <- input$flowjo_file
    if(is.null(flowjo_file)) {   
      return()
    } else if (str_detect(flowjo_file, ".xlsx$")) {
      df <- read_excel(flowjo_file$datapath) 
    } else if (str_detect(flowjo_file, ".csv$")) {
      df <- read_csv(flowjo_file$datapath)   
    } else if (str_detect(flowjo_file, ".txt$")) {
      df <- read_tsv(flowjo_file$datapath)  
    } else { return()
    } 
    
    colnames(df)[[1]] <- "DIVA_specimen"
      
    df %>%                            # rename first col, which my vary depending on import method
        select_if(function(x) any(!is.na(x))) %>%                                         # select on columns with contents (remove empty cols)
        dplyr::mutate(Specimen_ID = map_chr(DIVA_specimen, ~ str_split(.x, "_")[[1]][2])) %>%    # Pull out DIVA "specimen" information
        dplyr::mutate_at(vars(Specimen_ID), as.numeric) %>%
        arrange(Specimen_ID) %>%
        filter(!grepl('FMO', DIVA_specimen)) %>%
        filter(!DIVA_specimen %in% c("SD", "Mean")) %>%
        dplyr::mutate(well = map_chr(DIVA_specimen, ~ str_split(.x, "_")[[1]][3])) %>%
        group_by(well) %>%
        dplyr::mutate(Plate = 1:length(`well`)) %>%
        ungroup() %>%  
        dplyr::select(Specimen_ID, Plate, well, DIVA_specimen, everything()) %>%
        separate(well, c("well_row", "well_col"), sep = 1) %>%
        gather(key = "full_gating_path", value = "readout", 6:ncol(.)) %>%
        dplyr::mutate(plot_label = str_extract(full_gating_path, "(?<=\\|)[^\\/]+")) %>%
        dplyr::mutate(plot_label = gsub(pattern = "Mean", replacement = "MFI", x = .$plot_label)) %>%
        dplyr::mutate(plot_label = gsub(pattern = "\\(", replacement = "", x = .$plot_label)) %>%
        dplyr::mutate(plot_label = gsub(pattern = "\\)", replacement = "", x = .$plot_label)) %>%
        dplyr::mutate(Gate = str_extract(full_gating_path, "(?<=\\/)[^\\/]+(?=\\|)")) %>%
        dplyr::mutate(ParentGate = str_extract_all(.$full_gating_path, regex("(?<=\\/)[^\\/]+(?=\\/)", multiline = TRUE))) %>%
        dplyr::mutate(ParentGate = unlist(unique(map(.[,"ParentGate"], function(x) {map(x, last)})))) %>%
        dplyr::mutate(GrandparentGate = map_chr(full_gating_path, ~ nth(flatten(str_split(.x, "/")), -3))) %>%
        dplyr::mutate(plot_label =  str_replace_all(.$plot_label, "Freq. of Parent %", paste0(Gate, " (% freq. of ", ParentGate, ")"))) %>%
        dplyr::mutate(plot_label = gsub(pattern = "HLA ", replacement = "HLA\\-", x = .$plot_label)) %>%
        dplyr::select("Specimen_ID", "DIVA_specimen", "Plate", "well_row", "well_col", "full_gating_path", "GrandparentGate", "ParentGate", "Gate", "plot_label", "readout", everything()) %>%     #"full_gating_path",  "well_row", "well_col", "plot_label", "ParentGate", "Gate", "readout",
        greek_fix()
      })
    
    data_meta <- reactive({        # define metadata import function
      metadata_file <- input$metadata_file
      
      if(is.null(metadata_file)) {    
        return()
      } else if (str_detect(metadata_file, ".xlsx$")) {
                
                if (length(readxl::excel_sheets(metadata_file$datapath)) > 1) {
                  d.meta <- read_excel(metadata_file$datapath, sheet = "metadata")
                } else if (length(readxl::excel_sheets(metadata_file$datapath)) == 1) {
                  d.meta <- read_excel(metadata_file$datapath)
                } else {
                  return()
                  }
          
      } else if (str_detect(metadata_file, ".csv$")) {
        d.meta <- read_csv(metadata_file$datapath)   
      } else if (str_detect(metadata_file, ".txt$")) {
        d.meta <- read_tsv(metadata_file$datapath)  
      } 
      
      d.meta
      
    })
    
    table_wide_join <- reactive({              # wide table list generator function
      
      d.meta <- data_meta()
      if(is.null(data_meta())) {
        return() 
      } else {
        
        d.data3 <- data_flowjo() %>%
          group_by(`GrandparentGate`, `plot_label`, `Specimen_ID`) %>%
          dplyr::mutate(rep = 1:length(`Specimen_ID`)) %>%
          pivot_wider(.,
                      id_cols = c("GrandparentGate", "plot_label", "Specimen_ID"), 
                      values_from = "readout",
                      names_from = "rep") %>%
          inner_join(., d.meta, by = "Specimen_ID") %>%
          dplyr::select(names(d.meta), everything())
        
        d.data4 <- d.data3 %>%
          t() %>%
          as_tibble(rownames = "assay_vars")
        
        two_wide_prism_tables <- list(d.data3, d.data4)
        names(two_wide_prism_tables) <- list("Prism_long", "Prism_wide")
        two_wide_prism_tables
      }
        })
    
    table_long_join <- reactive({                  # define long format clean & join fun
      
      if(!is.null(data_meta()) & !is.null(data_flowjo())) {
        
           d.meta <- data_meta()
          
           df <- data_flowjo() %>%
             inner_join(., d.meta, by = "Specimen_ID") %>%
             dplyr::mutate_at(vars("Specimen_ID"), as.factor)
           df

      } else if (is.null(data_meta) & !is.null(data_flowjo())) {
            
           df <- data_flowjo()
           df

      } else {
        return()
      }
       
    })
    
  output$plot <- renderPlot({
    
    if(is.null(data_flowjo())) {
      
      return() 
      
      } else {
    
    ggplot(data = data_flowjo(), aes(well_col, well_row)) +
      geom_point(data = expand.grid(cols = 1:12, rows = LETTERS[1:8]), 
                 aes(factor(cols), fct_rev(rows)), 
                 alpha = 0.2, 
                 color = "grey", 
                 size = 7.5) + 
      geom_point(data = data_flowjo(), mapping = aes(well_col, well_row, color = Specimen_ID), 
                 size = 6, 
                 alpha = 0.05,
                 show.legend = FALSE) + 
      geom_text(data = data_flowjo(), mapping = aes(label = `Specimen_ID`)) +
      labs(x = NULL, y = NULL, title = "DIVA Specimen Plate Layout", 
           subtitle = "Wells labeled with Specimen numbers. Check layout for accuracy") +
      facet_wrap( ~ Plate, ncol = 2, labeller = label_both) +
      scale_color_jcolors_contin(palette = "rainbow")
      }
    })

  output$table_long <- reactive({
    if(is.null(table_long_join())){return()}
    
    df <- table_long_join()
    df$readout <- color_tile("#F9FB0E", "#089BCE")(df$readout)

    kbl(df, escape = F, align = "cccccccc") %>%
      kable_minimal(bootstrap_options = c("striped", "hover", "condensed", "responsive"), 
                     full_width = F, font_size = 11, fixed_thead = T) %>%
      row_spec(0, hline_after = T, color = "midnightblue", bold = TRUE, font_size = 13) %>%
      column_spec(which(1:length(df)%%2 == 0), background = "#f0f0f0", width_min = "2cm")
  })
  
  output$table_wide <- renderTable({   # show data set based on ui selection and data match in server/dataInput()
    if(is.null(table_wide_join())){return()}
    table_wide_join()[[2]]
  })
  
  output$downloadData <- downloadHandler(
    
    filename = paste(str_replace_all(Sys.Date(), "-", "_"), "reshaped flow stats.xlsx"),

    content = function(file) {
      three_tables <- table_wide_join()
      three_tables[["BI_long"]] <- table_long_join()
      #openxlsx::write.xlsx(three_tables, file)
      writexl::write_xlsx(three_tables, file)
    }
    
  )
}


# Run the application 
shinyApp(ui = ui, server = server)
