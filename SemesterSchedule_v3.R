###################################################################################################

# eX - Semester Schedule

# Github repo: https://github.com/rafaefarrukh/eX 

###################################################################################################

# SETUP ###########################################################################################

# Libraries
library(shiny)
library(bslib)
library(shinyWidgets)
library(tidyverse)
library(DT)
library(readxl)

# Data
## import
courses <- rbind(
    read_xls("data/2024SU.xls"),
    read_xls("data/2024FA.xls"),
    read_xls("data/2025SP.xls")
    )
## rename
names(courses) <- c("term", "dept", "codeOnly", "sec", "session", "title", "loc", "room", "days", "time", "instructor", "credits", "available", "offered", "date", "location", "method", "enrolled")
## mutate
courses <- courses %>%
    mutate(
        seats = paste(available, "/", offered),
        start = str_sub(time, 1, 5),
        end = str_sub(time, 9,14),
        code = paste(dept, codeOnly)) %>%
    mutate(codeOnly = NULL, session = NULL, loc = NULL, time = NULL, available = NULL, offered = NULL, date = NULL, location = NULL, method = NULL, enrolled = NULL)
## rearrange cols
courses <- courses[,c(1,2,12,4,3,8,7,6,10,11,5,9)]
## factorize
courses[c(1:7, 9:11)] <- lapply(courses[c(1:7, 9:11)], as.factor)

# dummy data to prevent error
dum <- data.frame("-", "-", "-", "-", "-", "MTWRF", "-", "-", "-")
names(dum) <- names(courses[3:11])

# UI ##############################################################################################

ui <- page_navbar(
    
    title = "eX - Semester Schedule",
    
    nav_panel(
        title = "Overview",
        layout_column_wrap(
            width = 1/2,
            card(height = 1025, fillable = TRUE, card_header(class = "bg-dark", "Your Time Table"), dataTableOutput("timetable")),
            layout_column_wrap(
                width = 1,
                card(height = 500, fillable = TRUE, card_header(class = "bg-dark", "How to Use"), uiOutput("text.how")),
                card(height = 500, fillable = TRUE, full_screen = TRUE, card_header(class = "bg-dark", "Overview of Selected Courses"), tableOutput("overview"))
                )
        ),
    ),
    
    nav_panel(
        width = 1000,
        title = "View and Select Courses",
        card(fillable = TRUE, card_header(class = "bg-dark", "Semester Schedule"), dataTableOutput("table"))
    )
)

###################################################################################################

# SERVER ##########################################################################################

server <- function(input, output) {
    
    # course schedule
    output$table <- renderDT(datatable(
        courses,
        rownames = FALSE,
        filter = list(position = 'top', clear = TRUE),
        options = list(
            dom = 'frtip',
            pageLength = "50",
            columnDefs = list(
                list(width = '5pc', targets = c(0,1,4,5)),
                list(width = '7pc', targets = c(2,6,7,8,9,10,11)),
                list(width = '10pc', targets = c(3)),
                list(className = 'dt-center', targets = c(0,1,2,4,5,7,8,9,10,11))))) %>%
            formatStyle(c('code', 'title'), fontWeight = 'bold')
    )
    
    # selected courses
    selected <- reactive(courses[input$table_rows_selected,])
    
    # overview
    output$overview <- renderTable(selected()[,3:11], striped = TRUE, width = "100%", height = "100%")
    
    # student time table data
    timedata <- reactive({
        
        temp <- rbind(
            data.frame(day = 1, rbind(dum, filter(selected(), str_detect(days, "M"))[,c(3:11)])),
            data.frame(day = 2, rbind(dum, filter(selected(), str_detect(days, "T"))[,c(3:11)])),
            data.frame(day = 3, rbind(dum, filter(selected(), str_detect(days, "W"))[,c(3:11)])),
            data.frame(day = 4, rbind(dum, filter(selected(), str_detect(days, "R"))[,c(3:11)])),
            data.frame(day = 5, rbind(dum, filter(selected(), str_detect(days, "F"))[,c(3:11)]))
        )
        
        temp <- arrange(temp, day, start)
        
        temp[which(temp[,1] == 1),1] <- "Monday"
        temp[which(temp[,1] == 2),1] <- "Tuesday"
        temp[which(temp[,1] == 3),1] <- "Wednesday"
        temp[which(temp[,1] == 4),1] <- "Thursday"
        temp[which(temp[,1] == 5),1] <- "Friday"
        
        temp <- temp %>%
            mutate(course = paste0(code, ": ", title, " (", sec, ") (", credits, ")")) %>%
            mutate(code = NULL, title = NULL, sec = NULL, credits = NULL, days = NULL)
        
        temp <- temp[,c(1,6,3,4,5,2)]
        
        names(temp) <- c("Day", "Course (section) (credits)", "Start", "End", "Room", "Instructor")
        
        temp[which(temp[,3] == "-"),2] <- "-"
        
        return(temp)
        
    })
    
    # student time table table
    output$timetable <- renderDT(
        datatable(
            timedata(),
            rownames = FALSE, 
            extensions = c('RowGroup', 'Buttons'),
            options = list(
                dom = 'Bfti',
                pageLength = "100",
                dom = "Bfrtip",
                buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                columnDefs = list(
                    list(width = '10pc', targets = c(0)),
                    list(width = '50pc', targets = c(1)),
                    list(width = '10pc', targets = c(2,3,4,5))
                ))))
    
    # text
    output$text.how <- renderUI({HTML(
    "Go to \"View and Select Courses\" page and click on the courses you want to select. Use the filters on the top for ease.
    <br><br>The selected courses will be displayed here.
    <br><br> To remove the courses from here, deselect them from the other page."
    )})
    
}

###################################################################################################

# RENDER ##########################################################################################
shinyApp(ui, server)
###################################################################################################