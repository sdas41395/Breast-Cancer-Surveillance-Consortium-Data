library(shiny)
library(ggplot2)

# UI code. This script gives the layout of the UI and provides the input variables to be filled in by the server.R

### Creating Functions for Display ###

title_layout = titlePanel(
  title = tags$strong("Invasive Breast Cancer and Invasive Ductal Carcinoma"),
  windowTitle = "Risk Estimation"
)

### Text Output for Each of the Generated Graphs ###

cancer_data = verbatimTextOutput(outputId = "data_cancer")
invasive_data = verbatimTextOutput(outputId = "invasive_data")
invasive_percentage = verbatimTextOutput(outputId = "invasive_percentage")
carcinoma_data = verbatimTextOutput(outputId = "carcinoma_data")
carcinoma_percentage = verbatimTextOutput(outputId = "carcinoma_percentage")

### Parameter Functions ###

menopaus_function = checkboxGroupInput(
  choices = list("premenopausal" = 0,
                 "postmenopausal or age > 55" = 1,
                 "unknown" = 9
  ),
  selected = 0,
  label = "Menopaus",
  inline = FALSE,
  inputId = "menopaus"
  
)

agegrp_function = checkboxGroupInput(
  choices = list("35 - 39" = 1,
                 "40 - 44" = 2,
                 "45 - 49" = 3,
                 "50 - 54" = 4,
                 "55 - 59" = 5,
                 "60 - 64" = 6,
                 "65 - 69" = 7,
                 "70 - 74" = 8,
                 "75 - 79" = 9,
                 "80 - 84" = 10
  ),
  #selected = 0,
  label = "Age Group",
  inline = FALSE,
  inputId = "agegrp"
  
)

density_function = checkboxGroupInput(
  choices = list("Almost Entirely Fat" = 1,
                 "Scattered fibroglandular densities" = 2,
                 "Heterogeneously dense" = 3,
                 "Extremely dense" = 4,
                 "Unknown or different measurment system" = 9
  ),
  #selected = 0,
  label = "Breast Density",
  inline = FALSE,
  inputId = "density"
  
)

race_function = checkboxGroupInput(
  choices = list("White" = 1,
                 "Asian/Pacific Islander" = 2,
                 "Black" = 3,
                 "Native American" = 4,
                 "Other/Mixed" = 5,
                 "Unknown" = 9
  ),
  #selected = 0,
  label = "Race",
  inline = FALSE,
  inputId = "race"
  
)

hispanic_function = checkboxGroupInput(
  choices = list("No" = 0,
                 "Yes" = 1,
                 "unknown" = 9
  ),
  #selected = 0,
  label = "Hispanic",
  inline = FALSE,
  inputId = "hispanic"
  
)

bmi_function = checkboxGroupInput(
  choices = list("10 - 24.99" = 1,
                 "25 - 29.99" = 2,
                 "30 - 34.99" = 3,
                 "35 or more" = 4,
                 "unknown" = 9
  ),
  #selected = 0,
  label = "Body Mass Index",
  inline = FALSE,
  inputId = "bmi"
  
)

agefirst_function = checkboxGroupInput(
  choices = list("Age < 30" = 0,
                 "Age 30 or Greater" = 1,
                 "Nulliparious" = 2,
                 "Unknown" = 9
  ),
  #selected = 0,
  label = "Age of First Birth",
  inline = FALSE,
  inputId = "agefirst"
  
)

nrelbc_function = checkboxGroupInput(
  choices = list("zero" = 0,
                 "One" = 1,
                 "Two or More" = 2,
                 "Unknown" = 9
  ),
  #selected = 0,
  label = "Number of First Degree Relatives with Breast Cancer",
  inline = FALSE,
  inputId = "nrelbc"
  
)

brstproc_function = checkboxGroupInput(
  choices = list("No" = 0,
                 "Yes" = 1,
                 "Unknown" = 9
  ),
  #selected = 0,
  label = "Previous Breast Procedure",
  inline = FALSE,
  inputId = "brstproc"
  
)

lastmamm_function = checkboxGroupInput(
  choices = list("Negative" = 0,
                 "False Positive" = 1,
                 "unknown" = 9
  ),
  #selected = 0,
  label = "Result of Last Mammogram before the Index Mammogram",
  inline = FALSE,
  inputId = "lastmamm"
  
)

surgmeno_function = checkboxGroupInput(
  choices = list("Natural" = 0,
                 "Surgical" = 1,
                 "Unknown or not Menopausal" = 9
  ),
  #selected = 0,
  label = "Surgical Menopause",
  inline = FALSE,
  inputId = "surgmeno"
  
)

hrt_function = checkboxGroupInput(
  choices = list("No" = 0,
                 "Yes" = 1,
                 "Unknown or not Menopausal" = 9
  ),
  #selected = 0,
  label = "Current Hormone Therapy",
  inline = FALSE,
  inputId = "hrt"
  
)

button = actionButton(
  inputId = "run",
  label = "Submit"
)

data_entry = fileInput(
  inputId = "risk_data",
  label = NULL,
  multiple = FALSE,
  accept = ".txt",
  buttonLabel = "Browse",
  placeholder = "No file selected"
)

save_box = radioButtons(
  inputId = "save_button",
  label = tags$em("Save Results"),
  c("Yes" = TRUE,
    "No" = FALSE)
)

download_button = downloadButton(
  outputId = "download",
  label = "Download Results"
)

### Cancer Plot Functions ###

cancerplotInvasive = plotOutput("cancerNumber_invasive")
percentageplotInvasive = plotOutput("cancerPercentage_invasive")
cancerplotCarcinoma = plotOutput("cancerNumber_carcinoma")
percentageplotCarcinoma = plotOutput("cancerPercentage_carcinoma")



#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Organization of UI ###


ui =  fluidPage(
  #theme = "flatly.css",
  title_layout,
  tags$hr(),
  tags$h4("The following graphs will display total and percentage values of individuals affected with invasive breast cancer and/or ductal/invasive carcinoma within one year of mammogram screening"),
  tags$h4("The data is taken from the Breast Cancer Surveillance Consortium and all information regarding constraints can be found in the README.txt"),
  br(),
  mainPanel(
    tabsetPanel(
      tabsetPanel(
        
        tabPanel("Invasive Breast Cancer Totals", cancerplotInvasive, invasive_data),
        tabPanel("Invasive Breast Cancer Percentages", percentageplotInvasive, invasive_percentage)
      ),
      tabsetPanel(
        tabPanel("Invasive or Ductal Carcinoma Totals", cancerplotCarcinoma, carcinoma_data),
        tabPanel("Invasive or Ductal Carcinoma Percentages", percentageplotCarcinoma, carcinoma_percentage)   
      )
    ),
    
    cancer_data
    
  ),
  hr(),
  fluidRow(
    column(2,
           menopaus_function,
           agegrp_function,
           density_function,
           race_function,
           bmi_function,
           agefirst_function
         ),

  column(2, 
         hispanic_function,
         nrelbc_function,
         brstproc_function,
         lastmamm_function,
         surgmeno_function,
         hrt_function,
         save_box
        ),
  
 
  button  )
)