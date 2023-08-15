@echo off
::##############################################################################
:: BAT version of target-runner for Windows.
:: Contributed by Andre de Souza Andrade <andre.andrade@uniriotec.br>.
:: Adapted by Stefan Bomsdorf <bomsdorf@dpo.rwth-aachen.de>
:: Check other examples in examples/
::
:: This script is run in the execution directory (execDir, --exec-dir).
::
:: PARAMETERS:
:: %%1 is the candidate configuration number
:: %%2 is the instance ID
:: %%3 is the seed
:: %%4 is the instance name
:: The rest are parameters to the target-algorithm
::
:: RETURN VALUE:
:: This script should print one numerical value: the cost that must be minimized.
:: Exit with 0 if no error, with 1 in case of error
::##############################################################################

:: Please change the EXE and FIXED_PARAMS to the correct ones
SET "exe=D:\src\repos\my.julia\irace_test\code\main.jl"

:: always activate the environment in the same directory as the %exe%
:: note, that this must be adapted to, e.g., "=../." if the environment is in the parent directory
SET "fixed_params= --project=."


:: This part reads the different configurations for irace
FOR /f "tokens=1-4*" %%a IN ("%*") DO (
	SET candidate=%%a
	SET instance_id=%%b
	SET seed=%%c
	SET instance=%%d
	SET candidate_parameters=%%e
)

:: Set the names of the output files
SET "stdout=c%candidate%-%instance_id%-%seed%.stdout"
SET "stderr=c%candidate%-%instance_id%-%seed%.stderr"


:: Run the file %exe% with julia with the fixed parameters and the ones passed by irace
julia %fixed_params% %exe% --inst %instance% --seed %seed% %candidate_parameters% --outfile %stdout% --errfile %stderr%


:: enables delayed variable expansing = variables executed at execution time, not at parse time
setlocal EnableDelayedExpansion
:: cmd will contain the number of lines in the file %stdout%
set "cmd=findstr /R /N "^^" %stdout% | find /C ":""
for /f %%a in ('!cmd!') do set numberlines=%%a
set /a lastline=%numberlines%-1
:: in the last line of the file %stdout%, the first part is the cost 
for /f "tokens=1" %%F in ('more +%lastline% %stdout%') do set COST=%%F
:: in the last line of the file %stdout%, the second part is the time 
for /f "tokens=2" %%F in ('more +%lastline% %stdout%') do set TIME=%%F

:: prints the necessary values to the command line for irace to read from
echo %COST% %TIME%

:: Un-comment this if you want to delete temporary files.
:: del %stdout% %stderr%
exit 0
