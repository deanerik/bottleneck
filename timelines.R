# THIS NEEDS CLEANIN UP
 
# timelines.R 
# Erik Dean 2023
# for plotting results and overarching trends as a timeline 

# ---- FOR THE SCHEMATIC -------------------------------------------------------

# Date focused data for timeline schematic diagram

# First spawn, last effective spawn, and last spawn for different places and time periods
baseline$nipigon[c("spawnDaysRange1", "lastBday", "spawnDaysRange2")] %>% colMeans(na.rm = T) %>% round(0)
# spawnDaysRange1        lastBday spawnDaysRange2 
#             228             NaN             246 

nipAvg[y2050s,c("spawnDaysRange1", "lastBday", "spawnDaysRange2")] %>% colMeans %>% round(0)
# spawnDaysRange1        lastBday spawnDaysRange2 
#             182             208             270 

nipAvg[y2100s,c("spawnDaysRange1", "lastBday", "spawnDaysRange2")] %>% colMeans %>% round(0)
# spawnDaysRange1        lastBday spawnDaysRange2 
#             160             240             288 


baseline$vermillion[c("spawnDaysRange1", "lastBday", "spawnDaysRange2")] %>% colMeans(na.rm = T) %>% round(0)
# spawnDaysRange1        lastBday spawnDaysRange2 
#             148             229             270 

vermAvg[y2050s,c("spawnDaysRange1", "lastBday", "spawnDaysRange2")] %>% colMeans %>% round(0)
# spawnDaysRange1        lastBday spawnDaysRange2 
#             144             258             312 

vermAvg[y2100s,c("spawnDaysRange1", "lastBday", "spawnDaysRange2")] %>% colMeans %>% round(0)
# spawnDaysRange1        lastBday spawnDaysRange2 
#             124             282             331 

# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

# Get the ordinal date when the GDD signal has been accrued
get.gdd <- function(tempArray){

    # copy for GDD calculations 
    gddArray <- tempArray

    # exclude the days below the base GDD temperature (zero them)
    gddArray[gddArray[,2] < baseTemp, 2]  <- 0

    # Get the first ordinal date where enough degree days have accrued
    gdd.day <- gddArray[(gddArray[,2] %>% cumsum >= degreeDays),1] %>% head(1)

    # return that 
    return(gdd.day)

}

# Example usage
get.gdd(vermMods[[1]][1:365,])

# applied use

modelSeries <- v.temp # nipMods[[5]]  n.temp  vermMods[[5]]
aYear <- 2099
get.gdd(modelSeries[which(modelSeries$year == aYear),])

# nip baseline
mean(c(263, 241, 230, 217, 229, 225, 230, 239, 244)) %>% round(0)
# [1] 235

# nip 2050
mean(c(168, 177, 169, 185, 155, 176, 173, 171, 171, 174, 174, 180, 183, 169, 162, 168, 181, 175, 177, 189, 197, 196, 208, 176, 187, 186, 180, 187, 188, 179, 175, 181, 173, 178, 191, 182, 186, 180, 174, 187, 190, 198, 184, 173, 191, 190, 193, 204, 189, 183)) %>% round(0)
# [1] 181

# nip 2100
mean(c(150, 126, 152, 143, 139, 145, 165, 143, 147, 150, 159, 159, 153, 170, 158, 174, 177, 165, 174, 164, 167, 170, 155, 158, 172, 169, 174, 180, 170, 175, 158, 164, 159, 157, 158, 148, 161, 153, 154, 159, 162, 154, 152, 169, 165, 157, 155, 158, 164, 169)) %>% round(0)
# [1] 160

# verm baseline
((159 + 155 + 141)/3) %>% round(0)
# [1] 152

# verm 2050
mean(c(126, 138, 142, 143, 129, 144, 143, 143, 137, 132, 133, 157, 139, 145, 124, 118, 144, 140, 147, 153, 150, 164, 153, 146, 146, 143, 137, 154, 142, 149, 137, 147, 147, 149, 150, 147, 147, 145, 122, 135, 147, 148, 135, 160, 153, 145, 139, 158, 147, 143)) %>% round(0)
# [1] 143

# verm 2100
mean(c(101, 109, 125, 123, 118, 108, 112, 117, 119, 141, 132, 135, 129, 142, 111, 133, 134, 129, 114, 130, 137, 131, 144, 121, 109, 121, 123, 130, 124, 135, 114, 116, 125, 113, 128, 117, 122, 112, 126, 110, 105, 110, 127, 141, 113, 127, 137, 123, 131, 137)) %>% round(0) 
# [1] 123





# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

# copy of get.Range that just gives the indices of winter start and end 
# from a pre-cut temp series (shoulder seasons plus winter)
 
get.winterDates <- function(tempArrayOG){

    # make a working copy
    tempArray <- tempArrayOG

    # find the index of the first cold day post equinox (Sept 23)
    startpoint <- (tempArray < winterTemp) %>% which %>% head(1) 
    # for the start of winter (which occurs at end of year)
    # guarding against cold spells making a false start of winter 

    # repeat until 5 days days following days also below the winter threshold
    # keep looping to find a correct stretch so long as all 5 are NOT winter temperatures 
    while( (tempArray < winterTemp)[startpoint:(startpoint+4)] %>% all != TRUE) {

        # if they aren't, get the five day range from the first cold day 
        range5 <- startpoint:(startpoint+4)

        # grab the last of the warm values
        checkpoint <- ((tempArray < winterTemp)[range5] != T) %>% which %>% tail(1)

        # then determine its position in the temp series
        # and the next cycle will check again starting from the next day 
        startpoint <- (range5)[checkpoint]+1

        # and if you hit the end of the series, finding nothing, then stop
        if(startpoint == length(tempArray)) break

    }

    # find the end of winter (which occurs at the start of the year)

    # get the index of the first warm day (crossing temperature threshold) 
    endpoint <- (startpoint-1) + (tempArray[startpoint:length(tempArray)] > winterTemp) %>% which %>% head(1)

    # if there's no start of winter, then log a negligble day
    if(identical(endpoint,numeric(0))){

        tempArray <- 0
        startpoint <- 1
        endpoint <- 2

    } else {

        # loop until all 5 days are above the winter threshold
        while( (tempArray > winterTemp)[endpoint:(endpoint+4)] %>% all != TRUE ) {

            # get the 5 day range
            range5 <- endpoint:(endpoint+4) 

            # grab the last of the cold values
            checkpoint <- ((tempArray > winterTemp)[range5] != T) %>% which %>% tail(1)

            # then determine its position in the temp series, and take the next spot
            endpoint <- (range5)[checkpoint]+1

        }
    }

    # the subtraction is necessary for this to work
    endpoint <- endpoint - 1

    # now with the true starting point of winter 
    # and the end (day before true start of growing) 
    # return the temperature series for the winter
    return(c(startpoint,endpoint))

}


get.winterDates(vermMods[[1]][130:565,2])

# start ordinal
130+161-1

# end ordinal (next year)
130+323-365

# From the indices, extract the actual ordinal dates
# ALWAYS put the index for the equivalent of the 200th ordinal date
get.winterOrdinal <- function(tempData, begin){

    # grab the start and end index for the data
    indices <- get.winterDates(tempData[begin:(begin+365),2])

    startDay <- 200 + indices[1] - 1

    endDay <- 200 + indices[2] - 365

    # return the ordinal dates for start of winter and end of winter (next year)
    return(c(startDay,endDay))

}

# application: find the cooresponding index for ordinal day 200 in a given year
# then find the start and end of winter for that segment of time
# which begins on day 200, and goes into the next year past winter
aYear <- 2015
modelSeries <- vermMods[[1]] # n.temp # v.temp 
get.winterOrdinal(modelSeries, which(modelSeries$year == aYear)[200])

# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

# nipigon baseline start end winter
mean(c(294, 295, 290, 296, 291, 288, 289, 296, 289)) 
# [1] 292
mean(c(174, 180, 160, 157, 164, 176, 162, 174, 168)) %>% round(0)
# [1] 168


# Nipigon by 2050 - average winter start and end
mean(c(301, 293, 299, 295, 292, 285, 279, 303, 287, 287, 282, 277, 282, 292, 284, 311, 300, 269, 281, 263, 308, 295, 298, 296, 284, 293, 298, 302, 284, 284, 285, 278, 278, 285, 279, 274, 286, 290, 289, 308, 296, 298, 309, 293, 294, 306, 299, 274, 312, 299) ) %>% round(0)
# [1] 291
mean(c(115, 133, 106, 123, 120, 112, 108, 106, 130, 135, 115, 130, 137, 108, 111, 136, 132, 115, 125, 121, 131, 124, 131, 130, 128, 108, 108, 128, 129, 99, 148, 126, 125, 114, 129, 109, 118, 103, 121, 108, 121) ) %>% round(0)
# [1] 121

# by 2100
mean(c(351, 324, 349, 322, 315, 332, 313, 312, 315, 348, 295, 300, 303, 309, 313, 292, 294, 311, 322, 317, 311, 298, 277, 293, 300, 313, 311, 271, 290, 276, 312, 325, 327, 314, 319, 308, 328, 309, 306, 316, 298, 312, 292, 321, 318, 309, 314, 320, 297, 309) ) %>% round(0)
# [1] 311
mean(c(3, 70, 89, 92, 100, 109, 113, 117, 132, 97, 113, 121, 107, 131, 113, 114, 112, 92, 94, 104, 125, 101, 110, 101, 115, 104, 111, 98, 116, 97, 95, 87, 85, 124, 100, 87, 113) ) %>% round(0)
# [1] 102


# Verm baseline winter start end
(310+302)/2
# [1] 306
(99+106)/2
# [1] 102.5

# Vermillion by 2050 - average winter start and end
# (dupe years tossed out)
mean(c(356, 343, 324, 340, 323, 345, 332, 326, 360, 337, 310, 331, 310, 302, 294, 298, 284, 336, 343, 301, 328, 317, 284, 304, 336, 313, 318, 295, 313, 311, 350, 328, 328, 349, 334, 314, 333, 327, 303, 316, 316, 320, 331, 310, 314, 325, 305, 327, 302, 310) ) %>% round(0)
# [1] 321
mean(c(77, 85, 74, 95, 102, 86, 90, 104, 62, 85, 33, 34, 106, 26, 66, 119, 39, 86, 107, 94, 86, 49, 92, 85, 90, 86, 61, 100, 75, 105) ) %>% round(0)
# [1] 80

# Vermillion by 2100
mean(c(394, 371, 374, 388, 355, 368, 361, 364, 389, 361, 314, 321, 331, 311, 325, 311, 337, 339, 329, 332, 330, 337, 314, 330, 337, 322, 343, 344, 301, 312, 357, 330, 341, 384, 334, 336, 346, 353, 337, 362, 329, 356, 348, 330, 355, 334, 350, 338, 334, 337) ) %>% round(0)
# [1] 343
mean(c(64, 41, 41, 79, 13, 61, 5, 56, 54, 79, 25, 43, 80, 11, 68, 4, 75, 21, 87, 1, 71, 71, 6, 22, 51, 1, 57, 44) ) %>% round(0)
# [1] 44

# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —

# FINAL DATA FOR SCHEMATIC PLOT 

# Verdict: the GDD is accrued by the time temperatures are suitable for spawning anyways
# so first spawn pretty much falls on the same day. No need to plot it.

# Nipigon
# Baseline

# spawnDaysRange1        lastBday spawnDaysRange2 
#             228             NaN             246 
winter 292 to 168 gdd 235

# 2050

# spawnDaysRange1        lastBday spawnDaysRange2 
#             182             208             270 
winter 291 to 121 gdd 181

# 2100

# spawnDaysRange1        lastBday spawnDaysRange2 
#             160             240             288 
winter 311 to 102 gdd 160

# Vermillion

# baseline
# spawnDaysRange1        lastBday spawnDaysRange2 
#             148             229             270 
winter 306 to 103 gdd 152

# 2050
# spawnDaysRange1        lastBday spawnDaysRange2 
#             144             258             312 
winter 321 to 80 gdd 143

# 2100
# spawnDaysRange1        lastBday spawnDaysRange2 
#             124             282             331 
winter 343 to 44 gdd 123

# ---- Making the timeline plot ------------------------------------------------

library(viridis)

# for month axis to go at bottom of plot
month <- data.frame(name = month.abb[c(1:12,1:7)],
                    ordinal = c(1, 32, 60, 91, 121, 152, 
                                182, 213, 244, 274, 305, 
                                335, 366, 365+32, 365+60,
                                365+91, 365+121, 365+152, 365+182)
)

# put the extracted time points together for plotting
timeDat <- data.frame(
                      period    = c("0", "-1", "-2", "0", "-1", "-2"),
                      location  = c("nipigon", "nipigon", "nipigon", "vermillion", "vermillion", "vermillion"),
                      spawn1    = c(228, 182, 160, 148, 144, 124),
                      les       = c(NA, 208, 240, 229, 258, 282),
                      spawn2    = c(246, 270, 288, 270, 312, 331),
                      winter1   = c(292, 291, 311, 306, 321, 343),
                      winter2   = c(168+365, 160+365, 102+365, 103+365, 80+365, 44+365)
                      #o.winter2 = c(168, 160, 102, 103, 80, 44)
)


# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
# for first year life history line 

# for this instance (genesee 2016 model 5)
# GDD is fully accrued before spawning temps are reached
# and not every day in the spawning period is suitable

modelSeries <- genMods[[5]] # n.temp #   v.temp vermMods[[5]]
aYear <- 2016
get.spawning(modelSeries[which(modelSeries$year == aYear),])

# gdd ordinal date achieved
get.gdd(modelSeries[which(modelSeries$year == aYear),])
# [1] 144

# winter start and end ordinal
get.winterOrdinal(modelSeries[366:1096,], 200)
# [1] 334 104

# make a copy to get the gradient of GDD progress
gddArray <- (modelSeries[which(modelSeries$year == aYear),])

# zero out the temperatures below base
gddArray[gddArray[,2] < baseTemp, 2]  <- 0

# save the final GDD gradient, ending on the date of accrual
gddArray <- (gddArray[,2] %>% cumsum)[1:144]

# for plotting
gddArray <- data.frame(ordinal = 1:(gddArray %>% length), gdd = gddArray)

# tack on the rest of the time sereis as unchanged, for plotting
gddArray <- rbind(gddArray, data.frame(ordinal = 145:469, gdd = 639))

# — — — — — — — — — — — — — — — —
# alternatively: plot the temp series itself

library(scales)

# the temp series matching the right dates
gddArray <- modelSeries[366:(366+365+104),1:2]

# reset the index / row numbers
row.names(gddArray) <- NULL

# make the ordinals part of a continuous day count up
gddArray[366:470,1] <- gddArray[366:470,1] + 365

# fix column names
names(gddArray) <- c("ordinal", "temp")

# — — — — — — — — — — — — — — 
# alternative: use baseline data cause GCM data is too variable (looks bad)
# using genesee 2011 again 

dat <- s.temp
dat2 <- baseline[[3]]
gdd.dates <- get.winterOrdinal(dat, 200)


gddArray <- dat[1:(365+gdd.dates[2]+5),1:2]
names(gddArray)[1] <- "ordinal"
gddArray[,1] <- 1:(365+gdd.dates[2]+5)

# make a copy
gdd.col <- gddArray

# zero out the temperatures below base
gdd.col[gdd.col[,2] < baseTemp, 2]  <- 0

# save the final GDD gradient, ending on the date of accrual
gdd.col <- (gdd.col[,2] %>% cumsum)[1:get.gdd(gddArray)]

# for plotting
gdd.col <- data.frame(ordinal = 1:(gdd.col %>% length), gdd = gdd.col)

# tack on the rest of the time series as unchanged, for plotting
gdd.col <- rbind(gdd.col, data.frame(ordinal = 1+length(gdd.col[,1]):(364+gdd.dates[2]+5),
                                     gdd = gdd.col[length(gdd.col[,1]),2]))

# combine the temp series with the gdd calculation
gddArray <- cbind(gddArray, gdd = gdd.col[,2])

# important dates
get.spawning(gddArray[,1:2])[1]
get.spawning(gddArray[,1:2]) %>% tail(1)

get.gdd(gddArray)

# winter dates
gdd.dates


# — — — — — — — — — — — — — — — —
# temp series with annotations later
# this is st louis baseline 2012
library(ggridges)

# force steady increase in GDD to see if it'll fix color gradient problem
gddArray[133:175,3] <- seq(15, 640, length.out = 43)
plot(gddArray$gdd ~ gddArray$ordinal) # check that

# fixing the gdd values to have stable colours in rest of year 
gddArray[176:504,3] <- 650

plot(gddArray$gdd ~ gddArray$ordinal)

fig1a <- ggplot(gddArray, aes(x = ordinal, height = temp, y = 0, fill = gdd)) + # color = gdd OR temp
    geom_ridgeline_gradient(gradient_lwd = 1, size = 0) +
    #ggplot(gddArray, aes(x = ordinal, y = temp,  color = gdd)) + # for non-ridgelines 
    #scale_color_gradient(high = "#D25471", low = "#171387") +
    scale_fill_gradient(high = "#D25471", low = "#171387", 
                        limits=c(0,640), oob = scales::squish,
                        name = "Degree days",
                        labels = c(0,200,400,633)) +
    #geom_line() +
    #geom_col(width = 1) + # tried this before but export had white line artifacts
    theme_classic() +
    theme(axis.line.y=element_blank(),
          axis.text.y=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.x =element_blank(),
          axis.ticks.x =element_blank(),
          axis.line.x =element_blank(),
          plot.margin = unit(c(0, -0.90, 0, -0.95), "cm"),
          legend.direction = "horizontal",
          legend.key.height = unit(0.2, 'cm'), #change legend key height
          legend.title = element_text(size=9), #change legend title font size
          legend.key.width = unit(0.6, 'cm'), 
          legend.background=element_blank(),
          legend.position = c(.11,.26)
          ) +
    guides(fill = guide_colorbar(title.position = "top")) +
    #ylim(0,150) +
    geom_segment(aes(x=0, xend=get.gdd(gddArray), y=15, yend=15), size = 0.3, linetype = "dashed", color = "white") +
    geom_segment(aes(x=get.spawning(gddArray)[1], xend=gdd.dates[1], y=18, yend=18), size = 0.3, linetype = "dashed", color = "white") +
    geom_segment(aes(x=(gdd.dates[1]-1), xend=gdd.dates[2]+370, y=10, yend=10), size = 0.3, linetype = "dashed", color = "black") +
    geom_segment(aes(x=get.spawning(gddArray)[1], xend=168, y=19, yend=24), size = 0.3, color = "gray50") +
    geom_segment(aes(x=133, xend=103, y=16, yend=23), size = 0.3, color = "gray50") +
    geom_segment(aes(x=168, xend=140, y=24, yend=28), size = 0.3, color = "gray50") +
    geom_segment(aes(x=175.5, xend=174, y=19, yend=24), size = 0.3, color = "gray50") +
    geom_segment(aes(x=174, xend=160, y=24, yend=30), size = 0.3, color = "gray50") +
    geom_segment(aes(x=176, xend=179, y=19.5, yend=33), size = 0.3, color = "gray50") +
    #geom_segment(aes(x=179, xend=199, y=26, yend=32), size = 0.3, color = "gray50") +
    geom_segment(aes(x=278, xend=280, y=11, yend=21), size = 0.3, color = "gray50") +
    #geom_segment(aes(x=278, xend=264, y=15, yend=30), size = 0.3, color = "gray50") +
    geom_segment(aes(x=440, xend=444, y=19, yend=15), size = 0.3, color = "gray50") +
    geom_segment(aes(x=497, xend=444, y=11, yend=15), size = 0.3, color = "gray50") +
    geom_text(label="15°C", aes(x=150, y=10), size = 3, color = "white") +
    geom_text(label="18°C", aes(x=215, y=14), size = 3, color = "white") +
    geom_text(label="10°C", aes(x=390, y=6), size = 3, color = "black") +
    geom_text(label="Maturation", aes(x=84, y=24), size = 3, color = "black") +
    geom_text(label="Spawning", aes(x=122, y=28), size = 3, color = "black") +
    geom_text(label="Larval drift", aes(x=152, y=33), size = 3, color = "black") +
    geom_text(label="Hatch, growth begins", aes(x=207, y=36), size = 3, color = "black") +
    geom_text(label="Growth ends, winter begins", aes(x=305, y=24), size = 3, color = "black") +
    geom_text(label="Winter ends, growth resumes", aes(x=450, y=23), size = 3, color = "black")

    #geom_vline(xintercept=get.spawning(gddArray)[1], color = "black", linetype = "solid", size=0.7) 
    #geom_vline(xintercept=gdd.dates[1], color = "white", linetype = "dotted", size=0.7) +
    #geom_vline(xintercept=dat2[1,"lastBday"], color = "white", linetype = "dotted", size=0.7)
    #geom_vline(xintercept=gdd.dates[2]+365, color = "white", linetype = "dotted", size=0.7) +
    #geom_vline(xintercept=get.spawning(gddArray[,1:2]) %>% tail(1), color = "white", linetype = "dotted", size=0.7) +


ggsave(plot = fig1a, filename = "lifehist.png", path = "../ch2graphics", bg = "white", width = 6, height = 3, dpi = 600)
     
# consider this for fixing the color gradient issue





# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
# for OVERARCHING with management suggestions  



# Genesee 2011 as the example

# spawning days

library(reshape2)

timeDat.o <- data.frame(
                        period    = "0",
                        spawn1    = baseline[[1]][1, 6],
                        les       = baseline[[1]][1, 8],
                        spawn2    = baseline[[1]][1, 7],
                        winter1   = get.winterOrdinal(g.temp, 200)[1],
                        winter2   = get.winterOrdinal(g.temp, 200)[2]+365
) %>% melt

# add label (for the winter start ordinal date in the next year)
timeDat.o <- cbind(timeDat.o, label = c(173, 232, 271, 299, 76))

# !! below not actually needed because they seem to spawn every day within the period
# even if it's theoretically possible that they wouldn't, due to temp flux
#
# add on individual spawning days
#timeDat.o <- rbind(timeDat.o, data.frame(period = 0,
#                                         variable = "spawnDay",
#                                         value = get.spawning(g.temp[1:365,]),
#                                         label = NA
#                                         )
#)

top.time <- ggplot(timeDat.o,aes(x=value,y=as.numeric(period), col=variable, label=label)) +
    ylim(-0.20,2) + 
    xlim(-30,608) + 
    theme_classic() +
    theme(axis.line.y=element_blank(),
                 axis.text.y=element_blank(),
                 axis.title.x=element_blank(),
                 axis.title.y=element_blank(),
                 axis.ticks.y=element_blank(),
                 axis.text.x =element_blank(),
                 axis.ticks.x =element_blank(),
                 axis.line.x =element_blank(),
                 legend.title = element_blank(),
                 legend.key.height = unit(0.4, 'cm'), #change legend key height
                 legend.key.width = unit(1, 'cm'),
                 legend.text = element_text(size=8), #change legend text font size
#                 legend.position = "none",
                 plot.margin = unit(c(0, 0, 0, 0), "cm"),
                 legend.position = c(.90,.88),
                 #legend.direction = "horizontal"
                ) +
    geom_hline(yintercept=0, color = "gray50", linetype = "dotted", size=0.4) + 
    geom_segment(aes(x=173,xend=271,y=0, yend=0), color = "#D25471") +
    geom_segment(aes(x=299,xend=441,y=0, yend=0), color = "#171387") +
    #geom_vline(aes(xintercept=365), linetype="dashed", size=0.75) +
    #geom_vline(aes(xintercept=152), linetype="dashed", size=0.75) +
    geom_point(aes(shape = variable), size=3) +
    scale_shape_manual(values=c("spawn1" = 20, "les" = 4, "spawn2" = 20,
                                "winter1" = 18, "winter2" = 18),
                       breaks = c("spawn1", "les", "winter1"),
                       labels=c("Spawning Period", "Last Effective Spawn", "Winter Period")) +
    scale_color_manual(values=c("spawn1" = "#D25471","les" = "#FAA543",
                                "spawn2" = "#D25471", "winter1" = "#171387",
                                "winter2" = "#171387"),
                       breaks = c("spawn1", "les", "winter1"),
                       labels=c("Spawning Period", "Last Effective Spawn", "Winter Period") ) +
    geom_text(aes(label = label, vjust=-0.95), size = 3, show_guide = F) +
    geom_text(data=month, aes(x=ordinal,y=-0.18,label=name),
              size=3, angle=90, color='black') +
    geom_segment(aes(x=-15, xend=90,y=1.5, yend=0.05), color = "gray50", size = 0.4) +
    geom_segment(aes(x=-15, xend=-15,y=1.5, yend=1.65), color = "gray50", size = 0.4) +
    geom_segment(aes(x=146, xend=166,y=0.12, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=80, xend=146,y=1, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=204, xend=224,y=0.12, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=160, xend=204,y=0.75, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=253, xend=263,y=0.12, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=230, xend=253,y=0.5, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=308, xend=323,y=0.12, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=323, xend=370,y=0.12, yend=0.75), color = "gray50", size = 0.4) +
    geom_segment(aes(x=447, xend=457,y=0.12, yend=0.12), color = "gray50", size = 0.4) +
    geom_segment(aes(x=457, xend=520,y=0.12, yend=1), color = "gray50", size = 0.4) +
    geom_text(aes(x=-30,y=1.9,label="Pre-spawning period:\nMonitor for aggregations"),
              color='black', hjust = 0, size = 3.5, family = "serif") +
    geom_text(aes(x=40,y=1.5,label="Spawning begins:\nTarget aggregating adults, and youngest life stages"),
              color='black', hjust = 0, size = 3.5, family = "serif") +
    geom_text(aes(x=122,y=1,label="Last effective spawn:\nNot necessary to prevent further spawning"),
              color='black', hjust = 0, size = 3.5, family = "serif") +
    geom_text(aes(x=202,y=0.6,label="Spawning ends: target largest YOY"),
              color='black', hjust = 0, size = 3.5, family = "serif") +
    geom_text(aes(x=355,y=1,label="Winter begins:\nTarget adults"),
              color='black', hjust = 0, size = 3.5, family = "serif") +
    geom_text(aes(x=460,y=1.2,label="Winter ends:\nTarget surviving young-of-year"),
              color='black', hjust = 0, size = 3.5, family = "serif")
                        
    
ggsave(plot = top.time, filename = "test.png", path = "../ch2graphics", bg = "white", width = 9, height = 3)


# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
# for NIPIGON
# reformatting for plotting, one place & period at a time
timeDat.n <- timeDat[1:3,] %>% melt
# add column for the ordinal date labels (for following year's winter end)
timeDat.n <- cbind(timeDat.n,
                 label = c(228, 182, 160, NA, 208, 240, 246, 270, 288, 292, 291, 311, 168, 160, 102))
# plot position adjustment column
timeDat.n <- cbind(timeDat.n,
                 adjust = c(1,1,1,
                            -0.2,0.2,0.8,
                            0.2,0.8,0.8,
                            -0.1,-0.1,-0.1,
                            0.4,0.4,0.4
                            ))
# !! NOTICE
# there are years where spawning doesn't happen at all
# 4 out of 9 years in nipigon baseline don't spawn
nip.time <- ggplot(timeDat.n,aes(x=value,y=as.numeric(period), col=variable, label=label)) +
    ylim(-3,1) + 
    theme_classic() +
    theme(axis.line.y=element_blank(),
                 axis.text.y=element_blank(),
                 axis.title.x=element_blank(),
                 axis.title.y=element_blank(),
                 axis.ticks.y=element_blank(),
                 axis.text.x =element_blank(),
                 axis.ticks.x =element_blank(),
                 axis.line.x =element_blank(),
                 legend.position = "none",
                 plot.margin = unit(c(0, 0.1, 0, 0), "cm")
                ) +
    geom_hline(yintercept=0, color = "gray50", linetype = "dotted", size=0.4) + 
    geom_hline(yintercept=-1, color = "gray50", linetype = "dotted", size=0.4) + 
    geom_hline(yintercept=-2, color = "gray50", linetype = "dotted", size=0.4) + 
    geom_segment(aes(x=228,xend=246,y=0, yend=0), color = "#D25471") +
    geom_segment(aes(x=182,xend=270,y=-1, yend=-1), color = "#D25471") +
    geom_segment(aes(x=160,xend=288,y=-2, yend=-2), color = "#D25471") +
    geom_segment(aes(x=292,xend=533,y=0, yend=0), color = "#171387") +
    geom_segment(aes(x=291,xend=525,y=-1, yend=-1), color = "#171387") +
    geom_segment(aes(x=311,xend=467,y=-2, yend=-2), color = "#171387") +
    geom_point(aes(shape = variable), size=3) +
    scale_shape_manual(values=c(20,4,20,18,18)) +
    scale_color_manual(values=c("#D25471","#FAA543","#D25471","#171387","#171387")) +
    #geom_vline(aes(xintercept=1), linetype="dashed", size=0.75) +
    #geom_vline(aes(xintercept=365), linetype="dashed", size=0.75) +
    geom_text(aes(label = label, hjust = adjust, vjust=-0.95), size = 3) +
    geom_text(data=month, aes(x=ordinal,y=-2.2,label=name),
              size=3, hjust=1, color='black', angle=90) +
     geom_text(aes(x=-2,y=0, hjust=0, vjust=-0.56, label = "Baseline"), color = "gray50", size = 3) +
     geom_text(aes(x=-2,y=-1, hjust=0, vjust=-0.5, label = "2050"), color = "gray50", size = 3) +
     geom_text(aes(x=-2,y=-2, hjust=0, vjust=-0.5, label = "2100"), color = "gray50", size = 3) 
    
    
# repeat for vermillion    
    
# reformatting for plotting, one place & period at a time
timeDat.v <- timeDat[4:6,] %>% melt
# add column for the ordinal date labels (for following year's winter end)
timeDat.v <- cbind(timeDat.v,
                 label = c(148, 144, 124, 229, 258, 282, 270, 312, 331, 306, 321, 343, 468-365, 445-365, 409-365))
# plot position adjustment column
timeDat.v <- cbind(timeDat.v,
                 adjust = c(0.4,0.4,0.4,
                            1, 1, 1,
                            0.7,1,1,
                            -0.1,-0.1,-0.1,
                            0.4,0.4,0.4
                            ))
# !! NOTICE
# there are years where spawning doesn't happen at all
# 4 out of 9 years in nipigon baseline don't spawn
verm.time <- ggplot(timeDat.v,aes(x=value,y=as.numeric(period), col=variable, label=label)) +
    ylim(-3,1) + 
    theme_classic() +
    theme(axis.line.y=element_blank(),
                 axis.text.y=element_blank(),
                 axis.title.x=element_blank(),
                 axis.title.y=element_blank(),
                 axis.ticks.y=element_blank(),
                 axis.text.x =element_blank(),
                 axis.ticks.x =element_blank(),
                 axis.line.x =element_blank(),
                 legend.position = "none",
                 plot.margin = unit(c(0, 0, 0, 0.1), "cm")
                ) +
    geom_hline(yintercept=0, color = "gray50", linetype = "dotted", size=0.4) + 
    geom_hline(yintercept=-1, color = "gray50", linetype = "dotted", size=0.4) + 
    geom_hline(yintercept=-2, color = "gray50", linetype = "dotted", size=0.4) + 
    geom_segment(aes(x=148,xend=270,y=0, yend=0), color = "#D25471") +
    geom_segment(aes(x=144,xend=312,y=-1, yend=-1), color = "#D25471") +
    geom_segment(aes(x=124,xend=331,y=-2, yend=-2), color = "#D25471") +
    geom_segment(aes(x=306,xend=468,y=0, yend=0), color = "#171387") +
    geom_segment(aes(x=321,xend=445,y=-1, yend=-1), color = "#171387") +
    geom_segment(aes(x=343,xend=409,y=-2, yend=-2), color = "#171387") +
    geom_point(aes(shape = variable), size=3) +
    scale_shape_manual(values=c(20,4,20,18,18)) +
    scale_color_manual(values=c("#D25471","#FAA543","#D25471","#171387","#171387")) +
    #geom_vline(aes(xintercept=1), linetype="dashed", size=0.75) +
    #geom_vline(aes(xintercept=365), linetype="dashed", size=0.75) +
    geom_text(aes(label = label, hjust = adjust, vjust=-0.95), size = 3) +
    #geom_text(aes(x=1,y=0, hjust=0, vjust=-0.5, label = "Baseline"), color = "black", size = 5) +
    #geom_text(aes(x=1,y=-5, hjust=0, vjust=-0.5, label = "2050"), color = "black", size = 5) +
    #geom_text(aes(x=1,y=-10, hjust=0, vjust=-0.5, label = "2100"), color = "black", size = 5) +
    geom_text(data=month, aes(x=ordinal,y=-2.2,label=name),
              size=3, hjust=1, color='black', angle=90) 
    
    
# — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — — —
# export


both.time <- plot_grid(nip.time, verm.time,
                       labels = c("Nipigon","Vermillion"),
                       label_size = 11,
                       label_fontface = "bold",
                       label_x = - -0.70, 
                       label_y = 1, 
                       align="h", 
                       ncol = 2)


all.time <- plot_grid(fig1a,
                      both.time,
                      top.time,
                      labels = c('a', 'b', 'c'),
                      ncol = 1,
                      rel_heights = c(0.25,0.35,0.4)
)

# save plot
ggsave(plot = all.time, filename = "timelines.png", path = "../ch2graphics", bg = "white", width = 9, height = 5)




# as EPS
library("cairo")
ggsave(plot = all.time, filename = "timelines.eps", path = "../ch2graphics", device = cairo_ps, bg = "white", width = 9, height = 6, fallback_resolution = 600)


