# How to use irace with your Julia code

This **repository** contains an exemplary setup that uses the [R](https://www.r-project.org/about.html) package [irace: Iterated Racing for Automatic Algorithm Configuration](https://mlopez-ibanez.github.io/irace/) with a code project written in [Julia](https://julialang.org/). It is set up to use a minimum running example on a Windows computer.

- `.\code` contains the Julia code including the environment (see [Pkg.jl](https://docs.julialang.org/en/v1/stdlib/Pkg/)) and a small R-script to view the examplary output of irace `irace.Rdata`
- `.\tuning` contains files necessary for irace

The following **guide** only contains a brief introduction to irace. Think of it as a **"tl;dr"** for the [irace user guide](https://cran.r-project.org/package=irace/vignettes/irace-package.pdf) combined with an introduction to command line arguments in Julia.
For an extensive user guide including a way wider range of configurations and usage scenarios, please, refer to the irace user guide.

## Installation of irace

Follow the instruction on [https://mlopez-ibanez.github.io/irace/#quick-start](https://mlopez-ibanez.github.io/irace/#quick-start) to install both R and the irace package on your computer.

## Initialize the necessary files for irace

1. Navigate to the folder where you want to create the files and open a terminal there (or the other way around).
2. Run `irace --init` here.
3. Several files are being generated now such as configurations.txt, forbidden.txt, parameters.txt, etc.

## Adapt the configuration

### Parameters that you would like to set up for automatic tuning

#### parameters.txt

- A fixed set of parameters, must be defined as categorical. For example, if you want to test 100, 200, and 300 as values for a parameter, the configuration would be: `numIterations "--param " c (100,200, 300)`. Using this definition, irace adds `--param 100`, among the others, to the command line call. Note the empty space in the definition of the String `"--param "`.
- You can also define a continuous set of integer values to test a range of parameter values, for example, between 100 and 300:
`numIterations "--numIterations " i (100,300)`.
The same holds for real numbers (type in the `paramaters.txt` is `r` instead of `i`).

### General irace configuration

#### scenario.txt

- defines how irace is executed
- the file is well commented when initialized by `irace --init` and self-explaining.
- for an example, refer to the given `scenario.txt`

#### target-runner.bat

- irace runs the `target-runner.bat` located in the folder where you called `irace --init`. This script uses values passed by irace, calls your code and reads the output values. Please refer to the corresponding file in this git and the comments in this file for more details.
- irace always aims to minimize the output value of your code. So, if you aim to maximize the value, simply multiply it by `-1` before returning it.
- `target-runner.bat` is set up to read two values: the cost, i.e., the value irace aims to minimize, and the runtime which is used, e.g., for limiting the maximum runtime in irace but not part of the optimization. If you want to find a trade-off between minimizing the runtime and the objective function value (OFV) of your algorithm, you must find a single value that represents both. In the user guide, the authors propose a weighted sum. However, the weights of runtime and OFV are not trivial and must be chosen carefully.

## Prepare the target runner and your code

### Input

(_Hint:_ `%var%` denotes a variables called var in a .bat-script)

- your code must take input from irace as command line arguments
- in Julia, they can be accessed via the `ARGS` vector. For more elaborate usage of command line arguments, you can use [ArgParse.jl](https://github.com/carlobaldassi/ArgParse.jl). An example of this is given in `main.jl`
- the way your code is called is specified in `target-runner.bat`.
  - In case you are using an own environment or other values that are constant/the same for all calls of your code, you can specify this using the `fixed_params`.
  - the core call in the script is `julia %exe% %fixed_params% --inst=%instance% --seed=%seed% %candidate_parameters% --stdout=%stdout% --stderr=%stderr%`
    - this calls Julia to execute the code in the file `%exe%` with all the `%fixed_params%` and the additional parameters `inst`, `seed`, `stdout`, `stderr` and
      the parameters to be tuned `%candidate_parameters%`.
    - `%candidate_parameters%` must be defined in `parameters.txt` as described above.
  - the script expects two files created by your code: `%stdout%` and `%stderr%` (the file names are passed as input to your code).
  - in `%stdout%`, the `target-runner.bat` looks for two values in the last line of the file (might also be a single line). The first value is expected to be the cost, the second one is expected to be the runtime. Note that irace expects two values because `maxTime` is set in `scenario.txt`. If you want to use `maxEperiments` (only one of both can be set), irace expects a single value. For this, you need to both adapt the output of your code as well as the `.bat`-script to read a single value instead of two.

## Run irace

- navigate to the directory that contains the `target-runner.bat` as well as the configuration files and execute `irace` there.
- the output will be stored in the `execDir` defined in the `scenario.txt`
- the output is both `stderr` and `stdout` files for each instance as well as the irace results in a file called `irace.Rdata`.
  - there are several ways to access this data, first and foremost using R
  - if you are not familiar with R, you can pick another way to convert the data or simply view them in an IDE that is capable of showing `.RData` files.
  - an IDE built for R is, for example, [RStudio](https://posit.co/download/rstudio-desktop/).
  - alternatively, there is an [extension for VS Code](https://code.visualstudio.com/docs/languages/r).
  - in `read_results.r` you can find an example on how to read the results of irace
