#import "SpeakingWatchView.h"
#import "SWTimeView.h"
#import "NSDateFormatter+SpokenTime.h"

@interface SpeakingWatchView ()
@property (nonatomic, strong) SWTimeView *timeView;
@end

NSRect squareInFrame(NSRect containerFrame, CGFloat scale)
{
    CGFloat side = MIN(containerFrame.size.width, containerFrame.size.height) * scale;
    CGFloat padding = (containerFrame.size.height - side) * (1/10.f);
    
    return NSMakeRect((containerFrame.size.width / 2) - (side / 2), containerFrame.size.height - side - padding,
                      side, side);
}

@implementation SpeakingWatchView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSColor *startingColor = [NSColor colorWithCalibratedWhite:0.03 alpha:1];
        NSColor *endingColor = [NSColor colorWithCalibratedWhite:0.0 alpha:1];
        
        self.background = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endingColor];
        self.timeView = [[SWTimeView alloc] initWithFrame:squareInFrame(self.frame, 2.f/3.f)];
        [self addSubview:self.timeView];
        [self setAnimationTimeInterval:1/2.f];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    [self.background drawInRect:[self bounds] angle:270.f]; // top to bottom
}

- (void)animateOneFrame
{
    [self.timeView animateOneFrame];
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
