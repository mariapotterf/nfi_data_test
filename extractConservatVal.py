

# Extract conservation values for NFI plots
# Read all files
# spatial join information from all conservation sites
# export as new files
import arcpy, os

# Set working directory
path = "C:/MyTemp/2020_FI_protectedAreas"
outWD = os.path.join(path, "output")

# set working environment
arcpy.env.workspace = os.path.join(path, "OneDrive_1_5-22-2020/NFI_by_province")
arcpy.env.overwriteOutput = True

# read input file of protected areas
inPA = "C:/MyTemp/2020_FI_protectedAreas/output.gdb/allProtected"

# Read all files in folder
fcs = arcpy.ListFeatureClasses()

# Loop throught features to perform spatial join
# of teh conservation values from teh protected sites
for fc in fcs:
    
    outFC = os.path.join(outWD, "c_"+ fc)
    targetFC = fc
    joinFC = inPA
    
    # Process: Run Spatial Join tool
    # to join attributes fromconservationt sites to NFI plots
    arcpy.SpatialJoin_analysis(targetFC,
                               joinFC,
                               outFC,
                               "",
                               "KEEP_ALL",
                               "",
                               "INTERSECT")
    