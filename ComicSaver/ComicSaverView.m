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
        NSString *localPath = @"/Documents/Shared/Comics/Letter 44/letter44_vol1_1412097863.pdf";
        NSString *docPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), localPath];
        document = getPDFDocument (docPath);
        numberOfPages = CGPDFDocumentGetNumberOfPages (document);
        currentPage = 1;
        
        pages = [[NSMutableArray alloc] init];
        
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)startAnimation
{
    
    currentPage = 1;
    offset = 0.0;
    
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
    
    for(id pageRef in pages) CGPDFPageRelease((CGPDFPageRef)pageRef);
    CGPDFDocumentRelease (document);
}

- (void)drawRect:(NSRect)rect
{
    if(!numberOfPages) return;
    
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    //printf("display size: [%f,%f]\n", rect.size.width, rect.size.height);
    
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
//    CGContextFillRect(context, rect);
    
    
    CGFloat pageOffset = offset;
    long visiblePage = 0;
    while(numberOfPages > (currentPage + visiblePage) && pageOffset < rect.size.width) {
        CGPDFPageRef page = nil;
        
        //        printf("page %lu/%lu\n", visiblePage, [pages count]);
        
        if(visiblePage < [pages count])
            page = (__bridge CGPDFPageRef)([pages objectAtIndex:visiblePage]);
        
        if(page == nil) {
            printf("adding page %lu\n", currentPage + (visiblePage));
            page = CGPDFDocumentGetPage (document, currentPage + visiblePage);
            [pages addObject:(__bridge id)(page)];
        }
        
        CGContextSaveGState(context);
        CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
        
        CGContextTranslateCTM(context, pageOffset, 0.0);
        CGContextScaleCTM(context, 1.0, 1.0);
        
        CGFloat xScale = rect.size.width / cropBox.size.width;
        CGFloat yScale = rect.size.height / cropBox.size.height;
        CGFloat scaleToApply = xScale < yScale ? xScale : yScale;
        CGContextScaleCTM(context, scaleToApply, scaleToApply);
        
        if(pageOffset + (cropBox.size.width * scaleToApply) <= 0) {
            printf("removing page\n");
            CGPDFPageRelease((CGPDFPageRef)[pages objectAtIndex:0]);
            [pages removeObjectAtIndex:0];
            currentPage += 1;
            pageOffset = offset = pageOffset + (cropBox.size.width * scaleToApply);
        } else {
            CGContextDrawPDFPage (context, page);
            pageOffset += cropBox.size.width * scaleToApply;
            visiblePage ++;
        }
        CGContextRestoreGState(context);
        
    }
    
    offset -= 3;
    
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

CGPDFDocumentRef getPDFDocument (NSString* filename)
{
    CFStringRef path;
    CFURLRef url;
    CGPDFDocumentRef document;
    
    path = CFStringCreateWithCString (NULL, [filename UTF8String], kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    document = CGPDFDocumentCreateWithURL (url);
    CFRelease(url);
    
    return document;
}


NSArray* getListOfPDFs(NSString *sourcePath)
{
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath error:NULL];
    
    NSMutableArray *pdfFiles = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"pdf"]) {
            [pdfFiles addObject:[sourcePath stringByAppendingPathComponent:filename]];
        }
    }];
    return pdfFiles;
}

@end