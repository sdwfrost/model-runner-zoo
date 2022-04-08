setRepositories(ind=1:2)
pkgs <- c(
  "deSolve",
  "rootSolve",
  "jsonlite",
  "jsonvalidate"
)
install.packages(pkgs, dependencies=TRUE, clean=TRUE, repos='https://cran.microsoft.com/snapshot/2022-03-30')
