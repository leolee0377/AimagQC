function blockorg = QC_patchblurDetection_mask_3(pathimage,bs,PageIndex,OutputPath,slideID,MASK,ImageType,Scanner,ImCat,I0)
% Patch Generator KEY QUALITY CONTROL ANALYSIS CODE!
% input :
% # path to QPtiff image
% # block structure of the blockproc function
% # page index of the channel to process ( highResolution Pages only)
% # outputpath
% # Name of the file
% # Intensity based simple trheshold for filtering tiles ( graythresh like)
% Author: Laurent GOLE, AIMAGINOSTIC PTE LTD ®. All Rights Reserved ©, 2020.
% Author: Laurent GOLE, A*STAR, IMCB ®. All Rights Reserved ©, 2019.
if contains(Scanner, 'KFBIO')
    
    Coord = bs.location-1  ;
    LocalPTR = struct('DataFilePTR', int64(0)) ;
    [bool, LocalPTR, ~] = calllib('lib','InitImageFileFunc',LocalPTR,pathimage) ;
    if bool==0
        block = 255.*uint8(true([(bs.blockSize),3]) ) ;
        blockorg = block ;
        disp('LocalPTR ERROR IN QC_PatchblurDetection_mask_3')
        return
    end
    
    %     LocalPTR
    [~, datalength] = calllib('lib','GetImageStreamSize',LocalPTR,PageIndex,Coord(2),Coord(1),0);
    pBuffer = libpointer('uint8Ptr',zeros(datalength,1));
    [~, pBuffer] = calllib('lib','GetImageStreamBySize',LocalPTR,PageIndex,Coord(2),Coord(1),datalength,pBuffer);
    
    % Unload the pointer from memory! : 
    [bool] = calllib('lib','UnInitImageFileFunc',LocalPTR) ;
     if bool==0
        disp('UnInitImageFileFunc ERROR IN QC_PatchblurDetection_mask_3 ??')
        return
    end
    
    
    try block = decodeJpeg (pBuffer) ;
    catch
        disp('empty image block?')
        % prolly empty pbduffer? so give empty imageoutput:
        block = 255.*uint8(true([(bs.blockSize),3]) );
    end
    try
        block = block(1:bs.blockSize(1),1:bs.blockSize(2),:) ;
    catch
        % disp(['some size issue? ' num2str(bs.location)])
        % for edges bottom mostly
        tmp = 255.*uint8(true([(bs.blockSize),3]) );
        tmp(1:size(block,1),1:size(block,2),:) = block ;
        block =tmp ;
        block = block(1:bs.blockSize(1),1:bs.blockSize(2),:) ;
    end
    
elseif contains(Scanner, ' OME')
    t = Tiff(pathimage,'r') ;
    offsets = getTag(t,'SubIFD') ;
    setSubDirectory(t,offsets(PageIndex-1)) ;
    t.computeTile(bs.location) ;
    block =readEncodedTile(t,t.computeTile(bs.location)) ;
    close(t) ;
    
    
else
    
    block = imread(pathimage,'Index',PageIndex,'PixelRegion',...
        {[bs.location(1) bs.location(1)+bs.blockSize(1)-1],...
        [bs.location(2) bs.location(2)+bs.blockSize(2)-1]}) ;
    
    
end




blockorg = block ;


try BLOCKMASK  = MASK([bs.location(1):bs.location(1)+bs.blockSize(1)-1],...
        [bs.location(2):bs.location(2)+bs.blockSize(2)-1]) ; %#ok<NBRAK>
catch
    BLOCKMASK  = false(bs.blockSize(1),bs.blockSize(2)) ;
end



% MEASURE ONLY WHEN THE MASK COVERS MORE THAN 10% of the TILE
if sum(sum(BLOCKMASK))> (0.1*bs.blockSize(1)*bs.blockSize(2))
    % CONVERTION TO OPTICAL DENSITY IMAGE FOR H&E INPUT:
    if strcmp(ImageType,'BrightField')
        [x, y, z] = size(block) ;
        Image   = double(block)                    ;
%         I0      = 255                           ;
        % calculate optical density image :
        OD      = -log((Image+1)/I0)            ;
        ODim    = reshape(OD,[x, y, z])           ;
        ODim    = uint8(255.*ODim)              ;
        %ODg     = rgb2gray(ODim)                ;
        ODg     = ODim ;
        block = ODg ;
        block =  rgb2gray(block) ;
    end
    % CONVERTION TO OPTICAL DENSITY IMAGE FOR H&E INPUT:
    if strcmp(ImageType,'BrightField')
        
       switch ImCat
           case 'HEIHC'
               
           [FM,BM,SM,CM,TM] = QC_imageMeasurements_BF_2(BLOCKMASK,block) ;
           case 'TCT'
        % PUT a IF IS 'TCT' HERE: 
           [FM,BM,SM,CM,TM] = QC_imageMeasurements_TCT_2(BLOCKMASK,block) ;
       end
        
    else
        [FM,BM,SM,CM,TM] = QC_imageMeasurements_MF_2(BLOCKMASK,block) ;
    end
    
    
    
%     if (FM>0 && FM<100)
%     
%         tmp = block ; 
%         tmp(block<63) = 0 ;
%         disp('CHECK this tile')
%        figure(1) ; imagesc(tmp) 
       
%         
%         
%     end
%     
    
    
    %AreaWeight
    AW = sum(BLOCKMASK(:)) ./ (size(BLOCKMASK,1)*size(BLOCKMASK,2)) ;
    % output block image with Location and measured values:
    imwrite(blockorg,[OutputPath filesep  slideID 'Loc_' num2str(bs.location)...
        '_FM_' num2str(FM) '_BM_' num2str(BM)...
        '_SM_' num2str(SM) '_CM_' num2str(CM)...
        '_TM_' num2str(TM) '_AW_' num2str(AW)...
        '.png']) ;
end

end


