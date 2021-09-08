##############################################################################################
# This script is meant to produce forest change maps using the forest change map output from ##
### the 'forest change mask' module in sepal. The output from that module is a combination##### 
######  of the GFC dataset including treecover2000, loss from 2001-2020 and gain 2012.#########

#### Outputs of this script
# Forest cover 2000
# forest change 2000-2005
# forest change 2000-2010
# forest change 2000-2015
# forest change 2000-2020

#### For questions contact Teopista, on teopista.nakalema@fao.org or teonakalema@gmail.com

## load libraries
library(rgdal)
library(raster)
library(gdalUtils)

## Read Hansen change map for Kafue created using the forest change mask module (treecover percentage of 10% was used to produce the map)
change_map <- paste0('/home/nakalema/Resilient_rivers/Forest_change_Kafue/merged_gfc_map.tif')
##gdalinfo(Kafue)

# Create output folder
output_maps <- paste0('/home/nakalema/Resilient_rivers/output_maps')
dir.create(output_maps)

# Define minimum mapping unit for seiving the output files (Zambia's forest definition 0.5ha forest area)
mmu <- 5

#define output files
f2000 <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_cover2000.tif')
f2000.sieved <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_cover2000_sieve.tif') 
fchange00_05 <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2005.tif')
fchange00_05.sieved <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2005_sieve.tif')
fchange00_10 <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2010.tif')
fchange00_10.sieved <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2010_sieve.tif')
fchange00_15 <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2015.tif')
fchange00_15.sieved <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2015_sieve.tif')
fchange00_20 <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2020.tif')
fchange00_20.sieved <- paste0('/home/nakalema/Resilient_rivers/output_maps/forest_change2000_2020_sieve.tif') 

# Classes in the change map
#code	pixels	class	area
#1	135238	loss_2001	11740.11195
#2	144256	loss_2002	12522.97128
#3	181547	loss_2003	15760.23089
#4	42821	  loss_2004	3717.323045
#5	231556	loss_2005	20101.54959
#6	133466	loss_2006	11586.28331
#7	55488	  loss_2007	4816.954791
#8	151544	loss_2008	13155.64801
#9	311568	loss_2009	27047.45117
#10	718850	loss_2010	62403.90628
#11	249435	loss_2011	21653.63896
#12	721402	loss_2012	62625.44731
#13	346912	loss_2013	30115.69025
#14	612695	loss_2014	53188.51132
#15	429948	loss_2015	37324.10753
#16	646420	loss_2016	56116.2038
#17	750714	loss_2017	65170.04396
#18	688154	loss_2018	59739.16356
#19	539796	loss_2019	46860.09459
#20	770322	loss_2020	66872.22911
#30	8896823	non forest	772339.8605
#40	103452720	forest	8980808.018
#50	67705	gains	5877.521701
#51	13566	gain+loss	1177.674609


#######################################################################################################
#################### CREATE A FOREST COVER MAP FOR THE YEAR 2000 ######################################

#1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 40 = 1 - forest
#30 50 51 = 2 - non-forest

system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               change_map,
               f2000,
               paste0("(A==0)* 0+",
                      "(A>0) * (A<20) *1+",
                      "(A==20) *1+",
                      "(A==40) *1+",
                      "(A==30) *2+",
                      "(A==50) *2+",
                      "(A==51) *2"
                      )
))

#plot(raster(f2000))

################### SIEVE AND COMPRESS 
if(!file.exists(f2000.sieved)){
  system(sprintf("gdal_sieve.py -st %s %s %s ",
                 mmu,
                 f2000,
                 paste0(output_maps, 'tmp_forest_cover2000_sieve.tif')
  ))
  
  # COMPRESS
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(output_maps, 'tmp_forest_cover2000_sieve.tif'),
                 f2000.sieved
  ))
  
  # REMOVE UNCOMPRESSED FILE
  system(sprintf("rm %s ",
                 paste0(output_maps, 'tmp_forest_cover2000_sieve.tif')
  ))
}


#######################################################################################################
#################### CREATE A FOREST CHANGE MAP FOR 2000-2005 #########################################

#6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 40 = 1- stable forest
#30 50 51 = 2 - stable non-forest
#1 2 3 4 5 = 3 - Deforestation

system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               change_map,
               fchange00_05,
               paste0("(A==0)* 0+",
                      "(A>5) * (A<20) *1+",
                      "(A==20) *1+",
                      "(A==40) *1+",
                      "(A==30) *2+",
                      "(A==50) *2+",
                      "(A==51) *2+",
                      "(A>0) * (A<6) *3"
               )
))


################### SIEVE TO THE MMU
if(!file.exists(fchange00_05.sieved)){
  system(sprintf("gdal_sieve.py -st %s %s %s ",
                 mmu,
                 fchange00_05,
                 paste0(output_maps, 'tmp_forest_change2000_2005_sieve.tif')
  ))
  
  # COMPRESS
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(output_maps, 'tmp_forest_change2000_2005_sieve.tif'),
                 fchange00_05.sieved
  ))
  
  # REMOVE UNCOMPRESSED FILE
  system(sprintf("rm %s ",
                 paste0(output_maps, 'tmp_forest_change2000_2005_sieve.tif')
  ))
}


#######################################################################################################
#################### CREATE A FOREST CHANGE MAP FOR 2000-2010 #########################################

#11 12 13 14 15 16 17 18 19 20 40 = 1- stable forest
#30 50 51 = 2 - stable non-forest
#1 2 3 4 5 6 7 8 9 10 = 3 - Deforestation

system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               change_map,
               fchange00_10,
               paste0("(A==0)* 0+",
                      "(A>10) * (A<20) *1+",
                      "(A==20) *1+",
                      "(A==40) *1+",
                      "(A==30) *2+",
                      "(A==50) *2+",
                      "(A==51) *2+",
                      "(A>0) * (A<11) *3"
               )
))


################### SIEVE TO THE MMU
if(!file.exists(fchange00_10.sieved)){
  system(sprintf("gdal_sieve.py -st %s %s %s ",
                 mmu,
                 fchange00_10,
                 paste0(output_maps, 'tmp_forest_change2000_2010_sieve.tif')
  ))
  
  # COMPRESS
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(output_maps, 'tmp_forest_change2000_2010_sieve.tif'),
                 fchange00_10.sieved
  ))
  
  # REMOVE UNCOMPRESSED FILE
  system(sprintf("rm %s ",
                 paste0(output_maps, 'tmp_forest_change2000_2010_sieve.tif')
  ))
}

#######################################################################################################
#################### CREATE A FOREST CHANGE MAP FOR 2000-2015 #########################################

#16 17 18 19 20 40 50= 1- stable forest
#30 51 = 2 - stable non-forest
#1 2 3 4 5 6 7 8 9 10 11 12 13 14 15= 3 - Deforestation

system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               change_map,
               fchange00_15,
               paste0("(A==0)* 0+",
                      "(A>15) * (A<20) *1+",
                      "(A==20) *1+",
                      "(A==40) *1+",
                      "(A==50) *1+",
                      "(A==30) *2+",
                      "(A==51) *2+",
                      "(A>0) * (A<16) *3"
               )
))


################### SIEVE TO THE MMU
if(!file.exists(fchange00_15.sieved)){
  system(sprintf("gdal_sieve.py -st %s %s %s ",
                 mmu,
                 fchange00_15,
                 paste0(output_maps, 'tmp_forest_change2000_2015_sieve.tif')
  ))
  
  # COMPRESS
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(output_maps, 'tmp_forest_change2000_2015_sieve.tif'),
                 fchange00_15.sieved
  ))
  
  # REMOVE UNCOMPRESSED FILE
  system(sprintf("rm %s ",
                 paste0(output_maps, 'tmp_forest_change2000_2015_sieve.tif')
  ))
}


#######################################################################################################
#################### CREATE A FOREST CHANGE MAP FOR 2000-2020 #########################################

#40 50= 1- stable forest
#30 51 = 2 - stable non-forest
#1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 = 3 - Deforestation

system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               change_map,
               fchange00_20,
               paste0("(A==0)* 0+",
                      "(A==40) *1+",
                      "(A==50) *1+",
                      "(A==30) *2+",
                      "(A==51) *2+",
                      "(A==20) *3+",
                      "(A>0) * (A<20) *3"
               )
))


################### SIEVE TO THE MMU
if(!file.exists(fchange00_20.sieved)){
  system(sprintf("gdal_sieve.py -st %s %s %s ",
                 mmu,
                 fchange00_20,
                 paste0(output_maps, 'tmp_forest_change2000_2020_sieve.tif')
  ))
  
  # COMPRESS
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(output_maps, 'tmp_forest_change2000_2020_sieve.tif'),
                 fchange00_20.sieved
  ))
  
  ################### REMOVE UNCOMPRESSED FILE
  system(sprintf("rm %s ",
                 paste0(output_maps, 'tmp_forest_change2000_2020_sieve.tif')
  ))
}

