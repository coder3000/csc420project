%% Find YCbCr ranges for grass and soil
grassFiles = dir('grass/*.png'); 
grassNumFiles = length(grassFiles);
grassCell = cell(1, grassNumFiles);
for k = 1:grassNumFiles
 grassCell{k} = rgb2ycbcr(imread(strcat('grass/', grassFiles(k).name))); 
end

soilFiles = dir('soil/*.png'); 
soilNumFiles = length(soilFiles);
soilCell = cell(1, soilNumFiles);
for k = 1:soilNumFiles
 soilCell{k} = rgb2ycbcr(imread(strcat('soil/', soilFiles(k).name))); 
end

grass = cell2mat(grassCell);
soil = cell2mat(soilCell);

grassYmean = mean2(grass(:,:,1)); grassYstd =  std2(grass(:,:,1)); 
grassCbmean = mean2(grass(:,:,2)); grassCbstd =  std2(grass(:,:,2)); 
grassCrmean = mean2(grass(:,:,3)); grassCrstd =  std2(grass(:,:,3)); 

soilYmean = mean2(soil(:,:,1)); soilYstd =  std2(soil(:,:,1)); 
soilCbmean = mean2(soil(:,:,2)); soilCbstd =  std2(soil(:,:,2)); 
soilCrmean = mean2(soil(:,:,3)); soilCrstd =  std2(soil(:,:,3));

grassRange = [round(grassYmean - 2*grassYstd), round(grassYmean + 2*grassYstd);
             round(grassCbmean - 2*grassCbstd), round(grassCbmean + 2*grassCbstd);
             round(grassCrmean - 2*grassCrstd), round(grassCrmean + 2*grassCrstd)];

soilRange = [round(soilYmean - 2*soilYstd), round(soilYmean + 2*soilYstd);
             round(soilCbmean - 2*soilCbstd), round(soilCbmean + 2*soilCbstd);
             round(soilCrmean - 2*soilCrstd), round(soilCrmean + 2*soilCrstd)];

% reference
%grassRange = [55, 118; 96,117; 119,132];
%soilRange = [64,127; 108,129;126,153];

save('grass.mat', 'grassRange');
save('soil.mat', 'soilRange');

clear sceneFeature;
