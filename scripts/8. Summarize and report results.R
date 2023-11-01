#!/usr/bin/env Rscript

# 8. Summarize and report results.R
#    Copyright © 2023 Erik K Dean 
#    Licence: GNU GPLv3 - see LICENSE.txt for more details

# digging through the results data to make sense of it all
 
#———————————————————————————————————————————————————————————————————————————————

# ---- Loading saved results data ----------------------------------------------

# load necessary functions
library(reshape2)

# turns a data frame of results in long-format into a list of wide-format data
restoreList <- function(dataset){

    # empty list to be filled 
    dataList <- list()

    # for each tributary in the melted (long) dataset
    for( location in unique(dataset$tributary) ){

        # subset data for that location
        listItem <- subset(dataset, tributary == location, select = c(year, variable, value))

        # cast the data into wide format, and insert into the list
        dataList[[ location ]] <- dcast(listItem, year ~ variable)

    }

    # return the data in list format as output
    return(dataList)
}

# load data and reshape it back into list format
baseline <- restoreList(read.csv("data/baseline.csv"))
future <- restoreList(read.csv("data/future.csv"))

# ---- Analysis of results ----------------------------------------------------


