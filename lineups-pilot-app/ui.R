library(shiny)
library(shinyjs)
library(shinythemes)


fluidPage(theme = shinytheme("cerulean"),

    useShinyjs(),

    sidebarLayout(
        sidebarPanel(width = 3,
            # This panel shows if the experiment was chosen and informed consent hasn't been given
            conditionalPanel(
                condition = "!input.welcome",
                h4("Welcome"),
                helpText(
                    "In this survey a series of similar looking charts will be presented.",
                    "We would like you to respond to the following questions."),
                helpText("1. Pick the plot based on the survey question"),
                helpText("2. Provide reasons for choice"),
                helpText("3. How certain are you?"),
                helpText(
                    "Finally we would like to collect some information about you.",
                    "(age category, education and gender)"),
                helpText(
                    "Your response is voluntary and any information we collect from you will be kept confidential.",
                    "Please read the informed consent document (click the button below) before you decide whether to participate."),

                a("Show Informed Consent Document", href = "informed_consent.html", target = "_blank"),

                checkboxInput(
                    "consent",
                    HTML(paste0("I have read the informed consent document and agree."))),

                actionButton("beginexp", "Begin Experiment", class = "btn btn-info")
            ),
            # This shows once informed consent has been provided (demographics)
            conditionalPanel(
                condition = "input.welcome && !input.ready",
                h4("Demographic Information"),
                textInput("turk", "nickname"),
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

                actionButton("submitdemo", "Submit Demographics", class = "btn btn-info")
            ),

            # These panels are to determine what stage the experiment is at
            conditionalPanel(condition = "input.response_no == null",
                             checkboxInput("welcome", "Welcome", value = FALSE)
            ),

            conditionalPanel(condition = "input.response_no == null",
                             checkboxInput("otheronly", "", value = FALSE)
            ),

            conditionalPanel(condition = "input.response_no == null",
                checkboxInput("ready", "Ready", value = FALSE)
            ),

            conditionalPanel(condition = "input.response_no == null",
                             checkboxInput("done", "Done", value = FALSE)
            ),

            # This panel is for lineup questions
            conditionalPanel(
                condition = "input.ready && !input.done",
                h4("Selection"),
                textInput("response_no", "Choice (Click on plot to select)", value = ""),

                # Handle other reasoning logic
                conditionalPanel(condition = "!input.otheronly",
                                 checkboxGroupInput("reasoning", "Reasoning", choices = "")
                ),
                conditionalPanel(condition = "input.reasoning.indexOf('Other') > -1 || input.otheronly",
                                 textInput("other", "Other Reason")
                ),

                selectizeInput("certain", "How certain are you?",
                               choices = c("", "Very Uncertain", "Uncertain",
                                           "Neutral", "Certain", "Very Certain")),
                actionButton("submit", "Submit", icon = icon("caret-right"), class = "btn btn-info"),
                hr(),
                h4("Status"),
                h5(textOutput("status"))
            )
        ),

        mainPanel(width = 9,
            #h4(textOutput("debug")),
            conditionalPanel(condition = "!input.welcome",
                h4(textOutput("welcome_header")),
                uiOutput("welcome_text"),

                h4(textOutput("example1_q")),
                imageOutput("example1_plot", height = "auto"),

                br(),
                br(),

                uiOutput("example1_a"),

                h4(textOutput("example2_q")),
                imageOutput("example2_plot", height = "auto"),

                br(),
                br(),

                uiOutput("example2_a")
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
            uiOutput("lineup")
        )
    ),
# Javascript action script for lineups -- may not be necessary
    includeScript("www/js/action.js")
)