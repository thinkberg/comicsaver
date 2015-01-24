//
//  ComicSaverView.m
//  ComicSaver
//
//  Created by Matthias Jugel on 24/01/15.
//  Copyright (c) 2015 Matthias Jugel. All rights reserved.
//

#import "ComicSaverView.h"

@implementation ComicSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    
    if (self) {
        //        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)startAnimation
{
    document = MyGetPDFDocumentRef ("/Users/leo/Documents/Shared/Comics/Letter 44/letter44_vol1_1412097863.pdf");
    long numberOfPages = CGPDFDocumentGetNumberOfPages (document);
    page = CGPDFDocumentGetPage (document, (random()%numberOfPages)+1);
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
    CGPDFDocumentRelease (document);
}

- (void)drawRect:(NSRect)rect
{
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGRect clip = CGContextGetClipBoundingBox(context);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, clip);
    CGContextTranslateCTM(context, 0.0, -(clip.size.height + cropBox.size.height));
    CGContextScaleCTM(context, 1.0, 1.0);
    
    CGFloat xScale = clip.size.width / cropBox.size.width;
    CGFloat yScale = clip.size.height / cropBox.size.height;
    CGFloat scaleToApply = xScale < yScale ? yScale : xScale;
    CGContextConcatCTM(context, CGAffineTransformMakeScale(scaleToApply, scaleToApply));
    //    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, clip, 0, true));
    CGContextDrawPDFPage (context, page);
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

CGPDFDocumentRef MyGetPDFDocumentRef (const char *filename)
{
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    size_t count;
    
    path = CFStringCreateWithCString (NULL, filename,
                                      kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path, // 1
                                         kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);// 2
    CFRelease(url);
    count = CGPDFDocumentGetNumberOfPages (document);// 3
    if (count == 0) {
        printf("`%s' needs at least one page!", filename);
        return NULL;
    }
    return document;
}

@end