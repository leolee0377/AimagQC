#ifndef CTESTCLASS_H
#define CTESTCLASS_H
#endif
#if defined _WIN32
#define LIBHELLO_API __declspec(dllexport)
#define STDCALL      __stdcall 
#else
    #define LIBHELLO_API
	#define STDCALL
#endif

typedef void                *LPVOID;
typedef signed int          KF_INT32;
typedef long long           LPARAM;
typedef struct ImageInfoStruct
{
	LPARAM DataFilePTR;
}ImageInfoStruct;
//#include "DLLDef.h"
//#include "ImageOperationManager.h"
//class DLLinterface
//{
//public:
//    DLLinterface();
//};

//Open slide file
LIBHELLO_API bool STDCALL InitImageFileFunc( ImageInfoStruct* sImageInfo, const char* Path );
//Close slide file
LIBHELLO_API bool STDCALL  UnInitImageFileFunc( ImageInfoStruct*  sImageInfo );
//Get image stream length
LIBHELLO_API bool STDCALL GetImageStreamSize(ImageInfoStruct sImageInfo, float scale, KF_INT32 x, KF_INT32 y, KF_INT32* size);
//Get image stream by size
LIBHELLO_API bool STDCALL GetImageStreamBySize(ImageInfoStruct sImageInfo, float scale, KF_INT32 x, KF_INT32 y, KF_INT32 size, unsigned char* buffer);
//Get image stream
//LIBHELLO_API unsigned char*  STDCALL GetImageStreamFunc( ImageInfoStruct  sImageInfo, float fScale, KF_INT32 nImagePosX, KF_INT32 nImagePosY, KF_INT32*  nDataLength, unsigned char** ImageStream );
//Delete image stream data
//LIBHELLO_API bool STDCALL  DeleteImageDataFunc( LPVOID pImageData );
//Get slide file header information
#ifndef WIN32
LIBHELLO_API bool STDCALL GetHeaderInfoFunc( ImageInfoStruct  sImageInfo,
                                                                    KF_INT32*	 khiImageHeight,
                                                                    KF_INT32*	 khiImageWidth,
                                                                    KF_INT32*	 khiScanScale,
                                                                    float*	 khiSpendTime,
                                                                    double*	 khiScanTime,
                                                                    float*	 khiImageCapRes,
                                                                    KF_INT32*    khiImageBlockSize);
#else
LIBHELLO_API bool STDCALL GetHeaderInfoFunc( ImageInfoStruct sImageInfo,
                                                                    KF_INT32*	 khiImageHeight,
                                                                    KF_INT32*	 khiImageWidth,
                                                                    KF_INT32*	 khiScanScale,
                                                                    float*	 khiSpendTime,
                                                                    double*	 khiScanTime,
                                                                    float*	 khiImageCapRes,
                                                                    KF_INT32*     khiImageBlockSize);
#endif

//Get thumbnail information
//#ifndef WIN32
//LIBHELLO_API bool STDCALL  GetThumnailImageFunc( ImageInfoStruct  sImageInfo, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nThumWidth, KF_INT32  nThumHeght );
//#else
//LIBHELLO_API bool STDCALL  GetThumnailImageFunc( ImageInfoStruct sImageInfo, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nThumWidth, KF_INT32  nThumHeght );
//#endif

LIBHELLO_API bool STDCALL GetThumbnailSize(ImageInfoStruct imageStruct, KF_INT32* size);
LIBHELLO_API bool STDCALL GetThumbnailBySize(ImageInfoStruct imageStruct, unsigned char* data, KF_INT32* width, KF_INT32* height, KF_INT32 size);

//Get preview information
//#ifndef WIN32
//LIBHELLO_API bool STDCALL GetPriviewInfoFunc( ImageInfoStruct  sImageInfo, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nPriviewWidth, KF_INT32  nPriviewHeight );
//#else
//LIBHELLO_API bool STDCALL GetPriviewInfoFunc( ImageInfoStruct sImageInfo, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nPriviewWidth, KF_INT32  nPriviewHeight );
//#endif

LIBHELLO_API bool STDCALL GetPreviewSize(ImageInfoStruct imageStruct, KF_INT32* size);
LIBHELLO_API bool STDCALL GetPreviewBySize(ImageInfoStruct imageStruct, unsigned char* data, KF_INT32* width, KF_INT32* height, KF_INT32 size);

//Get label information
//#ifndef WIN32
//LIBHELLO_API bool STDCALL GetLableInfoFunc( ImageInfoStruct  sImageInfo, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nLabelWidth, KF_INT32  nLabelHeight );
//#else
//LIBHELLO_API bool STDCALL GetLableInfoFunc( ImageInfoStruct sImageInfo, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nLabelWidth, KF_INT32  nLabelHeight );
//#endif

LIBHELLO_API bool STDCALL GetLabelSize(ImageInfoStruct imageStruct, KF_INT32* size);
LIBHELLO_API bool STDCALL GetLabelBySize(ImageInfoStruct imageStruct, unsigned char* data, KF_INT32* width, KF_INT32* height, KF_INT32 size);

//Get thumbnail information
LIBHELLO_API bool STDCALL GetThumnailImagePathFunc( const char* szFilePath, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nThumWidth, KF_INT32  nThumHeght );
//Get preview information
LIBHELLO_API bool STDCALL GetPriviewInfoPathFunc( const char* szFilePath, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nPriviewWidth, KF_INT32  nPriviewHeight );
//Get label information
LIBHELLO_API bool STDCALL GetLableInfoPathFunc( const char* szFilePath, unsigned char** ImageData, KF_INT32*  nDataLength, KF_INT32  nLabelWidth, KF_INT32  nLabelHeight );



