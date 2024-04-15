## flat_file_preprocessing_v2.R
## 2024-04-10
## Jelmar Quist & Roman Laddach
## A script to pre-process initial flat file exports from AtoMx

#### Set up ####

## Set working directory
setwd("../input/")

## Load data
exprMat = read.csv(list.files()[grep("exprMat_file.csv$", list.files())], header = TRUE)
fov_positions = read.csv(list.files()[grep("fov_positions_file.csv$", list.files())], header = TRUE)
metadata = read.csv(list.files()[grep("metadata_file.csv$", list.files())], header = TRUE)

## Move original data to archive folder  
dir.create("archive")
s3Files = list.files()[grep(".csv", list.files())]
file.rename(s3Files, paste0("archive/", s3Files))
rm("s3Files")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#### Prepare fov_positions_file.csv ####
colnames(fov_positions)[which(colnames(fov_positions)=="FOV")] = "fov" # all files use `fov` for FOVs
fov_positions$X_px = fov_positions$X_mm*1000/0.1202809 # converting mm to px 
fov_positions$Y_px = fov_positions$Y_mm*1000/0.1202809 # converting mm to px 

write.table(fov_positions, file = "fov_positions_file.csv", quote = TRUE, sep = ",", row.names = TRUE)


#### Prepare exprMat_file.csv ####
rownames(exprMat) = exprMat$cell # cell contains information about slide_fov_cell as a good unique identifier for cells
colnames(exprMat) = gsub("Negative", "NegPrb", fixed = TRUE, colnames(exprMat)) # changing the name 
exprMat = exprMat[,grep("SystemControl", colnames(exprMat), invert = TRUE)] # removing columns which contain SystemControl probes
exprMat$fov = NULL 
exprMat$cell_ID = NULL
exprMat$cell = NULL

write.table(exprMat, file = "exprMat_file.csv", quote = TRUE, sep = ",", row.names = TRUE)


#### Prepare metadata_file.csv ####
# list of useful columns
columns_to_keep = c("fov", "cell", 
                    "Area", "AspectRatio", "Width", "Height",
                    "CenterX_local_px", "CenterY_local_px", "CenterX_global_px", "CenterY_global_px",
                    colnames(metadata)[grep("Mean|Max", colnames(metadata))]
                    )
metadata = metadata[, columns_to_keep]
rownames(metadata) = metadata$cell

write.table(metadata, file = "metadata_file.csv", quote = TRUE, sep = ",", row.names = TRUE)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
