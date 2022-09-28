classdef KFBIO_IO < ImageAdapter
    %% VectraPolaris Image Reader for Matlab
    % PROPERTIES OF VectraPolarisIO CLASS ARE:
    %    #  Filename   % path to the QPtiff file of interest
    %    #  Info       % contains all pages metadata
    %    #  Indexes    % CONTAINS useful pages indexes
    %    #  MetaData   % contains 1st age metadata with ScanProfile
    %    #  ImSize     % size of the high resolution image (X and Y)
    %    #  ThumbnailImage % extract Thumbnail image
    %    #  LabelImage  % extract Label Image
    %    #  OverviewImage % overview small fluo image
    %    #  Filters     % CONTAINS useful information abt the filters name and page indexes
    %    #  Channels_path % output path of the Parextract Function
    %    #  Patches_path % output paths for the Patch Generator function
    %    #  Analysis_path % output path for the user defined patch apply function
    %    #  Output_path % output path for the 2Channel QPTIFF generation
    %    #  ScanProfile % ScanProfile Metadata
    % METHODS OF VectraPolarisIO CLASS  are :
    %    # PARextract % to extract a highres tif image of a single channel grayscale (optional)
    %    # CreateTif  % ( necessary for all Blockprocess function )
    %    # patch_generation % save individual Tif Tiles of the images a
    % threshold option is possible to extract only tiles that contains
    % enough intensity signal
    %    # patch_stitcher % (optional ) can put back together into 1 image tiles
    % extracted by the patch Generation function
    %    # patch_applyfunc %  Apply a function by block ,
    % e.g: considering a user define function F such that ImB = F(ImA,Params{})
    %    # Gen_2Channel_QPtiff % considering a qptiff and a user created
    % Tiff image, this function combined them together into a new QPtiff
    % all rights reserved, Laurent Gole, A*STAR, IMCB-CBA 2019
    properties
        Filename   % path to the QPtiff file of interest
        Info       % contains all pages metadata
        Indexes    % CONTAINS useful pages indexes
        MetaData   % contains 1st age metadata with ScanProfile
        ImSize     % size of the high resolution image (X and Y)
        ThumbnailImage % extract Thumbnail image
        LabelImage  % extract Label Image
        OverviewImage % overview small fluo image
        Filters     % CONTAINS useful information abt the filters name and page indexes
        Channels_path % output path of the Parextract Function
        Patches_path % output paths for the Patch Generator function
        Analysis_path % output path for the user defined patch apply function
        Output_path % output path for the 2Channel QPTIFF generation
        ScanProfile % ScanProfile Metadata
        Tmp_path % path for the dummy tiff for blockproc processes
    end
    
    
    methods(Static)
        
        function unloadLib()
            if (libisloaded('lib'))
                unloadlibrary 'lib'
            end
            spmd
                for i = 1:numlabs
                    if i == labindex
                        if (libisloaded('lib'))
                            unloadlibrary 'lib'
                        end
                    end
                    labBarrier
                end
            end
            disp(['Kfbio IO Library Unloaded on all workspace.'])
        end
        

        
        function loadCoreLib()
            if not(libisloaded('lib'))
                loadlibrary('ImageOperationLib',@KFBIO_SDK_Header,'alias','lib')
            disp(['Kfbio IO Library Loaded on Base workspace.'])
            else
            disp(['Kfbio IO Library Already in memory '])
            end  
        end
        
        
        function loadParalellLib()
            % PARALLELL LOADING OF DLL:
            spmd
                for i = 1:numlabs
                    if i == labindex
                        if not(libisloaded('lib'))
                            loadlibrary('ImageOperationLib',@KFBIO_SDK_Header,'alias','lib')
                        else
                            disp('Library already in memory')
                        end
                    end
                    labBarrier
                end
            end
            disp('Kfbio IO Library Loaded on each Core workspace.')
        end
    end
    

    
    
    
    
    methods
        %%
        % *************************************************************************
        % ************************INITIALISATION OF KFBIO OBJECT********************
        % *************************************************************************
        function obj        = KFBIO_IO(filename)
            obj.Filename    = filename;

            obj.loadCoreLib()
            obj.loadParalellLib()
            %

            % *************************************************************************
            % ************************read VectraPolaris metadata**********************
            % *************************************************************************
            % general information:_________________________________________
            SlideID(1) = {extractImageName( obj.Filename  ,'.kfb')};
 
            % initialise parameters:
            IMAGE_PTR = [] ; 
            IMAGE_PTR.DataFilePTR = 0 ;
            IMAGE_INFO_STRUCT = [] ;
            int32Ptr = int32(0) ;
            singlePtr = single(0) ;
            doublePtr = double(0) ;
            
            % INIT image: %     {'[bool, IMAGE_INFO_STRUCTPtr, cstring] InitImageFileFunc(IMAGE_INFO_STRUCTPtr, cstring)'                                                                                                       }
            [bool, IMAGE_PTR, ~] = calllib('lib','InitImageFileFunc',IMAGE_PTR,obj.Filename) ;
            disp(['Init image in KFBIO_IO on Base workspace:' num2str(bool)])
            % GET HEADER:  %     {'[bool, int32Ptr, int32Ptr, int32Ptr, singlePtr, doublePtr, singlePtr, int32Ptr] GetHeaderInfoFunc(IMAGE_INFO_STRUCT, int32Ptr, int32Ptr, int32Ptr, singlePtr, doublePtr, singlePtr, int32Ptr)'}
            [bool, IMAGE_INFO_STRUCT.Height, IMAGE_INFO_STRUCT.Width, IMAGE_INFO_STRUCT.ScanScale, IMAGE_INFO_STRUCT.SpendTime, IMAGE_INFO_STRUCT.ScanTime, IMAGE_INFO_STRUCT.ImageCapRes, IMAGE_INFO_STRUCT.ImageBlockSize] = ...
                calllib('lib','GetHeaderInfoFunc',IMAGE_PTR, int32Ptr, int32Ptr, int32Ptr, singlePtr, doublePtr, singlePtr, int32Ptr) ;
             
            
            IMAGE_INFO_STRUCT.ScanScale ;
            
            
            
            Magnification = {num2str(max(IMAGE_INFO_STRUCT.ScanScale ))} ;
            
            PixelSizeMicrons = IMAGE_INFO_STRUCT.ImageCapRes  ;
            AcquisitionSoftware = 'KFBIO Scanner' ;
            AcquisitionDate = date ;
            
            FresIndex = 1 ;
            RresIndex = [2 4 8 16 32];
            ImageWidth  = IMAGE_INFO_STRUCT.Width;
            ImageHeight  = IMAGE_INFO_STRUCT.Height;
            ImSize = [ImageHeight ImageWidth  3] ;
            
            %smallimagesReading:_________________________
            LabelImage = read_Kfbio_extraimages(IMAGE_PTR,'GetLabelSize','GetLabelBySize') ;
            OverviewImage = read_Kfbio_extraimages(IMAGE_PTR,'GetPreviewSize','GetPreviewBySize') ;
            ThumbnailImage = read_Kfbio_extraimages(IMAGE_PTR,'GetThumbnailSize','GetThumbnailBySize') ;

            % unload the pointer to the image here: 
            [bool] = calllib('lib','UnInitImageFileFunc',IMAGE_PTR) ;
            
            %             %list of all channels :
            Nchannel = numel(FresIndex) ;
            for i = 1:Nchannel
                Channelidx{i} = [FresIndex(i),   RresIndex(i:Nchannel:end)] ;
            end
            
            % Filter thingy :
            Color = {[1 1 1]} ;
            FilterName = {['HE_'  Magnification{1} 'x']};
            Markers = {'he'} ;
            
            % store info into obj sturcture:
            obj.ThumbnailImage = ThumbnailImage ;
            obj.LabelImage   =LabelImage  ;
            obj.OverviewImage =OverviewImage ;
            obj.Indexes.HighResolution =  1 ;
            obj.Indexes.RresIndex =  RresIndex ;
            obj.Indexes.Channels = Channelidx ;
            obj.Filters.Nchannel = Nchannel ;
            obj.MetaData.SlideID = SlideID ;
            obj.MetaData.AcquisitionSoftware = AcquisitionSoftware;
            obj.MetaData.AcquisitionDate = AcquisitionDate ;
            obj.MetaData.NumPages = 10;
            obj.MetaData.Magnification = Magnification ;
            obj.MetaData.PixelSizeMicrons = {num2str(PixelSizeMicrons)} ;
            % at the momment brightfield is hardcoded:
            obj.MetaData.ImageMode = {'Brightfield'};
            obj.ImSize= ImSize ;

            obj.Indexes.Magnification = [1 2 4 8 16 32] ;
            obj.Filters.Name=   FilterName;
            obj.Filters.Color =  Color ;
            obj.Filters.Markers = obj.filter2marker('default',obj.Filters.Name) ;
            obj.Reinitialize_paths() ;
            
            warning('off','imageio:tifftagsread:expectedTagDataFormat')
            
        end
        
        
        %%
        % *************************************************************************
        % ************************FUNCTIONS DEFINITIONS****************************
        % *************************************************************************
        
        % Fct to create a tif template useful for further *blockproc* functions****
        % ***return the path of the created tmp file ******************************
        
        function [tmppath,MagnificationIndex,filesize] = createTif(obj,Magnificationfactor)
            % input:1) Magnificationfactor
            % input range: choose one among obj.Indexes.Magnification {1     2     4     8    16    32    64}
            % output:1) path to a tif file
            % output:2) Index corresponding to magnificationfactor
            % output:3) size of the corresponding Image
            % Function: create a temporary tiff file of the corresponding
            % size necessary for blockprocessing
            
            MagnificationIndex = (obj.Indexes.Magnification == Magnificationfactor) ;
            PageIndex = obj.Indexes.Channels{1}(MagnificationIndex) ;
            filesize(1) =  obj.ImSize(1) /  Magnificationfactor;
            filesize(2) =  obj.ImSize(2) /  Magnificationfactor;
            Magnification = str2double(obj.MetaData.Magnification) / Magnificationfactor ;
            tmppath = strrep(obj.Filename,'.kfb',['_tmp' num2str(Magnificationfactor) '.tif']) ;
            obj.Tmp_path = tmppath ;
            if isfile(tmppath)
                tmpinfo = imfinfo(tmppath) ;
                if tmpinfo.Height==filesize(1) && tmpinfo.Width==filesize(2)
                    %  disp('tmpfile already exist')
                    return
                end
            end
            t = Tiff(tmppath, 'w8');
            %  disp('writing tmp image')
            tagstruct.ImageLength = double(filesize(1));
            tagstruct.ImageWidth = double(filesize(2));
            tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
            tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
            tagstruct.Compression = Tiff.Compression.None;
            tagstruct.BitsPerSample = 8;
            tagstruct.SamplesPerPixel = 1;
            tagstruct.RowsPerStrip = 160000 ; % why constant ? why not...
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Software = 'MATLAB';
            t.setTag(tagstruct);
            t.write(uint8(zeros([filesize(1:2),1])));
            t.close(); 
        end
        
        
        %% to extract Tiles from image and save those patches as individual tif file
        % return the path to the folder containing all the tiles
        function [TchannelPath,obj] = patch_generation(obj,ImageFilterIndex,patchSize,ImThreshold)
            % set to zero saves all blocks
            %ImThreshold = [0 1[ ;
            P = strsplit(obj.Filename,filesep) ;
            P{end} = 'Patches' ;
            P = join(P,filesep) ;
            P = P{1} ;
            P = [P filesep obj.Filters.Name{ImageFilterIndex}] ;
            if ~exist(P,'dir')
                mkdir(P)
            end
            SlideID = obj.MetaData.SlideID{1};
            obj.Patches_path{ImageFilterIndex} = [P] ;
            TchannelPath =  obj.Patches_path{ImageFilterIndex};
            fun = @(block_struct) block_patchGenerator(obj.Filename,block_struct,ImageFilterIndex,TchannelPath,SlideID,ImThreshold) ;
            blockproc(obj.Tmp_path,[patchSize(1) patchSize(2)],fun,...
                'PadPartialBlocks',true,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true...
                )    ;
        end
        %******************************************************************
        
        %% to extract Tiles from image and save those patches as individual tif file
        % return the path to the folder containing all the tiles
        function [TchannelPath,obj] = patch_generation_02(obj,ImageFilterIndex,patchSize,ImThreshold,SThreshold)
            % set to zero saves all blocks
            %ImThreshold = [0 1[ ;
            P = strsplit(obj.Filename,filesep) ;
            P{end} = 'Patches' ;
            P = join(P,filesep) ;
            P = P{1} ;
            P = [P filesep obj.Filters.Name{ImageFilterIndex}] ;
            if ~exist(P,'dir')
                mkdir(P)
            end
            SlideID = obj.MetaData.SlideID{1};
            obj.Patches_path{ImageFilterIndex} = [P] ;
            TchannelPath =  obj.Patches_path{ImageFilterIndex};
            
            fun = @(block_struct) block_patchGenerator_02(obj.Filename,block_struct,ImageFilterIndex,TchannelPath,SlideID,ImThreshold,SThreshold) ;
            blockproc(obj.Tmp_path,[patchSize(1) patchSize(2)],fun,...
                'PadPartialBlocks',true,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true...
                )    ;
        end
        %******************************************************************
        
        %% toget the Tiles from a folder image and stitch them back based on Filename Location
        % return the path to the folder containing all the tiles
        function [patchpath,obj] = patch_stitcher(obj,channelIndex,ImageFilterIndex,patchSize)
            P = strsplit(obj.Filename,filesep) ;
            P{end} = 'Patches' ;
            P = join(P,filesep) ;
            patchpath = obj.Patches_path{ImageFilterIndex} ;
            slideID = obj.MetaData.SlideID{1} ;
            fun = @(block_struct) block_patchStitcher(patchpath,block_struct,slideID)  ;
            blockproc(obj.Tmp_path,[patchSize(1) patchSize(2)],fun,...
                'PadPartialBlocks',true,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true,...
                'Destination',[P{1} filesep  slideID '_' obj.Filters.Name{ImageFilterIndex} '.tif'])    ;
            patchpath = [P{1} filesep  slideID '_' obj.Filters.Name{ImageFilterIndex} '.tif'] ;
        end
        %******************************************************************
        
        
        
        
        
        %% to extract Tiles from image and save those patches as individual tif file
        % return the path to the folder containing all the tiles
        function [TchannelPath,obj] = patch_blurdetection(obj,channelIndex,Magnificationfactor,patchSize,ImThreshold,SThreshold)
         
            MagnificationIndex = (obj.Indexes.Magnification == Magnificationfactor) ;
            PageIndex = obj.Indexes.Channels{channelIndex}(MagnificationIndex) ;
            filesize = [obj.Info(PageIndex).Height obj.Info(PageIndex).Width] ;
            tmppath = strrep(obj.Filename,'.tif',['_tmp' num2str(Magnificationfactor) '.tif']) ;
            
            P = strsplit(obj.Filename,filesep) ;
            P{end} = 'Patches' ;
            P = join(P,filesep) ;
            P = P{1} ;
            P = [P filesep obj.Filters.Name{channelIndex}] ;
            if ~exist(P,'dir')
                mkdir(P)
            end
            SlideID = obj.MetaData.SlideID{1};
            obj.Patches_path{channelIndex} = [P] ;
            TchannelPath =  obj.Patches_path{channelIndex};
            
            mkdir([TchannelPath filesep 'Focused'])
            mkdir([TchannelPath filesep 'Blurred'])
            mkdir([TchannelPath filesep 'inbetween'])

            Index =  obj.Indexes.Channels{channelIndex}(MagnificationIndex) ;
            fun = @(block_struct) block_patchblurDetection(obj.Filename,block_struct,Index,TchannelPath,SlideID,ImThreshold,SThreshold) ;
            blockproc(obj.Tmp_path,[patchSize(1) patchSize(2)],fun,...
                'PadPartialBlocks',true,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true...
                )    ;
        end
        %******************************************************************
        
        
        
        
        
        
%         %% to extract Tiles from image and save those patches as individual tif file
%         % return the path to the folder containing all the tiles
%         function [TchannelPath,obj,ResQuant] = patch_blurdetection_mask(obj,channelIndex,Magnificationfactor,patchSize,MASK,ImageType,FocusThreshold)
%             % set to zero saves all blocks
%             %ImThreshold = [0 1[ ;
%             % this is an obsoloete old version of the code ::
%             MagnificationIndex = (obj.Indexes.Magnification == Magnificationfactor) ;
%             PageIndex = obj.Indexes.Channels{channelIndex}(MagnificationIndex) ;
%             filesize = [obj.Info(PageIndex).Height obj.Info(PageIndex).Width] ;
%             tmppath = strrep(obj.Filename,'.tif',['_tmp' num2str(Magnificationfactor) '.tif']) ;
%             P = strsplit(obj.Filename,filesep) ;
%             P{end} = 'Patches' ;
%             P = join(P,filesep) ;
%             P = P{1} ;
%             SlideID = obj.MetaData.SlideID{1};
%             obj.Patches_path{channelIndex} = [P] ;
%             TchannelPath =  [obj.Patches_path{channelIndex} '_' num2str(Magnificationfactor)];
%             if ~exist(TchannelPath,'dir')
%                 mkdir(TchannelPath)
%             end
%             
%             if exist([TchannelPath filesep 'Focused'])==7
%                 rmdir([TchannelPath filesep 'Focused'],'s')
%             end
%             if exist([TchannelPath filesep 'Blurred'])==7
%                 rmdir([TchannelPath filesep 'Blurred'],'s')
%             end
%             if exist([TchannelPath filesep 'inbetween'])==7
%                 rmdir([TchannelPath filesep 'inbetween'],'s')
%             end
%             
%             mkdir([TchannelPath filesep 'Focused'])
%             mkdir([TchannelPath filesep 'Blurred'])
%             mkdir([TchannelPath filesep 'inbetween'])
%            
%             Index =  obj.Indexes.Channels{channelIndex}(MagnificationIndex) ;
%             fun = @(block_struct) block_patchblurDetection_mask(obj.Filename,block_struct,Index,TchannelPath,SlideID,MASK,ImageType,FocusThreshold) ;
%             blockproc(obj.Tmp_path,[patchSize(1) patchSize(2)],fun,...
%                 'PadPartialBlocks',true,'BorderSize',[0 0],...
%                 'DisplayWaitbar',false,'UseParallel',true...
%                 )    ;
%             
%             N1 =    numel(dir([TchannelPath filesep 'Focused']))-2;
%             N2 =    numel(dir([TchannelPath filesep 'Blurred']))-2;
%             N3 =    numel(dir([TchannelPath filesep 'inbetween']))-2;
%             N = N1+N2+N3;
%             
%             ResQuant.NumberofTiles.Focused = N1 ;
%             ResQuant.NumberofTiles.Blurred = N2;
%             ResQuant.NumberofTiles.inbetween = N3 ;
%             ResQuant.NumberofTiles.Total = N ;
%             
%             try imds = imageDatastore(TchannelPath,'IncludeSubfolders',true);
%                 idx = 0 ;
%                 for j =1:numel(imds.Files)
%                     
%                     try  FMval = extractBetween(imds.Files{j},'FM_','.png') ;
%                         idx = idx+1 ;
%                         FocusMeasurement(idx) = str2num(FMval{1}) ; 
%                     catch
%                         idx = idx-1 ;
%                     end
%                     
%                 end
%                 ResQuant.FocusValues = FocusMeasurement ;
%                 
%                 ResQuant.PercentofTiles.Focused = 100*(N1./N) ;
%                 ResQuant.PercentofTiles.Blurred = 100*(N2./N) ;
%                 ResQuant.PercentofTiles.inbetween = 100*(N3./N) ;
%                 ResQuant.PercentofTiles.Total = 100*(N./N) ;
%                 
%                 idx = 0 ;
%                 for j =1:numel(imds.Files)
%                     try  Locval = extractBetween(imds.Files{j},'Loc_','FM_') ;
%                         idx = idx+1 ;
%                         tmp = str2num(Locval{1}) ;
%                         LocMeasurement(idx,1) = tmp(1) ;
%                         LocMeasurement(idx,2) = tmp(2) ;
%                         
%                     catch
%                         idx = idx-1 ;
%                     end
%                     
%                 end
%                 ResQuant.LocValues = LocMeasurement ;
%                 
%                 
%                 
%                 
%                 
%             catch
%                 disp('warning,no tiles detected')
%                 ResQuant = [] ;
%             end
%             
%         end
        %******************************************************************
        
        
        
        
        
        
        
        
        
        
        %% PATCH APPLY a user defined function
        % eg: such that ImageOut = function(ImageIn,SomeParameter) ; ImageIn will be the blocks
        function [AchannelPath,obj] = patch_applyfunc(obj,ImageFilterIndex,patchSize,fun_handle,params,functionName)
            P = strsplit(obj.Filename,filesep) ;
            P{end} = ['Analysis_' functionName] ;
            P = join(P,filesep) ;
            P = P{1} ;
            if ~exist(P,'dir')
                mkdir(P)
            end
            obj.Analysis_path{ImageFilterIndex} = [P filesep obj.MetaData.SlideID{1} '_' obj.Filters.Name{ImageFilterIndex} '.tif'];
            AchannelPath =  obj.Analysis_path{ImageFilterIndex};
            fun = @(block_struct) block_patchapply(obj.Filename,block_struct,ImageFilterIndex,fun_handle,params) ;
            blockproc(obj.Tmp_path,[patchSize(1) patchSize(2)],fun,...
                'PadPartialBlocks',true,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true,...
                'Destination',obj.Analysis_path{ImageFilterIndex})    ;
        end
        %******************************************************************
        
        
        %% QPTIF 2CHANNEL GENERATOR (1st channel is original channel of interest(COI) | 2nd channel is processed COI
        %******************************************************************
        function [QPpath,obj] = Gen_2Channel_QPtiff(obj,ImageFilterIndex,New_im_size,maskimagepath,Cindex,Cname)
            
            P = strsplit(obj.Filename,filesep) ;
            P{end} = ['Result_output'] ;
            P = join(P,filesep) ;
            P = P{1} ;
            if ~exist(P,'dir')
                mkdir(P)
            end
            obj.Output_path{ImageFilterIndex} = [P filesep obj.MetaData.SlideID{1} '_' obj.Filters.Name{ImageFilterIndex} '_2channels.qptiff'];
            QPpath =  obj.Output_path{ImageFilterIndex};
            write_new_QPTIF(obj,New_im_size,obj.Output_path{ImageFilterIndex},maskimagepath,Cindex,Cname)  
        end
        
        
        %%
        function MarkerPanel = filter2marker(obj,Stainingkit,filterslist)
            % define the list of antibodies and marker based on the staining kit used:
            %list of Ultivue KITS: Stainingkit=
            %'PD-L1'
            %'PD-1'
            %'T-act'
            %'APC'
            %others
            %list of filters: filters= ( filters list is input from polaris metadata:
            %1 is DAPI
            %2 is FITC
            %3 is Cy3
            %3 is TRITC
            %4 is Texas Red
            %4 is Cy5
            %5 is Cy7
            
            switch lower(Stainingkit)
                case{'pd-l1','pdl1'}
                    MarkerList ={'DNA', 'CD8', 'CD68', 'PD-L1','panCK-SOX10'};
                case{'pd-1','pd1'}
                    MarkerList ={'DNA', 'CD3', 'CD45RO', 'PD-1','panCK-SOX10'};
                case{'apc'}
                    MarkerList ={'DNA', 'CD11c', 'CD20', 'CD68-CD163','MHC-II'};
                case{'t-act','tact'}
                    MarkerList ={'DNA', 'CD3', 'Granzyme-B', 'Ki67','panCK-SOX10'};
                case{'h&e','he'}
                    MarkerList ={'H-E', ' ', ' ', ' ',' '};
                case {'default'}
                    MarkerList ={'Channel_1', 'Channel_2', 'Channel_3', 'Channel_4','Channel_5'};
                otherwise
                    MarkerList ={'DNA', ' ', ' ', ' ',' '};
                    disp('Unknown kit')
            end
            
            for i = 1:numel(filterslist)
                switch lower(filterslist{i})
                    case 'dapi'
                        MarkerPanel{i} = MarkerList{1} ;
                    case 'fitc'
                        MarkerPanel{i} = MarkerList{2} ;
                    case {'tritc','cy3'}
                        MarkerPanel{i} = MarkerList{3} ;
                    case {'texas red','cy5'}
                        MarkerPanel{i} = MarkerList{4} ;
                    case {'cy7'}
                        MarkerPanel{i} = MarkerList{5} ;
                    otherwise
                        %                         disp('unknown filter');
                        %                         MarkerPanel{i} = ' ' ;
                        if ((contains(lower(filterslist{i}),'he') ||  contains(lower(filterslist{i}),'h-e')) && numel(filterslist)==1)
                            %disp('H&E')
                            MarkerPanel{i} = 'he' ;
                        else
                            %disp('unknown filter');
                            MarkerPanel{i} = ' ' ;
                        end
                end
            end
            
            
        end
        
        
        %% MISC  basic FUNCTIONS
        
        % READ FULL IMAGE ( 1 page )
        % read a full channel image must specify index:
        function result = read(obj,RATIOscale)
            %result = imread(obj.Filename,'Index',ImageFilterIndex);
           
            [tmppath,MagnificationIndex,filesize] = createTif(obj,RATIOscale) ;
            %  tic
            %  RATIOscale = 4 ;
            Wd =  obj.ImSize(2)/ RATIOscale;
            Hd =  obj.ImSize(1) /  RATIOscale;
            Magnification = str2double(obj.MetaData.Magnification) / RATIOscale ;
            
%             obj.unloadLib()
%             obj.loadCoreLib()
%             obj.loadParalellLib()
            fun = @(block_struct) READ_KFBIO_STREAM(block_struct,obj.Filename,Magnification) ;
         
            result = blockproc(tmppath,[256 256],fun,...
                'PadPartialBlocks',false,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true...
                ) ;
        end
        
        % potential faster image reader?
        function result = block_read(obj,ImageFilterIndex)
            fun = @(block_struct) block_imread(obj.Filename,block_struct,ImageFilterIndex) ;
            result= blockproc(obj.Tmp_path,[bestblk(obj.ImSize,16384)],fun,...
                'PadPartialBlocks',true,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true)    ;
        end
        
        % potential faster image reader?
        function result = block_read_extTif(obj,pathtoTif)
            fun = @(block_struct) block_imread(pathtoTif,block_struct,1) ;
            result= blockproc(obj.Tmp_path,[bestblk(obj.ImSize,16384)],fun,...
                'PadPartialBlocks',true,'BorderSize',[0 0],...
                'DisplayWaitbar',false,'UseParallel',true)    ;
        end
        
        
        
        % simple resize of an input image
        function result = resize(obj,ImageFilterIndex,resizefactor)
            result = imresize(imread(obj.Filename,'Index',ImageFilterIndex),resizefactor);
        end
        
        
        function result = readRegion(obj,start,count,ImageFilterIndex)
            result = imread(obj.Filename,'Index',ImageFilterIndex,...
                'Info',obj.Info,'PixelRegion', ...
                {[start(1), start(1) + count(1) - 1], ...
                [start(2), start(2) + count(2) - 1]});
        end
        
        function result = resizeRegion(obj,start,count,ImageFilterIndex)
            result = imread(obj.Filename,'Index',ImageFilterIndex,...
                'Info',obj.Info,'PixelRegion', ...
                {[start(1),step, start(1) + count(1) - 1], ...
                [start(2),step, start(2) + count(2) - 1]});
        end
        
        
        function obj = Reinitialize_paths(obj)
            % reinitilaize path if exist ?
            try
                Rootpath = strsplit(obj.Filename,filesep);
                Rootpath = join([Rootpath(1:end-1)],filesep) ;
                GDS = imageDatastore(Rootpath,'IncludeSubfolders',true,'LabelSource','foldernames') ;
                
                K = GDS.Files(contains(string(GDS.Labels),'Channels'));
                % reorder by filtersname
                for i = 1:numel(K)
                    obj.Channels_path{i} = K{contains(K,obj.Filters.Name{i})};
                end
                
                K = GDS.Files(contains(string(GDS.Labels),'Analysis_'));
                % reorder by filtersname
                for i = 1:numel(K)
                    obj.Analysis_path{i} = K{contains(K,obj.Filters.Name{i})};
                end
                
                
                for i = 1:numel(obj.Filters.Name)
                    K = GDS.Files(contains(string((GDS.Labels)),obj.Filters.Name{i})) ;
                    if ~isempty(K)
                        K = K(1) ;
                        K =  strsplit(K{1},filesep);
                        K =  join([K(1:end-1)],filesep) ;
                        obj.Patches_path{i} = K{1} ;
                    else
                        obj.Patches_path{i} = [] ;
                    end
                end
            catch
                %disp('failed') ;
            end
            
        end
        
        
        
        
        
        
        % *************************************************************************
        % ******************************CLOSE OBJECT ******************************
        % *************************************************************************
        function close(obj)
            obj.Filename = [] ;
            obj.Info = [] ;
            obj.MetaData = [] ;
            obj.Indexes = [];
            obj.ImSize = [] ;
            obj.Filters= [] ;
            obj.ThumbnailImage = [] ;
            obj.LabelImage = [] ;
            obj.OverviewImage = [] ;
        end
        
    end
    
end












% *************************************************************************
% ******************************TEMPLATE***********************************
% *************************************************************************




