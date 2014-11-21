#import "SWTimeView.h"
#import "NSDateFormatter+SpokenTime.h"

static NSString *kFontName = @"FuturistFixedWidth-Regular";
static NSString *kTimeText =
@"ITLISASTIMEACQUARTERDCTWENTYFIVEXHALFBTENFTOPASTERUNINEONESIXTHREEFOURFIVETWOEIGHTELEVENSEVENTWELVETENSEOCLOCK";

void registerFontWithPath(NSString *fontPath)
{
    NSData *inData = [NSData dataWithContentsOfFile:fontPath];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);
}

@interface SWTimeView ()
@property (nonatomic, strong) NSString *spokenDate;
@property (nonatomic, strong) NSAttributedString *drawingString;

@property (nonatomic, strong) NSColor *foregroundColor;
@property (nonatomic, strong) NSColor *highlightColor;
@end

@implementation SWTimeView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

-(instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    NSString *fontPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"futrfw" ofType:@"ttf"];

    registerFontWithPath(fontPath);
    self.foregroundColor = [NSColor colorWithWhite:0.3 alpha:1.0];
    self.highlightColor = [NSColor colorWithWhite:0.95 alpha:1.0];
    self.drawingString = [self configureStringForDisplay:kTimeText];
    self.spokenDate = [[[NSDateFormatter alloc] init] spokenStringFromDate:[NSDate date]];
}

- (NSAttributedString*)configureStringForDisplay:(NSString*)string
{
    CGFloat fontSize = MIN([self bounds].size.height, [self bounds].size.width) / 20.f;
    CGFloat spacing = fontSize * (4.f / 5.f);
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSFont *font = [NSFont fontWithName:kFontName size:fontSize];
    
    paragraphStyle.lineSpacing = spacing;
    paragraphStyle.alignment = NSCenterTextAlignment;
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: self.foregroundColor,
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSKernAttributeName: @(spacing),
                                 NSFontAttributeName: font
                                 };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    return attrString;
}

- (NSAttributedString*)highlightWords:(NSAttributedString*)attrString fromString:(NSString*)string
{
    NSArray *words = [string componentsSeparatedByString:@" "];
    NSMutableAttributedString *retString = [attrString mutableCopy];
    NSDictionary *highlightAttributes = @{NSForegroundColorAttributeName: self.highlightColor};
    NSInteger lastHighlightedIndex = 0;
    
    for (NSString *word in words) {
        NSRange subRange = NSMakeRange(lastHighlightedIndex, [retString length] - lastHighlightedIndex);
        NSRange range =
        [[retString string]
         rangeOfString:word options:NSCaseInsensitiveSearch
         range:subRange];
        
        [retString addAttributes:highlightAttributes range:range];
        lastHighlightedIndex = range.location + range.length;
    }
    return [retString copy];
}

- (void)animateOneFrame
{
    NSString *spokenNowDate = [[[NSDateFormatter alloc] init] spokenStringFromDate:[NSDate date]];
    if (NO == [spokenNowDate isEqualToString:self.spokenDate]) {
        self.spokenDate = spokenNowDate;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
//    [[NSColor greenColor] set];
//    [NSBezierPath fillRect:[self bounds]];
     CGContextRef context =
         (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    // Set the text matrix.
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();
    
    // In this simple example, initialize a rectangular path.
    CGPathAddRect(path, NULL, [self bounds]);
    
    CFAttributedStringRef attrString =
    CFBridgingRetain([self highlightWords:self.drawingString fromString:self.spokenDate]);
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, 0), path, NULL);
    
    // Draw the specified frame in the given context.
    CTFrameDraw(frame, context);
    
    // Release the objects we used.
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
}

@end
