grassFiles = dir('grass/*.png'); 
grassNumFiles = length(grassFiles);
grassCell = cell(1, grassNumFiles);
for k = 1:grassNumFiles
 grassCell{k} = imread(strcat('grass/', grassFiles(k).name)); 
end

soilFiles = dir('soil/*.png'); 
soilNumFiles = length(soilFiles);
soilCell = cell(1, soilNumFiles);
for k = 1:soilNumFiles
 soilCell{k} = imread(strcat('soil/', soilFiles(k).name)); 
end

grass = cell2mat(grassCell);
soil = cell2mat(soilCell);

grassRmean = mean2(grass(:,:,1)); grassRstd =  std2(grass(:,:,1)); 
grassGmean = mean2(grass(:,:,2)); grassGstd =  std2(grass(:,:,2)); 
grassBmean = mean2(grass(:,:,3)); grassBstd =  std2(grass(:,:,3)); 

soilRmean = mean2(soil(:,:,1)); soilRstd =  std2(soil(:,:,1)); 
soilGmean = mean2(soil(:,:,2)); soilGstd =  std2(soil(:,:,2)); 
soilBmean = mean2(soil(:,:,3)); soilBstd =  std2(soil(:,:,3));

grassRange = [round(grassRmean - 2*grassRstd), round(grassRmean + 2*grassRstd);
             round(grassGmean - 2*grassGstd), round(grassGmean + 2*grassGstd);
             round(grassBmean - 2*grassBstd), round(grassBmean + 2*grassBstd)];

soilRange = [round(soilRmean - 2*soilRstd), round(soilRmean + 2*soilRstd);
             round(soilGmean - 2*soilGstd), round(soilGmean + 2*soilGstd);
             round(soilBmean - 2*soilBstd), round(soilBmean + 2*soilBstd)];
      
save('grass.mat', 'grassRange');
save('soil.mat', 'soilRange');
