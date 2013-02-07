#import "FlashRuntimeExtensions.h"

FREContext eventContext;

#pragma mark - internal

void threadedBlackAndWhite( FREBitmapData *bmd, NSUInteger width, NSUInteger height ) {
    
    int i;
    int j;
    
    for( j = 0; j < 50; ++j ) {
        
        int byteIndex = 0;
        int len = width * height;
        unsigned char *bmdPixels = (unsigned char*)bmd->bits32;
        
        for( i = 0; i < len; ++i ) {
            
            // Apple endianess stores ARGB as BGRA.
            int avg = ( bmdPixels[ byteIndex + 0 ] + bmdPixels[ byteIndex + 1 ] + bmdPixels[ byteIndex + 2 ] ) / 3;
            
            bmdPixels[ byteIndex + 0 ] = (unsigned char)avg;
            bmdPixels[ byteIndex + 1 ] = (unsigned char)avg;
            bmdPixels[ byteIndex + 2 ] = (unsigned char)avg;
            
            byteIndex += 4;
        }
    }
    
}

#pragma mark - interface

FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    eventContext = ctx;
    return NULL;
}

FREObject filterBlackAndWhite(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    // Get bitmap data parameter.
    FREBitmapData bmd;
    FREAcquireBitmapData( argv[ 0 ], &bmd );
    
    NSUInteger width = bmd.width;
    NSUInteger height = bmd.height;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        threadedBlackAndWhite( &bmd, width, height );
    });
    
    // Tell Flash which region of the bitmapData changes (all of it here)
    FREInvalidateBitmapDataRect( argv[0], 0, 0, width, height );
    
    // Release our control over the bitmapData
    FREReleaseBitmapData( argv[0] );
    
    return NULL;
}

#pragma mark - bootstrap

void ImageProcessingExtensionContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    *numFunctionsToTest = 2;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "init";
    func[0].functionData = NULL;
    func[0].function = &init;
    
    func[1].name = (const uint8_t*) "filterBlackAndWhite";
    func[1].functionData = NULL;
    func[1].function = &filterBlackAndWhite;
    
    *functionsToSet = func;
}

void ImageProcessingExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ImageProcessingExtensionContextInitializer;
}