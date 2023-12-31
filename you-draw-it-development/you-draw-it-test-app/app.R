# Load libraries
library(shiny)
library(shinyjs)
library(r2d3) # ALERT: REQUIRES VERSION 
# url_r2d3v0.2.3 <- "https://cran.r-project.org/src/contrib/Archive/r2d3/r2d3_0.2.3.tar.gz"
# install.packages(url_r2d3v0.2.3, repos = NULL, type = 'source')
library(tidyverse)
library(gridSVG)
library(lubridate)
library(readxl)
library(DT)

# Redefine drawr function
drawr <- function(data, 
                  linear = "true", 
                  draw_start = mean(data$x),
                  points_end = max(data$x)*(3/4),
                  x_by = 0.25,
                  free_draw = T,
                  points = "partial",
                  aspect_ratio = 1.5,
                  title = "", 
                  x_range = NULL, 
                  y_range = NULL,
                  x_lab = "", 
                  y_lab = "", 
                  drawn_line_color = "orangered",
                  data_tab1_color = "steelblue", 
                  x_axis_buffer = 0.01, 
                  y_axis_buffer = 0.05,
                  show_finished = T,
                  shiny_message_loc = NULL) {
  
  plot_data <- dplyr::select(data, x, y, ypoints)
  x_min <- min(plot_data$x)
  x_max <- max(plot_data$x)
  y_min <- min(plot_data$y)
  y_max <- max(plot_data$y)
  if (is.null(x_range)) {
    x_buffer <- (x_max - x_min) * x_axis_buffer
    x_range <- c(x_min - x_buffer, x_max + x_buffer)
  }
  if (is.null(y_range)) {
    y_buffer <- (y_max - y_min) * y_axis_buffer
    y_range <- c(y_min - y_buffer, y_max + y_buffer)
    if (linear != "true") {
      if (y_range[1] <= 0) {
        y_range[1] <- min(y_min, y_axis_buffer)
      }
    }
  } else {
    if (y_range[1] > y_min | y_range[2] < y_max) {
      stop("Supplied y range doesn't cover data fully.")
    }
  }

  if ((draw_start <= x_min) | (draw_start >= x_max)) {
    stop("Draw start is out of data range.")
  }

  r2d3::r2d3(plot_data, "main.js",
             dependencies = c("d3-jetpack"),
             options = list(draw_start = draw_start, 
                            points_end = points_end,
                            linear = as.character(linear),
                            free_draw = free_draw, 
                            points = points,
                            aspect_ratio = aspect_ratio,
                            pin_start = T, 
                            x_range = x_range,
                            x_by = x_by,
                            y_range = y_range,
                            line_style = NULL,
                            data_tab1_color = data_tab1_color, 
                            drawn_line_color = drawn_line_color,
                            show_finished = show_finished,
                            shiny_message_loc = shiny_message_loc)
             )
  
}


# Define UI for application that draws a histogram
ui <- navbarPage(
  "You Draw It Development",
  
  # ---- Tab 1 ---------------------------------------------------------------
  tabPanel(
    title = "Test",
    
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "d3.css")
    ),
    fluidRow(
      column(
        width = 7,
        helpText("What will this line look like? Using your mouse, draw within the yellow shaded region
                  to fill in the values: maintaining the previous trend or best fit through points."),
        # This is our "wrapper"
        d3Output("shinydrawr", height = "500px"),
        # drawrmessage is the table id for the Recorded data
        p("Recorded Data:"),
        DT::dataTableOutput("drawrmessage", width = "70%")
      ),
      column(
        width = 2,
        p("Data Simulation Parameters:"),
        numericInput("beta", "Beta:", min = 0.05, max = 0.5, value = 0.2, step = 0.05),
        numericInput("sd", "SD:", min = 0.05, max = 0.5, value = 0.2, step = 0.05),
        numericInput("Npoints", "N Points:", min = 10, max = 50, value = 20, step = 5),
        numericInput("by", "Stepby:", min = 0.05, max = 0.5, value = 0.25, step = 0.05)
      ),
      column(
        width = 3,
        p("Aesthetic Plot Choices:"),
        checkboxInput("show_finished", "Show Finished?", value = T),
        checkboxInput("drawr_linear_axis", "Linear Y Axis?", value = T),
        checkboxInput("free_draw_box", "Free Draw?", value = F),
        radioButtons("points_choice", "Points?", choices = c("full", "partial", "none"), selected = "partial"),
        sliderInput("draw_start_slider", "Draw Start?", min = 4, max = 19, value = 10, step = 1),
        sliderInput("points_end", "Points End?", min = 4, max = 19, value = 15, step = 1),
        sliderInput("yrange_lower", label = "y-range lower buffer:", min = 0.25, max = 1, step = 0.25, value = 0.75),
        sliderInput("yrange_upper", label = "y-range upper buffer:", min = 1, max = 4, step = 0.25, value = 2),
        sliderInput("aspect_ratio", "Aspect Ratio:", min = 1, max = 2, value = 1, step = 0.25)
      )
    )
  )
  # ---- End UI --------------------------------------------------------------
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # message_loc and drawr_message
  # Somehow takes the points the user drew and records them.
  message_loc <- session$ns("drawr_message")
  drawn_data <- shiny::reactiveVal()
  
  # Provides a line for the data. (no errors)
  dataInput <- reactive({
                
                # generate line data
                line_data <- tibble(x = seq(1, 20, input$by), 
                                    y = exp(x*input$beta)
                                    )
                
                # generate point data
                if(input$points_choice == "full"){
                  xVals <- sample(line_data$x, input$Npoints, replace = F)
                } else {
                  xVals <- sample(line_data$x[line_data$x <= input$points_end], input$Npoints, replace = F)
                }
                repeat{
                  errorVals <- rnorm(length(xVals), 0, input$sd)
                  if(mean(errorVals[10]) < 2*input$sd & mean(errorVals[10] > -2*input$sd)){
                    break
                  }
                }
                point_data <- tibble(x = xVals,
                                     ypoints = exp(x*input$beta + errorVals)
                                     )
                
                full_join(line_data, point_data, by = "x") %>%
                  mutate(ypoints = ifelse(is.na(ypoints), 0, ypoints))
                
                })
  
  # shinydrawer is the id of our "wrapper" this is what draws our line
  output$shinydrawr <- r2d3::renderD3({
    
    data <- dataInput()
    y_range <- range(data$y) * c(as.numeric(input$yrange_lower), as.numeric(input$yrange_upper))
    
    # if linear box is checked, then T else F
    islinear <- ifelse(input$drawr_linear_axis, "true", "false")

    # Use redef'd drawr function...r2d3 is built into here.. how do we add points???
    drawr(data              = data,
          aspect_ratio      = input$aspect_ratio,
          linear            = islinear, # see function above
          free_draw         = input$free_draw_box,
          points            = input$points_choice,
          x_by              = input$by,
          draw_start        = input$draw_start_slider,
          points_end        = input$points_end,
          show_finished     = input$show_finished,
          shiny_message_loc = message_loc,
          x_range           = range(data$x), # covers the range of the sequence we define
          y_range           = y_range, # we define this above to span our data + some
          drawn_line_color  = "steelblue" # color the user's line is drawn in
          )
  })

  # Clears Recorded Data table when you toggle between log and linear
  shiny::observeEvent(input$drawr_linear_axis, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$free_draw_box, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$points_choice, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$draw_start_slider, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$ymag_range, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$aspect_ratio, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$by, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$beta, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$sd, {
    drawn_data(NULL)
  })
  shiny::observeEvent(input$Npoints,{
    drawn_data(NULL)
  })
  shiny::observeEvent(input$show_finished,{
    drawn_data(NULL)
  })
  
  
  # creates data set that contains the x value, actual y value, and drawn y value (drawn = input$drawr_message
  # for the x values >= starting draw point
  # WHAT DOES THE %>% drawn_data() do?? does that rename it so we can reference this?
  shiny::observeEvent(input$drawr_message, {
    
    if(input$free_draw_box){
    dataInput() %>%
      # dplyr::filter(x >= input$draw_start_slider) %>%
      dplyr::mutate(drawn = input$drawr_message) %>%
      dplyr::select(x, y, drawn) %>%
      drawn_data()
    } else{
      dataInput() %>%
        dplyr::filter(x >= input$draw_start_slider) %>%
        dplyr::mutate(drawn = input$drawr_message) %>%
        dplyr::select(x, y, drawn) %>%
        drawn_data()
    }
    
  })

  # Fills in the Recorded Data table... see id drawrmessage in developer tools on browser.
  output$drawrmessage <- DT::renderDataTable({
    drawn_data()
  })

}

# Run the application
shinyApp(ui = ui, server = server)
