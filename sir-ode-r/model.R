library(deSolve)
library(rootSolve)
library(jsonlite) 
library(jsonvalidate)
library(rstudioapi)

ARGS <- commandArgs(trailingOnly=TRUE)
print(ARGS)
# IO
if(length(ARGS)>1){
  model_input_fn <- ARGS[1]
  model_output_fn <- ARGS[2]
  model_input_schema_fn <- ARGS[3]
  model_output_schema_fn <- ARGS[4]
} else {
  model_input_fn <- "test/input.json"
  model_output_fn <- "output/data.json"
  model_input_schema_fn <- "schema/input.json"
  model_output_schema_fn <- "schema/output.json"
}

model_input_check <- json_validate(model_input_fn,model_input_schema_fn)
if(!model_input_check){
  quit(save="no",status=1)
}

model_input <- read_json(model_input_fn, simplifyVector = TRUE)

model <- function(t, u, p) {
  with (as.list(c(u, p)),{
    dS <- -b*S*I
    dI <- b*S*I-g*I
    dR <- g*I
    list(c(dS,dI,dR))
  })
}


p <- unlist(model_input$p)
names(p) <- c("b","g")
u0 <- unlist(model_input$u0)
names(u0) <- c("S","I","R")
tspan <- unlist(model_input$tspan)
dt <- unlist(model_input$dt)

ss <- runsteady(y = u0, fun = model, parms = p, times = tspan)
fs <- unname(ss$y[3])
tss <- attr(ss,"time")

## Run model separately to get peak infected and time
sol <- ode(y = u0 , times=seq(tspan[1],tss,by=dt), model, parms=p)
sol_df <- as.data.frame(sol)
f <- splinefun(x=sol_df$time,y=sol_df$I)
pkt <- uniroot(function(x){f(x,deriv=1)},c(tspan[1],tss))$root
pk <- f(pkt)

# Extract outputs and validate
model_output = list(metadata = model_input, t = sol_df$time, u=t(sol[,2:4]), outputs = c(fs,pk,pkt))

write_json(model_output, model_output_fn, na = "null", auto_unbox=TRUE, digits=17, pretty=TRUE)
model_output_check = json_validate(model_output_fn, model_output_schema_fn)

if(!model_output_check){
  quit(save="no",status=1)
}

print(model_output)

quit(save="no",status=0)
