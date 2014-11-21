//
//  NSDateFormatter+SpokenTime.h
//  SpeakingWatch
//
//  Created by Thomas Duplomb on 21/11/14.
//  Copyright (c) 2014 Thomas Duplomb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (NSDateFormatter)

- (NSString *)spokenStringFromDate:(NSDate*)date;

@end
