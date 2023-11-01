#!/usr/bin/env Rscript

# 5. Run model with climate data.R
#    Copyright © 2023 Erik K Dean 
#    Licence: GNU GPLv3 - see LICENSE.txt for more details

# Loading and processing temperature series data

#———————————————————————————————————————————————————————————————————————————————

# load the necessary functions to run analyses
source("./4. Young-of-year fish model functions.R") 

# prevent outputs from being in scientific notation
options(scipen = 100, digits = 4)


#---- 1. Run model on baseline data --------------------------------------------

# load historical water temperature data from Jones et al. 2017
g.temp <- read.csv("../data/gBaseline.csv")
n.temp <- read.csv("../data/nBaseline.csv")
s.temp <- read.csv("../data/sBaseline.csv")
v.temp <- read.csv("../data/vBaseline.csv")
 
# package all the baseline results together
baseline <- list(genesee    = get.results(g.temp),
                 nipigon    = get.results(n.temp),
                 stlouis    = get.results(s.temp),
                 vermillion = get.results(v.temp))

# data source: 
#   Jones, L.A., Drake, D.A.R., Mandrak, N.E., 
#   Jerde, C.L., Wittmann, M.E., Lodge, D.M., 
#   van der Lee, A.S., Johnson, T.B., and Koops, M.A.  2017. 
#   Modelling Survival and Establishment of Grass Carp, 
#   Ctenopharyngodon idella, in the Great Lakes Basin. 
#   DFO Can. Sci. Advis. Sec.  Res. Doc. 2016/101. vi + 52 p.

#---- 2. Run model on GCM data -------------------------------------------------

# There are 5 climate models in the ensemble,
# and each model was used to make daily temperature projections 
# for each of the 4 tributaries, totalling 20 temperature series.
# The data came grouped by model — containing 4 series per tributary,
# but needs to be grouped by tributary — containing the 5 GCM series.
# Then the model can be run 5 times per tributary 
# using each climate model's temperature series,
# and the ensemble of results can be averaged for reporting. 

# First, we'll need a couple functions to process this data

# convert GCM negative air temperatures to zero
zeroAir <- function(input){

    # make a working copy of the data set 
    tempSeries <- input

    # access each of the four GCMs in these columns (preceded by year & j.date)
    for (n in 3:6){

        # find negative values in a gcm-column
        negatives <- which(tempSeries[,n] <0)

        # convert those values to zero 
        tempSeries[negatives,n] <- 0

    }

    # output adjusted temperature series
    return(tempSeries)
}

# air-to-water conversion function, based on zeroed Thames River air temps
mod.temp2 <- function(x){ 
    y <- 0.8820862 * x + 3.201521
    return(y)
}

#——————————————————————————————————————————————————————————————————————————

# read data from each climate model 
 ec <- read.csv("../data/ecEarth3.csv")
had <- read.csv("../data/hadGEM3.csv")
inm <- read.csv("../data/inmCM5.csv")
mri <- read.csv("../data/mriESM2.csv")
uk  <- read.csv("../data/ukESM1.csv")

# convert negative air temperatures in all GCM datasets 
 ec <- zeroAir( ec)
had <- zeroAir(had)
inm <- zeroAir(inm)
mri <- zeroAir(mri)
uk  <- zeroAir(uk )

# convert all temps from air to water 
 ec[,c(3:6)] <-  ec[,c(3:6)] %>% mod.temp2
had[,c(3:6)] <- had[,c(3:6)] %>% mod.temp2
inm[,c(3:6)] <- inm[,c(3:6)] %>% mod.temp2
mri[,c(3:6)] <- mri[,c(3:6)] %>% mod.temp2
 uk[,c(3:6)] <-  uk[,c(3:6)] %>% mod.temp2

#——————————————————————————————————————————————————————————————————————————

# group the temperature projections from each model by tributary

# Vermillion
vermMods <- list( ec = data.frame(j.date = ec[,2],
                                    temp = ec[,3],
                                    year = ec[,1]),
                 had = data.frame(j.date = had[,2],
                                    temp = had[,3],
                                    year = had[,1]),
                 inm = data.frame(j.date = inm[,2],
                                    temp = inm[,3],
                                    year = inm[,1]),
                 mri = data.frame(j.date = mri[,2],
                                    temp = mri[,3],
                                    year = mri[,1]),
                  uk = data.frame(j.date = uk[,2],
                                    temp = uk[,3],
                                    year = uk[,1])
)

# St. Louis
slouMods <- list( ec = data.frame(j.date = ec[,2],
                                    temp = ec[,4],
                                    year = ec[,1]),
                 had = data.frame(j.date = had[,2],
                                    temp = had[,4],
                                    year = had[,1]),
                 inm = data.frame(j.date = inm[,2],
                                    temp = inm[,4],
                                    year = inm[,1]),
                 mri = data.frame(j.date = mri[,2],
                                    temp = mri[,4],
                                    year = mri[,1]),
                  uk = data.frame(j.date = uk[,2],
                                    temp = uk[,4],
                                    year = uk[,1])
)

# Genesee
genMods <- list( ec = data.frame(j.date = ec[,2],
                                   temp = ec[,5],
                                   year = ec[,1]),
                had = data.frame(j.date = had[,2],
                                   temp = had[,5],
                                   year = had[,1]),
                inm = data.frame(j.date = inm[,2],
                                   temp = inm[,5],
                                   year = inm[,1]),
                mri = data.frame(j.date = mri[,2],
                                   temp = mri[,5],
                                   year = mri[,1]),
                 uk = data.frame(j.date = uk[,2],
                                   temp = uk[,5],
                                   year = uk[,1])
)

# Nipigon
nipMods <- list( ec = data.frame(j.date = ec[,2],
                                   temp = ec[,6],
                                   year = ec[,1]),
                had = data.frame(j.date = had[,2],
                                   temp = had[,6],
                                   year = had[,1]),
                inm = data.frame(j.date = inm[,2],
                                   temp = inm[,6],
                                   year = inm[,1]),
                mri = data.frame(j.date = mri[,2],
                                   temp = mri[,6],
                                   year = mri[,1]),
                 uk = data.frame(j.date = uk[,2],
                                   temp = uk[,6],
                                   year = uk[,1])
)

#——————————————————————————————————————————————————————————————————————————

# get results for each model's temperature series in each tributary
vermSummary <- lapply(vermMods, get.results) 
genSummary  <- lapply( genMods, get.results) 
slouSummary <- lapply(slouMods, get.results) 
nipSummary  <- lapply( nipMods, get.results) 

#——————————————————————————————————————————————————————————————————————————

# function to average results between GCM outputs per tributary
mean.gcm <- function(tributary.data) {
                         
    # data frame to filled with averaged results
    output <- data.frame(year = 2015:2099)

    # loop across results from 2nd to 13th columns (1st is just year) 
    for (column in 2:13) {

        # take column from each gcm (list item) and average by year (row)
        output[column] <- lapply(tributary.data, function(gcm) {
                                          gcm[column] }) %>% 
                                          as.data.frame %>% 
                                          rowMeans(na.rm = T)
    }

    # apply labels for the outputted data frame 
    names(output) <- c("year", "num.growDays", "growPercent_year", 
                       "num.spawnDays", "spawnPercent_year", "spawnDaysRange1",
                       "spawnDaysRange2", "lastBday", "surviveNum", 
                       "percentSpawnSurvive", "theoryMin", "wintDay", "wintPer")

    # return the data frame of averaged results
    return(output)
}

# compute the average results for each tributary
 genAvg <- mean.gcm(genSummary) 
 nipAvg <- mean.gcm(nipSummary) 
slouAvg <- mean.gcm(slouSummary)
vermAvg <- mean.gcm(vermSummary)

# link the averaged results together 
future <- list(genesee    = genAvg,
               nipigon    = nipAvg, 
               stlouis    = slouAvg,
               vermillion = vermAvg)

#---- 3. Reshape data for export ----------------------------------------------

# load necessary functions 
library(reshape2)

# melt the results data into a long-format data frame for export
baselineOutput <- melt(baseline, id = "year", level = "tributary" ) 
futureOutput <- melt(future, id = "year", level = "tributary" ) 

# fix the levels column name
names(baselineOutput)[4] <- "tributary"
names(futureOutput)[4] <- "tributary"

# export both sets of results
write.csv(baselineOutput, "../data/baseline.csv", row.names = FALSE)
write.csv(futureOutput,   "../data/future.csv", row.names = FALSE)
