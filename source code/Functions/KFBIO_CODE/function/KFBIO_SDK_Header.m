function [methodinfo,structs,enuminfo,ThunkLibName]=KFBIO_SDK_Header
%KFBIO_SDK_HEADER Create structures to define interfaces found in 'ImageOperationLib'.

%This function was generated by loadlibrary.m parser version  on Wed Jun 10 14:29:25 2020
%perl options:'ImageOperationLib.i -outfile=KFBIO_SDK_Header.m -thunkfile=lib_thunk_pcwin64.c -header=ImageOperationLib.h'
ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.
structs=[];enuminfo=[];fcnNum=1;
fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival,'thunkname', ival);
MfilePath=fileparts(mfilename('fullpath'));
ThunkLibName=fullfile(MfilePath,'lib_thunk_pcwin64');
%  bool __stdcall InitImageFileFunc ( ImageInfoStruct * sImageInfo , const char * Path ); 
fcns.thunkname{fcnNum}='boolvoidPtrcstringThunk';fcns.name{fcnNum}='InitImageFileFunc'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStructPtr', 'cstring'};fcnNum=fcnNum+1;
%  bool __stdcall UnInitImageFileFunc ( ImageInfoStruct * sImageInfo ); 
fcns.thunkname{fcnNum}='boolvoidPtrThunk';fcns.name{fcnNum}='UnInitImageFileFunc'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStructPtr'};fcnNum=fcnNum+1;
%  bool __stdcall GetImageStreamSize ( ImageInfoStruct sImageInfo , float scale , KF_INT32 x , KF_INT32 y , KF_INT32 * size ); 
fcns.thunkname{fcnNum}='boolImageInfoStructfloatint32int32voidPtrThunk';fcns.name{fcnNum}='GetImageStreamSize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'single', 'int32', 'int32', 'int32Ptr'};fcnNum=fcnNum+1;
%  bool __stdcall GetImageStreamBySize ( ImageInfoStruct sImageInfo , float scale , KF_INT32 x , KF_INT32 y , KF_INT32 size , unsigned char * buffer ); 
fcns.thunkname{fcnNum}='boolImageInfoStructfloatint32int32int32voidPtrThunk';fcns.name{fcnNum}='GetImageStreamBySize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'single', 'int32', 'int32', 'int32', 'uint8Ptr'};fcnNum=fcnNum+1;
%  bool __stdcall GetHeaderInfoFunc ( ImageInfoStruct sImageInfo , KF_INT32 * khiImageHeight , KF_INT32 * khiImageWidth , KF_INT32 * khiScanScale , float * khiSpendTime , double * khiScanTime , float * khiImageCapRes , KF_INT32 * khiImageBlockSize ); 
fcns.thunkname{fcnNum}='boolImageInfoStructvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrThunk';fcns.name{fcnNum}='GetHeaderInfoFunc'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'int32Ptr', 'int32Ptr', 'int32Ptr', 'singlePtr', 'doublePtr', 'singlePtr', 'int32Ptr'};fcnNum=fcnNum+1;
%  bool __stdcall GetThumbnailSize ( ImageInfoStruct imageStruct , KF_INT32 * size ); 
fcns.thunkname{fcnNum}='boolImageInfoStructvoidPtrThunk';fcns.name{fcnNum}='GetThumbnailSize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'int32Ptr'};fcnNum=fcnNum+1;
%  bool __stdcall GetThumbnailBySize ( ImageInfoStruct imageStruct , unsigned char * data , KF_INT32 * width , KF_INT32 * height , KF_INT32 size ); 
fcns.thunkname{fcnNum}='boolImageInfoStructvoidPtrvoidPtrvoidPtrint32Thunk';fcns.name{fcnNum}='GetThumbnailBySize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'uint8Ptr', 'int32Ptr', 'int32Ptr', 'int32'};fcnNum=fcnNum+1;
%  bool __stdcall GetPreviewSize ( ImageInfoStruct imageStruct , KF_INT32 * size ); 
fcns.thunkname{fcnNum}='boolImageInfoStructvoidPtrThunk';fcns.name{fcnNum}='GetPreviewSize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'int32Ptr'};fcnNum=fcnNum+1;
%  bool __stdcall GetPreviewBySize ( ImageInfoStruct imageStruct , unsigned char * data , KF_INT32 * width , KF_INT32 * height , KF_INT32 size ); 
fcns.thunkname{fcnNum}='boolImageInfoStructvoidPtrvoidPtrvoidPtrint32Thunk';fcns.name{fcnNum}='GetPreviewBySize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'uint8Ptr', 'int32Ptr', 'int32Ptr', 'int32'};fcnNum=fcnNum+1;
%  bool __stdcall GetLabelSize ( ImageInfoStruct imageStruct , KF_INT32 * size ); 
fcns.thunkname{fcnNum}='boolImageInfoStructvoidPtrThunk';fcns.name{fcnNum}='GetLabelSize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'int32Ptr'};fcnNum=fcnNum+1;
%  bool __stdcall GetLabelBySize ( ImageInfoStruct imageStruct , unsigned char * data , KF_INT32 * width , KF_INT32 * height , KF_INT32 size ); 
fcns.thunkname{fcnNum}='boolImageInfoStructvoidPtrvoidPtrvoidPtrint32Thunk';fcns.name{fcnNum}='GetLabelBySize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'ImageInfoStruct', 'uint8Ptr', 'int32Ptr', 'int32Ptr', 'int32'};fcnNum=fcnNum+1;
%  bool __stdcall GetThumnailImagePathFunc ( const char * szFilePath , unsigned char ** ImageData , KF_INT32 * nDataLength , KF_INT32 nThumWidth , KF_INT32 nThumHeght ); 
fcns.thunkname{fcnNum}='boolcstringvoidPtrvoidPtrint32int32Thunk';fcns.name{fcnNum}='GetThumnailImagePathFunc'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'cstring', 'uint8PtrPtr', 'int32Ptr', 'int32', 'int32'};fcnNum=fcnNum+1;
%  bool __stdcall GetPriviewInfoPathFunc ( const char * szFilePath , unsigned char ** ImageData , KF_INT32 * nDataLength , KF_INT32 nPriviewWidth , KF_INT32 nPriviewHeight ); 
fcns.thunkname{fcnNum}='boolcstringvoidPtrvoidPtrint32int32Thunk';fcns.name{fcnNum}='GetPriviewInfoPathFunc'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'cstring', 'uint8PtrPtr', 'int32Ptr', 'int32', 'int32'};fcnNum=fcnNum+1;
%  bool __stdcall GetLableInfoPathFunc ( const char * szFilePath , unsigned char ** ImageData , KF_INT32 * nDataLength , KF_INT32 nLabelWidth , KF_INT32 nLabelHeight ); 
fcns.thunkname{fcnNum}='boolcstringvoidPtrvoidPtrint32int32Thunk';fcns.name{fcnNum}='GetLableInfoPathFunc'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='bool'; fcns.RHS{fcnNum}={'cstring', 'uint8PtrPtr', 'int32Ptr', 'int32', 'int32'};fcnNum=fcnNum+1;
structs.ImageInfoStruct.members=struct('DataFilePTR', 'int64');
methodinfo=fcns;