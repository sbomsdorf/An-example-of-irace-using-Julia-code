# show the working directory
getwd()
# load the irace results
iraceResults <- read_logfile("./my.julia/irace_test/code/irace.Rdata")

# show the irace results
View(iraceResults)

# show the algorithm configurations
head(iraceResults$allConfigurations)

# prints the elite candidate configurations per iteration
print(iraceResults$allElites)

# get the final elite configuration
library("irace")
getFinalElites("./my.julia/irace_test/code/irace.Rdata", n = 0)
