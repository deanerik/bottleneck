Overview
================================================================================

This is a repository of the code and data used in one of my research projects
that explores the first year of life for an invasive fish species, and whether
changing environmental conditions across time and space may enable better
performance (reproduction, growth, and survival) for them in four locations
within the Great Lakes basin. 

The purpose of this research is to explore the consequences of changing seasonal
temperatures on the onset and duration of spawning, growth, and overwinter
starvation, and whether young-of-year (age-0) Bighead Carp will be able to
endure winter conditions in the future. 

Environmental temperatures affect the rates at which fish grow, develop into
spawning condition, and consume stored energy. Thus, daily temperature trends
coming out of winter dictate when adult fish will begin reproducing and,
subsequently, determine how much spawned offspring will be able grow before
the start of winter. 

Colder environmental conditions at northern latitudes have been
theorized to limit the reproduction, growth, and body sizes of age-0 fish.
By restricting fish from attaining sufficiently large body sizes,
low temperatures can prevent overwinter survival, 
thereby imposing a population bottleneck.

Anticipated warming under climate change, however, may enable young-of-year fish
to attain larger sizes and store greater amounts of energy. With greater amounts
of stored energy, young-of-year fish will be able to endure longer periods of
overwinter starvation. Over time, Bighead Carp may be released from this
potential bottleneck at northern latitudes, which has implications for their
potential invasion.


Process
--------------------------------------------------------------------------------

*See [erikdean.ca/bottleneck](https://erikdean.ca/bottleneck/) for schematic of process*


0. Check that you have all scripts listed below in the current working
   directory, and a `/data` subdirectory with the 4 baseline data sets.

1. Run shell script `acquireData.sh` to download GCM data from NASA.

2. Run `accessData.R` to read, format, and output GCM data for analysis.

3. `convert.R`

4. Run `seriesRun.R`, which loads the core functions in `utilities.R`, 
   to run the model. Annual results are averaged and reshaped before export.

5. Run `plotting.R` to plot results, which also calls `timelines.R` to plot 
   a complicated timeline plot. This script first calls `seriesRun.R` and 
   runs the entire model to use the entire range of raw data for plotting.

6. Run `summarize.R` for analysis of all the averaged annual results.

7. ??? 

8. Profit!


To do list
--------------------------------------------------------------------------------

- [ ] add a process step for air to water temperature model `convert.R`

- [ ] The `timelines.R` code for timeline plot needs to be cleaned up

- [ ] The remaining content of old model file to be extracted into `summarize.R`


