//
//  DOPScrollableActionSheet.h
//  DOPScrollableActionSheet
//
//  Created by weizhou on 12/27/14.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class DOPAction;

@interface DOPScrollableActionSheet : UIView


- (instancetype)initWithTitle:(NSString *)title
                      actions:(NSArray *)actions;

//always show in a new window
- (void)show;
- (void)dismiss;
@end

#pragma mark - DOPAction interface
@interface DOPAction : NSObject

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *actionName;
@property (nonatomic, copy) void(^handler)(void);

- (instancetype)initWithName:(NSString *)name
                    iconName:(NSString *)iconName
                     handler:(void(^)(void))handler;

@end