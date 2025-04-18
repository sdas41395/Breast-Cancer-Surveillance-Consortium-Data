# Server side code. Manages handling the backend system call and the storing of data retrieved from output.txt
# Also prints text to UI and displays data through barplots.
# Note that output.txt is generated by data_parse.py and can be found in ./Tempus/backend/output.txt
# Output.txt contains the result of parsing the risk.txt file 
# For more information about this script please consult the README.txt or email Shoham Das at sdas41395@gmail.com
# Saved results are located in ./backend/saved_results.txt 
# Note that the saved_results are from the last submission


### Global Variable ###

backend_call <- ""                                                                                  # The backend system call is kept as a global variable. It is updated per each submission

server = function(input, output){
  
  ### Reactive Values ###
  values = reactiveValues(cancer_list = list(), cancer_percentage = list())                         # Both variables contain data totals and percentages
  
  
  ### Submission of Parameters ###
  
  observeEvent(input$run,{
    
    showModal(modalDialog(
      title = "Compiling",                       
      fotter = NULL,
      tags$code("Calling backend python script data_parse.py"),                                     # Compiling the data and alerting the User
      easyClose = FALSE
    ))
    
    backend_func()
    system(backend_call)                                                                            # Running the backend system call generated as parameters are being picked
    Sys.sleep(1)
    removeModal()
    
    local_cancer = read.csv("output.txt", header = FALSE, sep = ",")                                # data_parse.py generates a csv file with 
    
    values$cancer_list = local_cancer
    names(values$cancer_list) = c("Diagnosed", "Nondiagnosed")
    
    #COllecting percentages from output file generated by python backend
    invasive_undiagnosed = ((values$cancer_list[1,2] - values$cancer_list[1,1])/(values$cancer_list[1,1] + values$cancer_list[1,2])) * 100
    invasive_diagnosed = 100 - invasive_undiagnosed
    carcinoma_undiagnosed = ((values$cancer_list[2,2] - values$cancer_list[2,1])/(values$cancer_list[2,1] + values$cancer_list[2,2])) * 100
    carcinoma_diagnosed = 100 - carcinoma_undiagnosed
    diagnosed_p = c(carcinoma_diagnosed, invasive_diagnosed)
    undiagnosed_p = c(carcinoma_undiagnosed,invasive_undiagnosed)
    
    #Storing the percentages to be graph
    local_percentage = data.frame(diagnosed_p, undiagnosed_p)
    names(local_percentage) = c("Diagnosed", "Nondiagnosed")
    values$cancer_percentage = local_percentage
    
  })
  
  
  ### Backend system call String Generation ###
  
  backend_func = function(){
    
    function_call = "py ./backend/data_parse.py"
    
    menopaus_array = "menopaus-"                                                                    # Each of these snippets generates the necessary array to paste into a system call to the backend
    for(i in input$menopaus){
      menopaus_array = paste(menopaus_array , i, sep = ".")
    }
    
    agegrp_array = "agegrp-"
    for(i in input$agegrp){
      agegrp_array = paste(agegrp_array , i, sep = ".")
    }
    
    density_array = "density-"
    for(i in input$density){
      density_array = paste(density_array , i, sep = ".")
    }
    
    race_array = "race-"
    for(i in input$race){
      race_array = paste(race_array , i, sep = ".")
    }
    
    hispanic_array = "hispanic-"
    for(i in input$hispanic){
      hispanic_array = paste(hispanic_array , i, sep = ".")
    }
    
    bmi_array = "bmi-"
    for(i in input$bmi){
      bmi_array = paste(bmi_array , i, sep = ".")
    }
    
    agefirst_array = "agefirst-"
    for(i in input$agefirst){
      agefirst_array = paste(agefirst_array , i, sep = ".")
    }
    
    nrelbc_array = "nrelbc-"
    for(i in input$nrelbc){
      nrelbc_array = paste(nrelbc_array , i, sep = ".")
    }
    
    brstproc_array = "brstproc-"
    for(i in input$brstproc){
      brstproc_array = paste(brstproc_array , i, sep = ".")
    }
    
    lastmamm_array = "lastmamm-"
    for(i in input$lastmamm){
      lastmamm_array = paste(lastmamm_array , i, sep = ".")
    }
    
    surgmeno_array = "surgmeno-"
    for(i in input$surgmeno){
      surgmeno_array = paste(surgmeno_array , i, sep = ".")
    }
    
    hrt_array = "hrt-"
    for(i in input$hrt){
      hrt_array = paste(hrt_array , i, sep = ".")
    }
    
    save_array = "save-"
    if (input$save_button == TRUE){
      save_array = paste(save_array, "TRUE", sep = ".") 
    }
    else{
      save_array = paste(save_array, "FALSE", sep = ".")
    }
    
    
    function_call = paste(function_call, menopaus_array, agegrp_array, density_array, race_array,                                         # The function call is created from combining the arrays
                          hispanic_array, bmi_array,agefirst_array, nrelbc_array, brstproc_array, lastmamm_array,
                          surgmeno_array, hrt_array, save_array)
    print(function_call)
    
    backend_call <<- function_call                                                                                                        # The combined function call is stored in the global variable
  }
  
  ### Serverside code for Graph Creation ###
  
  output$cancerNumber_invasive = renderPlot({                                                                                             # The plots are created based off reactive values. Changes to these values updates our graphs
    barplot(as.matrix(values$cancer_list[1,]),
            beside = TRUE,
            ylab = "Number of Patients")
    
  })
  
  output$cancerPercentage_invasive = renderPlot({
    barplot(as.matrix(values$cancer_percentage[1,]),
            beside = TRUE,
            ylab = "Percentage of Patients")
    
  })
  
  output$cancerNumber_carcinoma = renderPlot({
    barplot(as.matrix(values$cancer_list[2,]),
            beside = TRUE,
            ylab = "Number of Patients")
    
  })
  
  output$cancerPercentage_carcinoma = renderPlot({
    barplot(as.matrix(values$cancer_percentage[2,]),
            beside = TRUE,
            ylab = "Percentage of Patients")
    
  })
  
  ### Outputting text per Graph
  
  output$invasive_data = renderPrint({
    
    print(paste("Number of patients diagnosed with invasive breast cancer:",values$cancer_list[1,1], sep = " "))                          # These render prints output the total values and percentages per each graph generated
    print(paste("Number of patients not diagnosed with invasive breast cancer:",values$cancer_list[1,2], sep = " "))
    print(paste("Total number of patients with constraints:", (values$cancer_list[1,1] + values$cancer_list[1,2])), sep = " ")
  })
  
  output$carcinoma_data = renderPrint({
    print(paste("Number of patients diagnosed with carcinoma:",values$cancer_list[2,1], sep = " "))
    print(paste("Number of patients not diagnosed with carcinoma:",values$cancer_list[2,2], sep = " "))
    print(paste("Total number of patients with constraints:", (values$cancer_list[2,1] + values$cancer_list[2,2])), sep = " ")
  })
  
  output$invasive_percentage = renderPrint({
    print(paste("Percentage of patients diagnosed with invasive breast cancer:",values$cancer_percentage[1,1], sep = " "))
    print(paste("Percentage of patients diagnosed with invasive breast cancer:",values$cancer_percentage[1,2], sep = " "))
    
  })
  
  output$carcinoma_percentage = renderPrint({
    print(paste("Percentage of patients diagnosed with carcinoma:",values$cancer_percentage[2,1], sep = " "))
    print(paste("Percentage of patients diagnosed with carcinoma:",values$cancer_percentage[2,2], sep = " "))
  })
  
  
}