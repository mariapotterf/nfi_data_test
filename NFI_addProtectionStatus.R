
# ------------------------------------
# Reclassify conservation values
# ------------------------------------

# Multiple categories:

# landscape level protection
# noprotection = commercial forests
# IUCN category

library(sf)
library(dplyr)
library(data.table)

nfi_sf = st_read("C:/MyTemp/2020_FI_protectedAreas/output.gdb",
                 layer = "NFI_protectStatus",
                 fid_column_name = "FID")

coord.nfi <- st_coordinates(nfi_sf)
head(nfi_sf)

# Convert to data.frame
nfi_df <- nfi_sf
st_geometry(nfi_df) <- NULL






# Understand the protecction categorries and reclassify the datasets:
# Landscape level protection: YES, NO
# statutory Protected sites: YES, NO
# IUCN categories


# ----------------------------------
# Explore the unique values
# -----------------------------------

unique(nfi_df$Luokka)     # landscape
ifelse(is.na(nfi_df$Luokka), "0", "1")

# [1] <NA> SSO  HSO  MAO  RSO  LVO  AMO  LHO  PMO  KLO 
# Levels: AMO HSO KLO LHO LVO MAO PMO RSO SSO

# protected sites
unique(nfi_df$TyyppiLyhe)   # protected areas = statutory

#[1] <NA> KPU  YSA  VMA  SSA  ESA  LPU  EMA  LHA  MRA  LTA  ERA 
# Levels: EMA ERA ESA KPU LHA LPU LTA MRA SSA VMA YSA


unique(nfi_df$IUCNKatego)  
#[1] <NA> II   IV   Ib   V         Ia  
#Levels:   Ia Ib II IV V

# Reclassify the table
nfi_df2 <- 
  nfi_df %>% 
  mutate(landscapeProt = ifelse(is.na(Luokka), "0", "1")) %>% # Landscape
  mutate(statutoryProt = ifelse(is.na(TyyppiLyhe), "0", "1")) %>% 
  mutate(IUCNcat = ifelse((is.na(IUCNKatego) | IUCNKatego == " " ), "0", as.character(IUCNKatego))) %>% 
  select(FID,
         Luokka, 
         TyyppiLyhe, 
         IUCNKatego,
         landscapeProt, 
         statutoryProt, 
         IUCNcat ) %>% 
  mutate(protect_lev = case_when(statutoryProt != 0 ~ "strict",
                               statutoryProt == 0 & landscapeProt != 0 ~ "landscape",
                               TRUE ~ "commercial")
  )




# Inspect the output table
head(nfi_df2)


unique(nfi_df2$landscapeProt)
unique(nfi_df2$statutoryProt)
unique(nfi_df2$IUCNcat)
unique(nfi_df2$protect_lev)


subset(nfi_df2, protect_lev == "strict")
subset(nfi_df2, protect_lev == "landscape")
subset(nfi_df2, protect_lev == "commercial")


# Export table
# fast export 
fwrite(nfi_df2, "C:/MyTemp/2020_FI_protectedAreas/outTable/NFI_protection.csv")
