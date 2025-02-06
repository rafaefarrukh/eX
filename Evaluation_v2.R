###################################################################################################

# eX - Course/Instructor Evaluation

# Github repo: https://github.com/rafaefarrukh/eX 

###################################################################################################

# SETUP ###########################################################################################

# Libraries
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(bslib)
library(tidyverse)
library(googlesheets4)
library(plotly)
library(DT)
library(bsicons)

###################################################################################################

# UI ##############################################################################################

ui <- page_sidebar(
    
    # refresh code (idk how it works)
    useShinyjs(), extendShinyjs(text = "shinyjs.refresh_page = function() { history.go(0); }", functions = "refresh_page"),
    
    fillable = TRUE, fillable_mobile = TRUE,
    
    title = "eX - Course and Instructor Evaluation",
    
    # sidebar ----
    sidebar = sidebar(
        
        title = "Select Instructor", width = 400,
        
        # input instructor
        pickerInput(
            inputId = "ins", label = "Instructor",
            choices = "None", selected = "None",
            options = list("live-search" = TRUE),
            multiple = FALSE, width = "100%"
        ),
        
        # input course code
        pickerInput(
            inputId = "code", label = "Course",
            choices = "None", selected = "None",
            options = list("live-search" = TRUE),
            multiple = FALSE, width = "100%"),
        
        # refresh button
        actionBttn(inputId = "refresh", label = "Refresh Data", style = "fill"),
        
        # text
        h2("Help eX out"), htmlOutput("text.help"),
        h2("How to Use"), htmlOutput("text.how")
        
    ),
    
    # table and graphs ----
    navset_card_tab(title = "Statistics", height = 500,
        nav_panel("Overview", DTOutput("ins.course")),
        nav_panel("GPA Detail", plotlyOutput("gpa.detail", height = "100%")),
        nav_panel("Instructor Detail", plotlyOutput("ins.detail", height = "100%")),
    ),
    
    br(),
    
    # value boxes ----
    layout_columns(
        
        height = 200,
        
        # gpa
        value_box(height = 200, theme = "teal",
                  title = "GPA", p("Average GPA in the selected course"),
                  showcase = uiOutput("fig.gpa"), value = textOutput("val.gpa")
                  ),
        
        # quality
        value_box(height = 200, theme = "cyan",
                  title = "Course Quality", p("1 means course is useless and 5 means course is useful"),
                  showcase = uiOutput("fig.aca"), value = textOutput("val.aca")
                  ),
        
        # repeat
        value_box(height = 200, theme = "purple",
                  title = "Happy Students", p("students willing to study again from this instructor"),
                  showcase = uiOutput("fig.rep"), value = textOutput("val.rep")
                  )
    ),
    
    br(),
    
    # opinions ----
        layout_column_wrap(
            heights_equal = "row", width = 1/2, height = 250,
            card(fillable = TRUE, card_header(class = "bg-dark", "Opinions/Advice about Instructor"), tableOutput("ins.op")),
            card(fillable = TRUE, card_header(class = "bg-dark", "Opinions/Advice about Course"), tableOutput("course.op"))
        )
    
    
    # end of ui ----
    
)

# SERVER ##########################################################################################

server <- function(input, output) {
    
    #bs_themer()
    
    # refresh ----
    eval <- reactive({
        invalidateLater(300000) # 10 minute time delay
        gs4_deauth() # gives error 403 if omitted (idky)
        read_sheet("https://docs.google.com/spreadsheets/d/1TUNufVMrymAr7Qea_OpV8QC9LdAzs6HZHgegtjTriDw/edit?usp=sharing", sheet = "Export")
    })
    observeEvent(input$refresh, {js$refresh_page()})
    
    # update inputs ----
    observe({updatePickerInput(inputId = "ins", choices = sort(unique(eval()$ins)), selected = "None")})
    observe({updatePickerInput(inputId = "code", choices = sort(unique(eval()$code)), selected = "None")})
    
    # instructor and courses ----
    output$ins.course <- renderDataTable(datatable({
        
        # if no instructor or course
        if (input$ins == "None" & input$code == "None") {
            eval() %>% 
                filter(ins == "None", code == "None") %>%
                mutate(`Average GPA` = NA, `Course Quality` = NA, `Course Difficulty` = NA, `Instructor Teaching Quality` = NA, `Instructor Personality` = NA, `Instructor Strictness` = NA, gpa = NULL, aca = NULL, diff = NULL, qot = NULL, person = NULL, strict = NULL, op.c = NULL, op.i = NULL, rep = NULL) %>%
                rename(Course = "code", Instructor = "ins")
        }
        
        # if only instructor
        else if (input$ins != "None" & input$code == "None") {
            eval() %>%
                filter(ins %in% input$ins) %>%
                mutate(`Average GPA` = mean(as.numeric(gpa)),
                       `Course Quality` = mean(as.numeric(aca)),
                       `Course Difficulty` = mean(as.numeric(diff)),
                       `Instructor Quality` = mean(as.numeric(qot)),
                       `Instructor Personality` = mean(as.numeric(person)),
                       `Instructor Strictness` = mean(as.numeric(strict)),
                       gpa = NULL, aca = NULL, diff = NULL, qot = NULL, person = NULL, strict = NULL, op.c = NULL, op.i = NULL, rep = NULL) %>%
                rename(Course = "code", Instructor = "ins")
        }
        
        # if only code
        else if (input$ins == "None" & input$code != "None") {
            eval() %>%
                filter(code %in% input$code) %>%
                mutate(`Average GPA` = mean(as.numeric(gpa)),
                       `Course Quality` = mean(as.numeric(aca)),
                       `Course Difficulty` = mean(as.numeric(diff)),
                       `Instructor Quality` = mean(as.numeric(qot)),
                       `Instructor Personality` = mean(as.numeric(person)),
                       `Instructor Strictness` = mean(as.numeric(strict)),
                       gpa = NULL, aca = NULL, diff = NULL, qot = NULL, person = NULL, strict = NULL, op.c = NULL, op.i = NULL, rep = NULL) %>%
                rename(Course = "code", Instructor = "ins")
        }
        
        # if both instructor and code
        else if (input$ins != "None" & input$code != "None") {
            eval() %>%
                filter(ins %in% input$ins, code %in% input$code) %>%
                mutate(`Average GPA` = mean(as.numeric(gpa)),
                       `Course Quality` = mean(as.numeric(aca)),
                       `Course Difficulty` = mean(as.numeric(diff)),
                       `Instructor Quality` = mean(as.numeric(qot)),
                       `Instructor Personality` = mean(as.numeric(person)),
                       `Instructor Strictness` = mean(as.numeric(strict)),
                       gpa = NULL, aca = NULL, diff = NULL, qot = NULL, person = NULL, strict = NULL, op.c = NULL, op.i = NULL, rep = NULL) %>%
                rename(Course = "code", Instructor = "ins")
        }
         
    },
    rownames = FALSE,
    options = list(
        dom = 'tp',
        pageLength = "5",
        scrollY = "200px",
        columnDefs = list(
            list(width = '30pc', targets = c(0)),
            list(width = '20pc', targets = c(1)),
            list(className = 'dt-center', targets = c(2:7))
        ))))
    
    # instructor detail graph ----
    ## data
    ins.graph <- reactive({
        
        # requirement
        req(input$ins != "None")
        
        # convert wide to long df
        temp <- data.frame(rbind(
            cbind(
                type = "Teaching Quality",
                mean = mean(as.numeric(eval()$qot[which(eval()$ins %in% input$ins)])),
                min = min(as.numeric(eval()$qot[which(eval()$ins %in% input$ins)])),
                max = max(as.numeric(eval()$qot[which(eval()$ins %in% input$ins)]))
            ),
            cbind(
                type = "Personality",
                mean = mean(as.numeric(eval()$person[which(eval()$ins %in% input$ins)])),
                min = min(as.numeric(eval()$person[which(eval()$ins %in% input$ins)])),
                max = max(as.numeric(eval()$person[which(eval()$ins %in% input$ins)]))
            ),
            cbind(
                type = "Strictness", 
                val = mean(as.numeric(eval()$strict[which(eval()$ins %in% input$ins)])),
                min = max(as.numeric(eval()$strict[which(eval()$ins %in% input$ins)])),
                max = min(as.numeric(eval()$strict[which(eval()$ins %in% input$ins)]))
            )
        ))
        return(temp)
    })
    ## graph
    output$ins.detail <- renderPlotly({
        req(input$ins != "None")
        plot_ly(type = "scatterpolar", fill = "toself", mode = "markers", opacity = 0.5) %>%
            add_trace(r = ins.graph()$max, theta = ins.graph()$type, name = "Maximum", color = I("green"), hovertemplate = paste('%{theta} Score: %{r}')) %>%
            add_trace(r = ins.graph()$mean, theta = ins.graph()$type, name = "Average", color = I("blue"), hovertemplate = paste('%{theta} Score: %{r}')) %>%
            add_trace(r = ins.graph()$min, theta = ins.graph()$type, name = "Minimum", color = I("red"), hovertemplate = paste('%{theta} Score: %{r}')) %>%
            layout(polar = list(radialaxis = list(visible = T, range = c(0,10))))
    })
    
    # gpa detail ----
    output$gpa.detail <- renderPlotly({
        req(input$code != "None")
        plot_ly(
            x = data.frame(table(eval()$gpa[eval()$code %in% input$code]))$Var1,
            y = data.frame(table(eval()$gpa[eval()$code %in% input$code]))$Freq,
            type = "bar", hoverinfo = "skip") %>%
            layout(title = "GPA Distibution Per Course", yaxis = list(title = "Count"), xaxis = list(title = "GPA"))
        
    })
    
    
    # instructor tags/opinions and course opinions  ----
    output$ins.op <- renderText({gsub(pattern = "\\n", replacement = "<br/>", paste(na.omit(unique(eval()$op.i[which(eval()$ins %in% input$ins)])), collapse = "\n"))})
    output$course.op <- renderText({gsub(pattern = "\\n", replacement = "<br/>", paste(na.omit(unique(eval()$op.c[which(eval()$code %in% input$code)])), collapse = "\n"))})
    # value boxes ----
    
    ## repeat students
    output$val.rep <- renderText({ifelse(input$ins == "None", "Select Instructor", paste0((sum(eval()$rep[eval()$ins %in% input$ins] == "Yes") / sum(eval()$ins %in% input$ins))*100, "%"))})
    output$fig.rep <- renderText({
        ifelse(input$ins == "None",
               as.character(bs_icon("emoji-expressionless-fill")),
               ifelse((sum(eval()$rep[eval()$ins %in% input$ins] == "Yes") / sum(eval()$ins %in% input$ins)) <= 0.5,
                      as.character(bs_icon("emoji-frown-fill")),
                      as.character(bs_icon("emoji-smile-fill"))
                      ))})
    ## gpa
    output$val.gpa <- renderText({ifelse(input$code == "None", "Select Course", mean(as.numeric(eval()$gpa[eval()$code %in% input$code]), na.rm = T))})
    output$fig.gpa <- renderText({
        ifelse(input$code == "None",
               as.character(bs_icon("arrow-left-circle-fill")),
               ifelse(mean(as.numeric(eval()$gpa[eval()$code %in% input$code]), na.rm = T) <= 3,
                      as.character(bs_icon("arrow-down-circle-fill")),
                      as.character(bs_icon("arrow-up-circle-fill"))
               ))})
    
    ## course quality
    output$val.aca <- renderText({ifelse(input$code == "None", "Select Course", paste(mean(as.numeric(eval()$aca[eval()$code %in% input$code]), na.rm = T), "/ 5"))})
    output$fig.aca <- renderText({
        ifelse(input$code == "None",
               as.character(bs_icon("journal")),
               ifelse(mean(as.numeric(eval()$aca[eval()$code %in% input$code]), na.rm = T) <= 3,
                      as.character(bs_icon("journal-arrow-down")),
                      as.character(bs_icon("journal-arrow-up"))
               ))})
    
    # text ----
    output$text.help <- renderUI({HTML("Help yourself and other students by filling and sharing this <a href=\"https://forms.gle/TWXyXDiNUidmfzUL6\"> course/instructor evaluation form</a>")})
    output$text.how <- renderUI({HTML(
    "Select an instructor or course using the drop downs above to get started. If there are no results or the instructor/course name is not present in the drop down, then it means there is not enough data. Share the evaluation form with yur friends to improve the dataset.
    <br><br>
    Choose a course and then go to GPA details. The bar graph shows the distribution of the GPAs given in that course.
    <br><br>
    Choose an instructor and then go to Instructor details. The radar chart shows some properties of the instructor: teaching quality, personality, and strictnes."
    )})
    
}

###################################################################################################

# RENDER ##########################################################################################

shinyApp(ui, server)

###################################################################################################