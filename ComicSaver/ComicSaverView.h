//
//  ComicSaverView.h
//  ComicSaver
//
//  Created by Matthias Jugel on 24/01/15.
//  Copyright (c) 2015 Matthias Jugel. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface ComicSaverView : ScreenSaverView
{
    CGPDFDocumentRef document;
    CGPDFPageRef page;
}

@end
