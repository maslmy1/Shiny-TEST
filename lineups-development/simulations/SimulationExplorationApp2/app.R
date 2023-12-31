library(shiny)
library(shinyjs)
require(tidyverse)
require(gridExtra)
require(scales)

# Define functions ---------------------------------------------------------------------------------------

# ExponentialSimulation
simulate.exponential <- 
    function(N, xRange = c(1,N), nReps, beta, muErr = 0, sdErr, errorType, ...){
        
        exp.data <- data.frame(x = rep(seq(xRange[1], xRange[2], length.out = N), nReps), y = NA)
        
        theta <- 0
        
        if(errorType %in% c("Mult", "mult", "Multiplicative", "multiplicative")){
            # alpha <- sqrt(1/(exp(2*sdErr^2)-exp(sdErr^2)))
            alpha <- 1/(exp((sdErr^2)/2))
            exp.data$y <- alpha*exp(beta*exp.data$x + rnorm(N*nReps, muErr, sdErr)) + theta
        } else { 
            alpha <- 1
            if(errorType %in% c("Add", "add", "Additive", "additive")){
                exp.data$y <- alpha*exp(beta*exp.data$x) + theta + rnorm(N*nReps, muErr, sdErr)
            }
        }
        
        return(exp.data)
    }

# Quadratic Simulation

simulate.quadratic <- 
    function(N, nReps, xRange = c(1,N), beta0, beta1, beta2, muErr, sdErr, ...){
        
        quad.data <- data.frame(x = rep(seq(xRange[1], xRange[2], length.out = N), nReps), y = NA)
        quad.data$y <- beta0 + beta1*quad.data$x + beta2*quad.data$x^2 + rnorm(N*nReps, muErr, sdErr)
        
        return(quad.data)
    }

# Overall Simulation Function

simulate.data <- 
    function(functionalForm, ...){
        if(functionalForm %in% c("Exponential")){
            sim.data <- simulate.exponential(...)
        }
        if(functionalForm %in% c("Quadratic")){
            sim.data <- simulate.quadratic(...)
        }
        
        return(sim.data)
    }

# Evaluate Fit

fit.models <- 
    function(sim.data){
        
        #fit glm exponential model (BEWARE HERE)
        glm.mod <- glm(y ~ x, data = sim.data, family = gaussian(link="log"))
        
        # fit quadratic model
        quad.mod  <- lm(y ~ x + I(x^2), data = sim.data)
        
        # fit linear model
        lin.mod   <- lm(y ~ x, data = sim.data)
        
        # Calculate lack of fit
        if(nrow(sim.data)/length(unique(sim.data$x)) > 1){
            lof.mod <- lm(y ~ x + as.factor(x), data = sim.data)
            lof <- anova(lof.mod) %>% 
                as.data.frame() %>%
                filter(row.names(.) == "as.factor(x)")
        } else {
            lof.mod <- NULL
            lof <- NULL
        }
        
        # return(list(sim.data = sim.data, glm.mod = glm.mod, exp.mod = exp.mod, quad.mod = quad.mod, lin.mod = lin.mod, lof.mod = lof.mod, lof = lof))
        return(list(sim.data = sim.data, glm.mod = glm.mod, quad.mod = quad.mod, lin.mod = lin.mod, lof.mod = lof.mod, lof = lof))
    }

# Evaluate LOF
calcLOF <- 
    function(sim.data){
        
        # Calculate lack of fit
        if(nrow(sim.data)/length(unique(sim.data$x)) > 1){
            lof.mod <- lm(y ~ x + as.factor(x), data = sim.data)
            lof <- anova(lof.mod) %>% 
                as.data.frame() %>%
                filter(row.names(.) == "as.factor(x)")
        } else {
            lof.mod <- NULL
            lof <- NULL
        }
        
        return(list(lof = lof))
    }

# Define UI for application that draws a histogram
ui <- navbarPage(
    "Simulation Exploration",
    
    # ---- Tab 1 ---------------------------------------------------------------
    tabPanel(
        title = "Algebraic Simulation",
        fluidRow(
            column(width = 2,
                wellPanel(id = "tPanel",style = "overflow-y:scroll; max-height: 600px",
                    selectInput("functionalForm_tab1", "Functional Form:", c("Exponential")),
                    sliderInput("xRange_tab1", "x-Axis Range", min = 0, max = 200, value = c(0, 30)),
                    # numericInput("maxMag_tab1", "Magnitude", value = 100, min = 0, max = 100000, step = 10),
                    sliderInput("n_tab1", "Sample Size (n):", min = 5, max = 200, value = 20),
                    sliderInput("nReps_tab1", "Number of reps per x:", min = 1, max = 10, value = 1),
                    numericInput("muErr_tab1", "Error Mean:", value = 0, min = 0, max = 10, step = 1),
                    numericInput("sdErr_tab1", "Error SD:", value = 0.05, min = 0, max = 50, step = 0.05),
                    selectInput("errorType_tab1", "Error Type:", c("Multiplicative", "Additive")),
            
                    helpText("Exponential Regression Coefficients:"),
                    numericInput("beta_tab1", "\u03B2:", value = 0.03, min = 0, max = 2, step = 0.01),
               
                    # helpText("Quadratic Regression Coefficients:"),
                    # numericInput("beta0_tab1", "\u03B2\u2080:", value = 0.1, min = 0, max = 5, step = 0.05),
                    # numericInput("beta1_tab1", "\u03B2\u2081:", value = 0, min = -5, max = 20, step = 1),
                    # numericInput("beta2_tab1", "\u03B2\u2082:", value = 0.25, min = 0, max = 10, step = 0.05)
                )
            ),
            column(
                width = 7,
                helpText("Exponential Model (additive): \u03B1exp(\u03B2x) + error"),
                helpText("Exponential Model (multiplicative): \u03B1exp(\u03B2x + error)"),
                # helpText("Quadratic Model: \u03B2\u2080 + \u03B2\u2081x + \u03B2\u2082x\u00B2 + error"),
                plotOutput("plots_tab1", height = "500px")
 
            ),
            column(  
                width = 2,
                checkboxGroupInput("lin.fit_tab1", "Linear Scale Fitted Lines:", c("Exponential (glm)", "Linear", "Quadratic")),
                checkboxGroupInput("log.fit_tab1", "Log Scale  Fitted Lines:", c("Exponential (glm)", "Linear", "Quadratic")),
                helpText("Lack of Fit Test:"),
                helpText("F test from lm(y ~ x + as.factor(x)):"),
                tableOutput("lofTable_tab1")
            )
        )
    )
    
    # ---- End UI --------------------------------------------------------------
)

# Define server
server <- function(input, output, session) {
    
    # ---- Tab 1 ---------------------------------------------------------------
    
    
    sim.data_tab1 <- reactive({
        simulate.data(functionalForm = input$functionalForm_tab1, 
                                  N = input$n_tab1, 
                                  nReps = input$nReps_tab1,
                                  xRange = input$xRange_tab1,
                                  
                                  # Exponential Parameters
                                  beta = input$beta_tab1, 
                                  
                                  # Quadratic Parameters
                                  # beta0 = input$beta0_tab1,
                                  # beta1 = input$beta1_tab1, 
                                  # beta2 = input$beta2_tab1,
                                  
                                  muErr = input$muErr_tab1,
                                  sdErr = input$sdErr_tab1,
                                  errorType = input$errorType_tab1)
    })
    
    
    sim.fit_tab1 <- reactive({
        fit.models(sim.data_tab1())
    })
    
    output$plots_tab1 <- renderPlot({
        
        sim.data <- sim.data_tab1()
        sim.fit  <- sim.fit_tab1()
        
        lin.fit <- input$lin.fit_tab1
        
        lin.plot <- sim.data %>%
            ggplot(aes(x = x, y = y)) +
            geom_point(shape = 1) +
            scale_color_brewer(palette = "Paired") +
            theme_bw() +
            theme(legend.position="bottom") +
            ggtitle("Linear")
        if("Exponential (glm)" %in% lin.fit){
            lin.plot <- lin.plot + geom_line(aes(y = predict(sim.fit$glm.mod, type = "response"), color = "Exponential \n (glm)"))
        } 
        if("Exponential (nonlinear)" %in% lin.fit){
            lin.plot <- lin.plot + geom_line(aes(y = predict(sim.fit$exp.mod), color = "Exponential \n (nonlinear)"))
        } 
        if("Linear" %in% lin.fit){
            lin.plot <- lin.plot + geom_line(aes(y = predict(sim.fit$lin.mod), color = "Linear"))
        } 
        if("Quadratic" %in% lin.fit){
            lin.plot <- lin.plot + geom_line(aes(y = predict(sim.fit$quad.mod), color = "Quadratic"))
        }
        
        log.fit <- input$log.fit_tab1
        
        log.plot <- sim.data %>%
            ggplot(aes(x = x, y = y)) +
            geom_point(shape = 1) +
            scale_y_continuous(trans = "log10",
                               breaks = trans_breaks("log10", function(x) 10^x),
                               labels = trans_format("log10", math_format(10^.x))) +
            scale_color_brewer(palette = "Paired") +
            theme_bw() +
            theme(legend.position="bottom") +
            ggtitle("Log")
        if("Exponential (glm)" %in% log.fit){
            log.plot <- log.plot + geom_line(aes(y = predict(sim.fit$glm.mod, type = "response"), color = "Exponential \n (glm)"))
        } 
        if("Exponential (nonlinear)" %in% log.fit){
            log.plot <- log.plot + geom_line(aes(y = predict(sim.fit$exp.mod), color = "Exponential \n (nonlinear)"))
        } 
        if("Linear" %in% log.fit){
            log.plot <- log.plot + geom_line(aes(y = predict(sim.fit$lin.mod), color = "Linear"))
        } 
        if("Quadratic" %in% log.fit){
            log.plot <- log.plot + geom_line(aes(y = predict(sim.fit$quad.mod), color = "Quadratic"))
        }
        
        grid.arrange(lin.plot, log.plot, ncol=2)
        
    })
    
    output$lofTable_tab1 <- renderTable({
        sim.fit  <- sim.fit_tab1()
        sim.fit$lof
    })
    
    # ---- End Server --------------------------------------------------------------
}

# Run the application
shinyApp(ui = ui, server = server)
