
# ------------------------------------
# Reclassify conservation values
# ------------------------------------
# ======================
# Multiple categories:

# landscape level protection
# noprotection = commercial forests
# IUCN category
# process: 
# - read shp files with FID!! (FID is not unique across all files, just onique over one file)
# - recode the conservation values
# - get coordinates
# - export shp         
# - export coordinates in .csv for individual regions


library(sf)
library(dplyr)
library(data.table)

# List all shp files:
setwd("C:/MyTemp/2020_FI_protectedAreas/output")


# List all shp.files
fcs.names <- list.files(getwd(), pattern = ".shp$")


# read all files as sf geometry,
# include the FID as unique indicator by shp  
fcs.ls<-  lapply(fcs.names, function(x) st_read(x, 
                                                fid_column_name = "FID",
                                                stringsAsFactors = FALSE))

lapply(fcs.ls, head)



# Understand the protecction categorries and reclassify the datasets:
# Landscape level protection: YES, NO
# statutory Protected sites: YES, NO
# IUCN categories


# -------------------------------------

# Reclassify the table
reclassProtected <- function(nfi_sf, ...) {
  
  
  #nfi_sf <- fcs.ls[[5]]
  
  # Keep coordinates
  centroid <- st_centroid(nfi_sf)
  
  coord.nfi <- data.frame(cbind(centroid$standid,
                               # nfi_sf$FID,
                                st_coordinates(centroid)), 
                          stringsAsFactors = FALSE)
  # Assign names
  names(coord.nfi) <- c("standid", "X", "Y") # "FID",
  
  
  # Convert to data.frame
  # Set geometry to null
  nfi_df <- nfi_sf
  st_geometry(nfi_df) <- NULL
  
   # 
  df<- nfi_df %>% 
    mutate(landscapeProt = ifelse(is.na(Luokka), "0", "1")) %>% # Landscape
    mutate(statutoryProt = ifelse(is.na(TyyppiLyhe), "0", "1")) %>% 
    mutate(IUCNcat = ifelse((is.na(IUCNKatego) | IUCNKatego == " " ), "0", as.character(IUCNKatego))) %>% 
    select(standid,
          # FID,
           Luokka, 
           TyyppiLyhe, 
           IUCNKatego,
           landscapeProt, 
           statutoryProt, 
           IUCNcat ) %>% 
    mutate(protection = case_when(statutoryProt != 0 ~ "strict",
                                   statutoryProt == 0 & landscapeProt != 0 ~ "landscape",
                                   TRUE ~ "commercial")
    ) %>% 
    left_join(coord.nfi, by = "standid")
  
  return(df)
  
}



# hget the outputs as 
rcl.ls<- lapply(fcs.ls, reclassProtected)

lapply(rcl.ls, function(df) unique(df$protection)) 

# Double control, export at shp and csv
# check shp in Arcgis 
# -----------------------------
names(rcl.ls) <- fcs.names

# Export the .csv and shp files,
# iterate over the names
lapply(1:length(rcl.ls), function(i) {
  
  # Convert to s.sf
  s.sf <- st_as_sf(rcl.ls[[i]], 
                   coords = c("X", "Y"), 
                   crs = 3067, 
                   agr = "constant")
  # Export geometry
  outName = names(rcl.ls[i])
  outShp = paste("C:/MyTemp/2020_FI_protectedAreas/output_r", outName, sep = "/")
  #print(outShp)
  st_write(s.sf, outShp)
  
  # Export as csv 
  outCSV = gsub("shp", "csv", outName)
  fwrite(rcl.ls[[i]], paste("C:/MyTemp/2020_FI_protectedAreas/output_r", outCSV, sep = "/"))
  
})

