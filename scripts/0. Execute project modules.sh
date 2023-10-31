#!/usr/bin/env bash
# 0. Execute project modules.sh
# Erik Dean 2023
 
# This script can be used to runs all the scripts in this project,
# or a only subset of them to either 
# 1. download and process climate projection data
# 2. model young-of-year overwinter survival and output results

# ——————————————————————————————————————————————————————————————————————————————

# define functions to be called to perform commands

# for the first set of actions, run scripts 1 to 3 
function getData {
    printf "

    1.         Retrieving climate data    
                      _________
                     / ======= \\
                    /___________\\
                   | ___________ |
                   | | -       | |
                   | |         | |
                   | |_________| |                        
                   \=___________ /                         
                   / \"\"\"\"\"\"\"\"\"\"\" \                        
                  / ::::::::::::: \                      
                 (_________________)
  
    "

    # Step 1: download climate data
    printf "Downloading...                  (1/8)\r"
    #Bash ./1*.sh
    sleep 1 
     
    # Step 2: format climate data
    printf "        Formatting...               (2/8)\r"
    #Rscript ./2*.R
    sleep 1 
     
    # Step 3: convert climate data 
    printf "              Converting...         (3/8)\r"
    #Rscript ./3*.R
    sleep 1 
    
    # message upon completion
    printf "                    All finished!        \n\n"
}

# for the second set of actions, run scripts 4 to 8
function getResults {
    printf "
    2.     Running young-of-year fish model
 
                       /\`-._
                      /_,.._\`:-          
                  ,.-\'  ,   \`-:..-\')      
                 : o ):\\';      _  {      
                  \`-._ \`\'__,.-\'⑊\`-.)
                      \`⑊⑊  ⑊,.-\'\`
 
    "               

    # Step 4: load young-of-year fish model functions
    # (done by the script in the next step)
    printf "Loading model...                (4/8)\r"
    sleep 1
    
    # Step 5: run model with climate data
    printf "      Running model...              (5/8)\r"
    #Rscript ./5*.R
    sleep 1
     
    # Step 6: plot modelling results
    printf "        Plotting results...         (6/8)\r"
    #Rscript ./6*.R
    sleep 1
     
    # Step 7: produce timelines graphic
    printf "          Plotting timelines...     (7/8)\r"
    #Rscript ./7*.R
    sleep 1
     
    # Step 8: summarize and report results
    printf "             Summarizing results... (8/8)\r"
    #Rscript ./8*.R
    sleep 1
    
    # final message upon completion
    printf "                    All finished!         \n\n"
}

# ——————————————————————————————————————————————————————————————————————————————

# Needs defensive programming

# Display for user running the script
 
# print overview statement for user 
printf "
        ___       __  __  __                 __
       / _ )___  / /_/ /_/ /__ ___  ___ ____/ /__
      / _  / _ \/ __/ __/ / -_) _ \/ -_) __/  '_/
     /____/\___/\__/\__/_/\__/_//_/\__/\__/_/\_\\
   
  Modelling overwinter survival under climate change 
for young-of-year Bighead Carp in the Great Lakes basin
  
————————————————————————————————————————————————————————

  Please give your desired output(s) and press enter.
  There are three options:

  1. data     -  retrieve & output climate projections
  
  2. results  -  run model & output simulation results
  
  3. both     -  performs each of the steps listed above



Your selection:
> "

# read user input from keyboard
read option extra

# if there's more than one argument provided, return error message
if [ -n "$extra" ]  
then
    printf "
                          .-.
                         (o.o)
                          |=|
                         __|__
                       //.=|=.\\\\\\
                      // .=|=. \\\\\\
                      \\\\\\ .=|=. //
                       \\\\\\(_=_)//
                        (:| |:)
                         || ||
                         () ()
                         || ||
                         || ||
                        ==' '==

  --  Too many arguments given. Please use just one.  --\n\n\n"

# for climate data outputs, source scripts 1 to 3
elif [ $option == data ] || [ $option = 1 ]
then
    getData

# to run the model, source scripts 4-8 
elif [ $option == results ] || [ $option = 2 ]
then
    getResults

# to do both parts if requested
elif [ $option == both ] || [ $option = 3 ]
then
    getData
    getResults

# if anything else is provided as an argument, return error message
else
    printf "
                              .''
                    ._.-.___.' (\`\\
                   //(        ( \`'
                  '/ )\ ).__. ) 
                  ' <' \`\ ._/\'\\
                     \`   \\     \\
    \n\n  --  Unrecognized argument given, please try again.  --\n\n\n"
fi
