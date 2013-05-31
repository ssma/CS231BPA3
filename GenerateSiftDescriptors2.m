function [] = GenerateSiftDescriptors2( imageFileList, imageBaseDir, dataBaseDir, maxImageSize, gridSpacing, patchSize, canSkip )
%function [] = GenerateSiftDescriptors2( imageFileList, imageBaseDir, dataBaseDir, maxImageSize, gridSpacing, patchSize, canSkip )
%
%Generate the dense grid of sift descriptors for each
% image
%
% imageFileList: cell of file paths
% imageBaseDir: the base directory for the image files
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image files
% maxImageSize: the max image size. If the image is larger it will be
%  resampeled.
% gridSpacing: the spacing for the grid to be used when generating the
%  sift descriptors
% patchSize: the patch size used for generating the sift descriptor
% canSkip: if true the calculation will be skipped if the appropriate data
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Sift Descriptors\n\n');

%% parameters

if(nargin<4)
    maxImageSize = 1000
end

if(nargin<5)
    gridSpacing = 8
end

if(nargin<6)
    patchSize = [16, 25, 31];
end

if(nargin<7)
    canSkip = 0
end

patchSize = [16, 25, 31];

for f = 1:size(imageFileList,1)
    
    %% load image
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = [dirN filesep base];
    outFName = fullfile(dataBaseDir, sprintf('%s_sift.mat', baseFName));
    imageFName = fullfile(imageBaseDir, imageFName);
    
    if(size(dir(outFName),1)~=0 && canSkip)
        fprintf('Skipping %s\n', imageFName);
        continue;
    end
    
    
    
    I = sp_load_image(imageFName);
    
    [hgt wid] = size(I);
    if min(hgt,wid) > maxImageSize
        I = imresize(I, maxImageSize/min(hgt,wid), 'bicubic');
        fprintf('Loaded %s: original size %d x %d, resizing to %d x %d\n', ...
            imageFName, wid, hgt, size(I,2), size(I,1));
        [hgt wid] = size(I);
    end
    
    
    
    %% make grid (coordinates of upper left patch corners)
    remX = mod(wid-patchSize,gridSpacing);
    offsetX = floor(remX/2)+1;
    remY = mod(hgt-patchSize,gridSpacing);
    offsetY = floor(remY/2)+1;
    
    sizes(1) = ceil((wid-patchSize(1)+2- offsetX(1))/gridSpacing )*ceil((hgt-patchSize(1)+2- offsetY(1))/gridSpacing );
    sizes(2) = ceil((wid-patchSize(2)+2- offsetX(2))/gridSpacing )*ceil((hgt-patchSize(2)+2- offsetY(2))/gridSpacing );
    sizes(3) = ceil((wid-patchSize(3)+2- offsetX(3))/gridSpacing )*ceil((hgt-patchSize(3)+2- offsetY(3))/gridSpacing );
    % [gridX,gridY] = meshgrid(offsetX(1):gridSpacing:wid-patchSize(1)+1, offsetY(1):gridSpacing:hgt-patchSize(1)+1);
    
    features.wid = wid;
    features.hgt = hgt;
    % [xx yy] = size(gridX);
    %flen = sum(sizes);
    features.data =zeros(sum(sizes),128);
    features.x = zeros(sum(sizes),1);
    features.y = zeros(sum(sizes),1);
    
     fprintf('Processing %s: wid %d, hgt %d\n', ...
            imageFName, wid, hgt);
    
    
    indii = 0;
    for ii =1:3
        %% find SIFT descriptors
        [gridX,gridY] = meshgrid(offsetX(ii):gridSpacing:wid-patchSize(ii)+1, offsetY(ii):gridSpacing:hgt-patchSize(ii)+1);
       
      
        
        siftArr = sp_find_sift_grid(I, gridX, gridY, patchSize(ii), 0.8);
        siftArr = sp_normalize_sift(siftArr);
        
        features.data(indii+1:indii+sizes(ii),:) =  siftArr;
        features.x(indii+1:indii+sizes(ii)) =  gridX(:) + patchSize(ii)/2 - 0.5;
        features.y(indii+1:indii+sizes(ii)) = gridY(:) + patchSize(ii)/2 - 0.5;
        
        indii = indii+sizes(ii);
        
        %         if ii == 1
        %             features.data(1:sizes(1)) =  siftArr;
        %             features.x(1:sizes(1)) =  gridX(:) + patchSize(ii)/2 - 0.5;
        %             features.y(1:sizes(1)) = gridY(:) + patchSize(ii)/2 - 0.5;
        %         else if ii == 2
        %             features.data(sizes(1)+1:sizes(1)sizes(1)) =  siftArr;
        %             features.x(1:sizes(1)) =  gridX(:) + patchSize(ii)/2 - 0.5;
        %             features.y(1:sizes(1)) = gridY(:) + patchSize(ii)/2 - 0.5;
        %             else
        %                 patchSize = 45;
        %             end
        %         end
        
        
        
        
        
        %         features.data = [features.data; siftArr];
        %         features.x = [features.x; gridX(:) + patchSize/2 - 0.5];
        %         features.y = [features.y; gridY(:) + patchSize/2 - 0.5];
        
        %         if ii == 0
        %             patchSize = 25;
        %         else if ii == 1
        %                 patchSize = 31;
        %             else
        %                 patchSize = 45;
        %             end
        %         end
        %
        %         %% make grid (coordinates of upper left patch corners)
        %         remX = mod(wid-patchSize,gridSpacing);
        %         offsetX = floor(remX/2)+1;
        %         remY = mod(hgt-patchSize,gridSpacing);
        %         offsetY = floor(remY/2)+1;
        
        %  [gridX,gridY] = meshgrid(offsetX:gridSpacing:wid-patchSize+1, offsetY:gridSpacing:hgt-patchSize+1);
        
        
    end
    
    sp_make_dir(outFName);
    save(outFName, 'features');
    
end % for

end % function