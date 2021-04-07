library(shiny)
library(shinyjs)
library(shinythemes)
library(r2d3)

inputUserid <- function(inputId, value='') {
  #   print(paste(inputId, "=", value))
  tagList(
    singleton(tags$head(tags$script(src = "js/md5.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shinyBindings.js", type='text/javascript'))),
    tags$body(onload="setvalues()"),
    tags$input(id = inputId, class = "userid", value=as.character(value), type="text", style="display:none;")
  )
}

inputIp <- function(inputId, value=''){
  tagList(
    singleton(tags$head(tags$script(src = "js/md5.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shinyBindings.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/action.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/tinycolor.js", type='text/javascript'))),
    tags$body(onload="setvalues()"),
    tags$input(id = inputId, class = "ipaddr", value=as.character(value), type="text", style="display:none;")
  )
}

inputBrowserDims <- tags$head(
  tags$script('
    var dimension = [0, 0];
    $(document).on("shiny:connected", function(e) {
        dimension[0] = window.innerWidth;
        dimension[1] = window.innerHeight;
        Shiny.setInputValue("dimension", dimension);
    });
    $(window).resize(function(e) {
        dimension[0] = window.innerWidth;
        dimension[1] = window.innerHeight;
        Shiny.setInputValue("dimension", dimension);
    });
  '))


fluidPage(
  theme = shinytheme("cerulean"),
  tags$style(type = "text/css",
             # Define the col widths
             ".left {width:25%;height:100%;padding:10px;}",
             ".right {width:75%;height:100%;padding:10px;}",
             # Define the column position and background
             "#one {float:left; background-color:#fbfbfb;color:#555555;}",
             "#two {float:right;background-color:#ffffff;}",
             # Fix text highlighting
             ".left .checkbox span {color: #555555;}",
             ".left label {color: #555555;}",
             # Scale image to 80% of browser window height
             ".full-lineup-container img {object-fit:contain; height:80vh; max-width:100%;}",
             ".ex-lineup-container img {object-fit:contain; height:20vh;}",
             ".full-lineup-container svg {object-fit:contain; height:80vh; max-width:100%; padding:0; margin:0;}",
             ".ex-lineup-container svg {object-fit:contain; height:20vh;}"),
  inputBrowserDims,
  useShinyjs(),
  fluidRow(
    column(id = "one", width = 3,
  # div(
    # id = "one", class = "left",
    # This panel shows if the experiment was chosen and informed consent hasn't been given
    conditionalPanel(
      condition = "!input.welcome",
      h4("Welcome"),
      helpText(
        "In this survey points following a trend will be shown.",
        "We would like you to finish drawing the trend for the light yellow box using your mouse."),
      # helpText("1. Pick the plot based on the survey question"),
      # helpText("2. Provide reasons for choice"),
      # helpText("3. How certain are you?"),
      helpText(
        "Finally we would like to collect some information about you.",
        "(age category, education and gender)"),
      helpText(
        "Your response is voluntary and any information we collect from you will be kept confidential.",
        "Please read the informed consent document (click the button below) before you decide whether to participate."),

      a("Show Informed Consent Document", href = "informed_consent.html", target = "_blank"),

      checkboxInput("consent","I have read the informed consent document and agree.", width = "100%"),

      actionButton("beginexp", "Begin Experiment", class = "btn btn-info")
    ),
    # This shows once informed consent has been provided (demographics)
    conditionalPanel(
      condition = "input.welcome && !input.ready",
      h4("Demographic Information"),
      # textInput("turk", "nickname"),
      inputIp("ipid"),
      inputUserid("nickname"),
      selectizeInput("age", "Age Range",
                     choices = c("", "Under 19", "19-25", "26-30",
                                 "31-35", "36-40", "41-45", "46-50",
                                 "51-55", "56-60", "Over 60",
                                 "Prefer not to answer")),
      radioButtons("gender", "Gender Identity",
                   choices = c("Female", "Male",
                               "Variant/Nonconforming",
                               "Prefer not to answer"),
                   selected = NA),
      selectizeInput("education",
                     "Highest Education Level",
                     choices = c("", "High School or Less",
                                 "Some Undergraduate Courses",
                                 "Undergraduate Degree",
                                 "Some Graduate Courses",
                                 "Graduate Degree",
                                 "Prefer not to answer")),
      selectizeInput("recruitment",
                     "How were you recruited for participation in this study?",
                     choices = c("", "Reddit",
                                 "Prolific",
                                 "Graphics Group",
                                 "Direct Email",
                                 "I am the researcher",
                                 "Other")),

      actionButton("submitdemo", "Submit Demographics", class = "btn btn-info")
    ),

    # These panels are to determine what stage the experiment is at
    conditionalPanel(condition = "input.submit == null",
                     checkboxInput("welcome", "Welcome", value = FALSE)
    ),

    # conditionalPanel(condition = "input.submit == null",
                     # checkboxInput("otheronly", "", value = FALSE)
    # ),

    conditionalPanel(condition = "input.submit == null",
                     checkboxInput("ready", "Ready", value = FALSE)
    ),

    conditionalPanel(condition = "input.submit == null",
                     checkboxInput("done", "Done", value = FALSE)
    ),

    # This panel is for lineup questions
    conditionalPanel(
      condition = "input.ready && !input.done",
      # h4("Selection"),
      # textInput("response_no", "Choice", value = NULL, placeholder = "Click the plot to select"),
      # selectizeInput("response_no", "", choices = 1:20, selected = NULL, multiple = T),
      checkboxInput("show_finished", "Show Finished?", value = T),

      # Handle other reasoning logic
      # conditionalPanel(condition = "!input.otheronly",
                       # checkboxGroupInput("reasoning", "Reasoning", choices = "")
      # ),
      # conditionalPanel(condition = "input.reasoning.indexOf('Other') > -1 || input.otheronly",
                       # textInput("other", "Other Reason")
      # ),

      # selectizeInput("certain", "How certain are you?",
                     # choices = c("", "Very Uncertain", "Uncertain",
                                 # "Neutral", "Certain", "Very Certain")),
      actionButton("submit", "Submit", icon = icon("caret-right"), class = "btn btn-info"),
      hr(),
      h4("Status"),
      h5(textOutput("status"))
    )
  ),
  # div(
  #   id = "two", class = "right",
  column(id = "two", width = 9,
    conditionalPanel(condition = "!input.welcome",
                     h4(textOutput("welcome_header")),
                     uiOutput("welcome_text"),

                     h4(textOutput("example1_q")),
                     # div(
                       # class = "ex-lineup-container",
                       # imageOutput("example1_plot", height = "auto")
                       img(src="examples/exponential.gif", align = "center", width = 350),
                     # ),

                     h4(textOutput("example2_q")),
                     # div(
                       # class = "ex-lineup-container",
                       # imageOutput("example2_plot", height = "auto")
                       img(src="examples/linear1.gif", align = "center", width = 350)
                     # )
    ),
    conditionalPanel(condition = "input.welcome && !input.ready",
                     h4(textOutput("demo_text"))
    ),

    conditionalPanel(condition = "input.ready",
                     h3(textOutput("question"))
                     #conditionalPanel(condition = "input.done",
                     #    HTML("<a href='https://prolificacademic.co.uk/submissions/56293369c8ffc200055132fd/complete?cc=XYA822O3'>https://prolificacademic.co.uk/submissions/56293369c8ffc200055132fd/complete?cc=XYA822O3</a>")
                     #)
    ),
    hr(),
    d3Output("shinydrawr", 
             height = "500px") #,
    # hr(),
    # p("Recorded Data:"),
    # DT::dataTableOutput("drawrmessage", width = "70%")
  )
  # Javascript action script for lineups -- may not be necessary
  # includeScript("www/js/action.js")
)
)