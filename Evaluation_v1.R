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
        width = 400,
        title = "Select Instructor",
        # input ins
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
        h2("How to Use"),htmlOutput("text.how.ins"),
        h2("Criteria"), htmlOutput("text.criteria")
        ),
    
    # tables ----
    navset_card_tab(
        height = 500,
        title = "Courses/Instructor",
        nav_panel("Instructor's Courses", DTOutput("ins.course")),
        nav_panel("Course's Instructors", DTOutput("course.ins")),
    ),
    
    br(),
    
    # boxes ----
    layout_columns(
        height = 225,
        # gpa
        value_box(
            height = 225, theme = "teal",
            title = "GPA", p("Average GPA in the selected course"),
            showcase = uiOutput("figure.gpa"),
            value = textOutput("value.gpa")
        ),
        # difficulty
        value_box(
            height = 225, theme = "yellow",
            title = "Course Difficulty", p("1 is difficult and 10 is easy"),
            showcase = uiOutput("figure.cd"),
            value = textOutput("value.cd")
        ),
        # quality
        value_box(
            height = 225, theme = "cyan",
            title = "Course Quality", p("1 is useless and 10 is useful"),
            showcase = uiOutput("figure.cq"),
            value = textOutput("value.cq")
        ),
        # repeat
        value_box(
            height = 225, theme = "purple",
            title = "Happy Students", p("students willing to study again from this instructor"),
            showcase = uiOutput("figure.hs"),
            value = textOutput("value.hs")
        )
    ),
    
    br(),
    
    # tags, opinions and graph ----
    layout_column_wrap(
        width = 1/2, height = 500,
        layout_column_wrap(
            heights_equal = "row", width = 1,
            card(fillable = TRUE, card_header(class = "bg-dark", "Instructor Tags"), htmlOutput("ins.tags")),
            card(fillable = TRUE, card_header(class = "bg-dark", "Opinions/Advice about Instructor"), tableOutput("ins.op")),
            card(fillable = TRUE, card_header(class = "bg-dark", "Opinions/Advice about Course"), tableOutput("course.op"))
        ),
        card(height = 500, full_screen = TRUE, 
             card_header(class = "bg-dark","Instructor Evaluation"), 
             card_body(class = "align-items-center", plotlyOutput("ins.eval", height = "100%"))
             )
    )
    
    # end of ui ----
    
)

###################################################################################################

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
    
    # instructor courses ----
    output$ins.course <- renderDataTable(datatable(
        {
            if (length(eval()$code[which(eval()$ins %in% input$ins)]) > 0) {
                # data frame
                temp <- data.frame(
                    # courses taught by instructor
                    Course = sort(unique(eval()$code[which(eval()$ins %in% input$ins)])),
                    # average measures by courses
                    Average.GPA = NA, Course.Quality = NA, Course.Difficulty = NA)
                # determine avg measure
                for (i in 1:nrow(temp)) {
                    temp$Average.GPA[i] <- round(mean(as.numeric(eval()$gpa[which(eval()$code %in% temp$Course[i])]), na.rm = TRUE), digits = 1)
                    temp$Course.Quality[i] <- round(mean(as.numeric(eval()$course[which(eval()$code %in% temp$Course[i])]), na.rm = TRUE), digits = 1)
                    temp$Course.Difficulty[i] <- round(mean(as.numeric(eval()$diff[which(eval()$code %in% temp$Course[i])]), na.rm = TRUE), digits = 1)
                }
                return(temp)}
            else {temp <- data.frame(Error = "Insufficent Data")}
        },
        rownames = FALSE,
        options = list(
            dom = 'tp',
            pageLength = "5",
            scrollY = "200px",
            columnDefs = list(
                list(width = '40pc', targets = c(0)),
                list(className = 'dt-center', targets = c(1:3))
            ))))
    
    # instructor graph ----
    ## data
    ins.graph <- reactive({
        
        # requirement
        req(length(eval()$code[which(eval()$ins %in% input$ins)]) > 0)
        
        # convert wide to long df
        temp <- data.frame(rbind(
            cbind(
                type = "Teaching Quality",
                val = as.numeric(eval()$qot[which(eval()$ins %in% input$ins)])),
            cbind(
                type = "Personality",
                val = as.numeric(eval()$per[which(eval()$ins %in% input$ins)])),
            cbind(
                type = "Grading Strictness", 
                val = as.numeric(eval()$grade[which(eval()$ins %in% input$ins)])),
            cbind(
                type = "Attendance Strictness",
                val = as.numeric(eval()$att[which(eval()$ins %in% input$ins)])),
            cbind(
                type = "Deadline Strictness",
                val = as.numeric(eval()$ded[which(eval()$ins %in% input$ins)]))
        ))
        return(temp)
    })
    ## graph
    output$ins.eval <- renderPlotly({
            ggplotly(ggplot(ins.graph(), aes(x=factor(val, level = as.character(1:5)), group = type, fill = type)) +
                         #xlim(rev(as.numeric(ins.graph()$val))) +
                         scale_x_discrete(limits = as.character(1:5)) +
                         geom_density(adjust=1.5, alpha=.5) +
                         labs(title = NULL, x = "score (see criteria)", y = "percentage distribution") +
                         theme(plot.margin = margin(1, 1, 1, 1, "cm"), panel.background = element_rect(fill = "white")))
    })
    
    # instructor tags/opinions and course opinions  ----
    output$ins.tags <- renderText({gsub(pattern = "\\n", replacement = "<br/>", paste(na.omit(unique(unlist(str_split(eval()$tags[which(eval()$ins %in% input$ins)], ", ")))), collapse = "\n"))})
    output$ins.op <- renderText({gsub(pattern = "\\n", replacement = "<br/>", paste(na.omit(unique(eval()$op.i[which(eval()$ins %in% input$ins)])), collapse = "\n"))})
    output$course.op <- renderText({gsub(pattern = "\\n", replacement = "<br/>", paste(na.omit(unique(eval()$op.c[which(eval()$code %in% input$code)])), collapse = "\n"))})
    # course instructors ----
    output$course.ins <- renderDataTable(datatable(
        {
            if (length(unique(eval()$ins[which(eval()$code %in% input$code)])) > 0) {
                # data frame
                temp <- data.frame(
                    # courses taught by instructor
                    Instructor = sort(unique(eval()$ins[which(eval()$code %in% input$code)])),
                    # average measures by courses
                    Teaching.Quality = NA, Personality = NA, Grading.Strictness = NA, Deadline.Strictness = NA,Attendance.Strictness = NA)
                # determine avg measure
                for (i in 1:nrow(temp)) {
                    temp$Teaching.Quality[i] <- round(mean(as.numeric(eval()$qot[which(eval()$ins %in% temp$Instructor[i])]), na.rm = TRUE), digits = 1)
                    temp$Personality[i] <- round(mean(as.numeric(eval()$per[which(eval()$ins %in% temp$Instructor[i])]), na.rm = TRUE), digits = 1)
                    temp$Grading.Strictness[i] <- round(mean(as.numeric(eval()$grade[which(eval()$ins %in% temp$Instructor[i])]), na.rm = TRUE), digits = 1)
                    temp$Deadline.Strictness[i] <- round(mean(as.numeric(eval()$ded[which(eval()$ins %in% temp$Instructor[i])]), na.rm = TRUE), digits = 1)
                    temp$Attendance.Strictness[i] <- round(mean(as.numeric(eval()$att[which(eval()$ins %in% temp$Instructor[i])]), na.rm = TRUE), digits = 1)
                }
                return(temp)
            }
            else {temp <- data.frame(Error = "Insufficient Data")}
        },
        rownames = FALSE,
        options = list(
            dom = 'tp',
            pageLength = "5",
            scrollY = "200px",
            columnDefs = list(
                list(width = '35pc', targets = c(0)),
                list(className = 'dt-center', targets = c(1:5))
            ))))
    
    # text ----
    output$text.how.ins <- renderUI({HTML(
    "Select an instructor using the drop down above and wait for the data to load. If there are no results, then it means there is <b>insufficient data.</b>
    <br><br> You can help out by filling the course/instructor evaluation form.
    <br><br> To view the graph in more detail, click the full screen button on the bottom right of the graph"
    )})
    output$text.criteria <- renderUI({HTML(
    "<b>Course Quality:</b> Did the course: expand your knowledge; prepare you for the job market; or help you grow as a person?
    <br><br><b>Course Difficulty:</b> Was the course content too much? Did it require knowledge from other courses?
    <br><br><b>Teaching Quality:</b> Did you understand the content of the course? Did the instructor help you understand topics you struggled with? 1 is bad and 5 is good.
    <br><br><b>Personality:</b> Did you enjoy your classes? Was the instructor an egoistic maniac? 1 is poor and 5 is great.
    <br><br><b>Grading Strictness:</b> Would the instructor give you an extra mark if it meant changing your grade? 1 is very strict and 5 is very lenient.
    <br><br><b>Deadline Strictness:</b> Would the instructor give you an extension in case of an actual emergency? 1 is very strict and 5 is very lenient.
    <br><br><b>Attendance Strictness:</b> Would the instructor mark your attendance if you come 5 minutes late? 1 is very strict and 5 is very lenient."
    )})
    output$text.help <- renderUI({HTML(
    "help yourself and other students by filling and sharing this <a href=\"https://forms.gle/TWXyXDiNUidmfzUL6\"> course/instructor evaluation form</a>")
    })
    # value box ----
    ## happy students
    output$value.hs <- renderText({
        if (input$ins == "None") {temp <- "Select an Instructor"}
        else {temp <- paste(((length(which(eval()$rep[which(eval()$ins %in% input$ins)] == "Yes")) / length(eval()$rep[which(eval()$ins %in% input$ins)])) * 100), "%")}
        return(temp)
    })
    output$figure.hs <- renderText({
        if (is.nan(length(which(eval()$rep[which(eval()$ins %in% input$ins)] == "Yes")) / length(eval()$rep[which(eval()$ins %in% input$ins)]))) {temp <- as.character(bs_icon("emoji-expressionless-fill"))}
        else if (input$ins == "None") {temp <- as.character(bs_icon("emoji-expressionless-fill"))}
        else if ((length(which(eval()$rep[which(eval()$ins %in% input$ins)] == "Yes")) / length(eval()$rep[which(eval()$ins %in% input$ins)])) < 0.5) {temp <- as.character(bs_icon("emoji-frown-fill"))}
        else if ((length(which(eval()$rep[which(eval()$ins %in% input$ins)] == "Yes")) / length(eval()$rep[which(eval()$ins %in% input$ins)])) == 0.5) {temp <- as.character(bs_icon("emoji-expressionless-fill"))}
        else if ((length(which(eval()$rep[which(eval()$ins %in% input$ins)] == "Yes")) / length(eval()$rep[which(eval()$ins %in% input$ins)])) > 0.5) {temp <- as.character(bs_icon("emoji-smile-fill"))}
        return(temp)
    })
    ## course quality
    output$value.cq <- renderText({
        if (input$code == "None") {temp <- "Select a Course"}
        else {temp <- paste0(mean(as.numeric(eval()$course[which(eval()$code %in% input$code)]), na.rm = TRUE), "/10")}
        return(temp)
    })
    output$figure.cq <- renderText({
        if (is.na(mean(as.numeric(eval()$course[which(eval()$code %in% input$code)]), na.rm = TRUE))) {temp <- as.character(bs_icon("journal"))}
        else if (input$code == "None") {temp <- as.character(bs_icon("journal"))}
        else if (mean(as.numeric(eval()$course[which(eval()$code %in% input$code)]), na.rm = TRUE) < .5) {temp <- as.character(bs_icon("journal-arrow-down"))}
        else if (mean(as.numeric(eval()$course[which(eval()$code %in% input$code)]), na.rm = TRUE) == .5) {temp <- as.character(bs_icon("journal"))}
        else if (mean(as.numeric(eval()$course[which(eval()$code %in% input$code)]), na.rm = TRUE) > .5) {temp <- as.character(bs_icon("journal-arrow-up"))}
        return(temp)
    })
    ## course difficulty
    output$value.cd <- renderText({
        if (input$code == "None") {temp <- "Select a Course"}
        else {temp <- paste0(mean(as.numeric(eval()$diff[which(eval()$code %in% input$code)]), na.rm = TRUE), "/10")}
        return(temp)
    })
    output$figure.cd <- renderText({
        if (is.na(mean(as.numeric(eval()$diff[which(eval()$code %in% input$code)]), na.rm = TRUE))) {temp <- as.character(bs_icon("star-half"))}
        else if (input$code == "None") {temp <- as.character(bs_icon("star-half"))}
        else if (mean(as.numeric(eval()$diff[which(eval()$code %in% input$code)]), na.rm = TRUE) < .5) {temp <- as.character(bs_icon("star"))}
        else if (mean(as.numeric(eval()$diff[which(eval()$code %in% input$code)]), na.rm = TRUE) == .5) {temp <- as.character(bs_icon("star-half"))}
        else if (mean(as.numeric(eval()$diff[which(eval()$code %in% input$code)]), na.rm = TRUE) > .5) {temp <- as.character(bs_icon("star-fill"))}
        return(temp)
    })
    ## gpa
    output$value.gpa <- renderText({
        if (input$code == "None") {temp <- "Select a Course"}
        else {temp <- mean(as.numeric(eval()$gpa[which(eval()$code %in% input$code)]), na.rm = TRUE)}
        return(temp)
    })
    output$figure.gpa <- renderText({
        if (is.na(mean(as.numeric(eval()$gpa[which(eval()$code %in% input$code)]), na.rm = TRUE))) {temp <- as.character(bs_icon("arrow-left-circle-fill"))}
        else if (input$code == "None") {temp <- as.character(bs_icon("arrow-left-circle-fill"))}
        else if (mean(as.numeric(eval()$gpa[which(eval()$code %in% input$code)]), na.rm = TRUE) < .5) {temp <- as.character(bs_icon("arrow-down-circle-fill"))}
        else if (mean(as.numeric(eval()$gpa[which(eval()$code %in% input$code)]), na.rm = TRUE) == .5) {temp <- as.character(bs_icon("arrow-left-circle-fill"))}
        else if (mean(as.numeric(eval()$gpa[which(eval()$code %in% input$code)]), na.rm = TRUE) > .5) {temp <- as.character(bs_icon("arrow-up-circle-fill"))}
        return(temp)
    })
}

###################################################################################################

# RENDER ##########################################################################################
shinyApp(ui, server)
###################################################################################################