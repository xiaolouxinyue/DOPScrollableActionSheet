//
//  DOPScrollableActionSheet.m
//  DOPScrollableActionSheet
//
//  Created by weizhou on 12/27/14.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import "DOPScrollableActionSheet.h"

#define HexColor(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0]

#define maxRowCount             2.0

@interface DOPScrollableActionSheet ()<UIScrollViewDelegate>
{
    NSInteger       columnCount;
    NSInteger       pageCount;
    CGFloat         horizontalMargin, verticalMargin, headerHeightMargin,
                    iconHeightMargin, iconWidthMargin,
                    titleHeightMargin, titleWidthMargin,
                    itemWidthMargin, itemHeightMargin,
                    buttonHeightMargin;
}

@property (nonatomic, assign) CGRect         screenRect;
@property (nonatomic, strong) UIWindow       *window;
@property (nonatomic, strong) UIView         *dimBackground;
@property (nonatomic, strong) UIPageControl  *pageControl;
@property (nonatomic, strong) UIScrollView   *rowContainer;
@property (nonatomic, copy  ) NSArray        *actions;
@property (nonatomic, copy  ) NSString       *title;

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *handlers;
@property (nonatomic, copy) void(^dismissHandler)(void);

@end

@implementation DOPScrollableActionSheet


- (void)initMargins {
    
    // Defaults

    if ([UIScreen mainScreen].bounds.size.height == 480) {
        // iPhone 3.5 inch
        horizontalMargin        = 15.0;
        verticalMargin          = 20.0;
        headerHeightMargin      = 28.0;
        
        iconWidthMargin         = 50.0;
        iconHeightMargin        = 50.0;
        titleWidthMargin        = 60.0;
        titleHeightMargin       = 20.0;
        itemHeightMargin        = (iconHeightMargin + titleHeightMargin);
        itemWidthMargin         = MAX(iconWidthMargin, titleWidthMargin);
        buttonHeightMargin      = 44.0;
        
    }else if ([UIScreen mainScreen].bounds.size.height == 568) {
        // iPhone 4.0 inch
        horizontalMargin        = 15.0;
        verticalMargin          = 15.0;
        headerHeightMargin      = 28.0;
        
        iconWidthMargin         = 50.0;
        iconHeightMargin        = 50.0;
        titleWidthMargin        = 60.0;
        titleHeightMargin       = 20.0;
        itemHeightMargin        = (iconHeightMargin + titleHeightMargin);
        itemWidthMargin         = MAX(iconWidthMargin, titleWidthMargin);
        buttonHeightMargin      = 44.0;
        
    } else if ([UIScreen mainScreen].bounds.size.height == 667){
        // iPhone 4.7 inch up
        
        horizontalMargin        = 18.0;
        verticalMargin          = 18.0;
        headerHeightMargin      = 28.0;
        
        iconWidthMargin         = 50.0;
        iconHeightMargin        = 50.0;
        titleWidthMargin        = 70.0;
        titleHeightMargin       = 20.0;
        itemHeightMargin        = (iconHeightMargin + titleHeightMargin);
        itemWidthMargin         = MAX(iconWidthMargin, titleWidthMargin);
        buttonHeightMargin      = 44.0;
        
    }else {
        // iPhone 5.5 inch up
        horizontalMargin        = 20.0;
        verticalMargin          = 20.0;
        headerHeightMargin      = 28.0;
        
        iconWidthMargin         = 80.0;
        iconHeightMargin        = 60.0;
        titleWidthMargin        = 80.0;
        titleHeightMargin       = 20.0;
        itemHeightMargin        = (iconHeightMargin + titleHeightMargin);
        itemWidthMargin         = MAX(iconWidthMargin, titleWidthMargin);
        buttonHeightMargin      = 54.0;
    }
}


- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions{
    self = [super init];
    if (self) {
        
        [self initMargins];
        _screenRect = [UIScreen mainScreen].bounds;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.5 &&
            UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            _screenRect = CGRectMake(0, 0, _screenRect.size.height, _screenRect.size.width);
        }
        _actions = actions;
        _title = title;
        
        columnCount = _screenRect.size.width / (itemWidthMargin + horizontalMargin);
        pageCount = ceil(actions.count /((float)columnCount * (float)maxRowCount));

        _buttons = [NSMutableArray array];
        _handlers = [NSMutableArray array];
        _dimBackground = [[UIView alloc] initWithFrame:_screenRect];
        _dimBackground.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_dimBackground addGestureRecognizer:gr];
        self.backgroundColor = HexColor(0xdfdfdf);
        
        /*calculate action sheet frame begin*/
        //row title screenwidth*40 without row title margin screenwidth*20
        //60*60 icon 60*30 icon name
        CGFloat height = 0.0;
        if ([_title isEqualToString:@""]) {
            height += verticalMargin;
        }else{
            height += headerHeightMargin;
        }
        
        NSInteger rows = ceil(actions.count /(float)columnCount);
        rows = rows < maxRowCount ? rows : maxRowCount;
        for (int i = 0; i < rows; i++) {
            height += itemHeightMargin;
        }
        
        height += verticalMargin;
        //cancel button screenwidth*60
        
        if (pageCount > 1) {
            height += verticalMargin;
        }
        height += verticalMargin / 2;//for sep
        height += buttonHeightMargin;
        /*calculation end*/
        self.frame = CGRectMake(0, _screenRect.size.height, _screenRect.size.width, height);
        
        
        CGFloat y = 0;
        //title
        if ([_title isEqualToString:@""]) {
            UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, verticalMargin)];
            marginView.backgroundColor = HexColor(0xd3d3d3);
            [self addSubview:marginView];
            y+=verticalMargin;
        } else {
            
            UIView *marginView = [[UIView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, headerHeightMargin)];
            marginView.backgroundColor = HexColor(0xd3d3d3);
            
            UILabel *rowTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, y, _screenRect.size.width, headerHeightMargin)];
            rowTitle.font = [UIFont systemFontOfSize:14.0];
            rowTitle.text = _title;
            rowTitle.textColor = HexColor(0x5f5f5f);
            rowTitle.textAlignment = NSTextAlignmentLeft;
            [marginView addSubview:rowTitle];
            
            [self addSubview:marginView];
            y+=headerHeightMargin;
        }
        
        CGFloat containerHeight = itemHeightMargin * rows + verticalMargin;
        self.rowContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width, containerHeight)];
        self.rowContainer.directionalLockEnabled = YES;
        self.rowContainer.showsHorizontalScrollIndicator = NO;
        self.rowContainer.showsVerticalScrollIndicator = NO;
        self.rowContainer.pagingEnabled = YES;
        self.rowContainer.delegate = self;
        self.rowContainer.contentSize = CGSizeMake(_screenRect.size.width * pageCount, containerHeight);
        [self addSubview:self.rowContainer];
        
        for (int index = 0; index < actions.count; index ++ ) {
            
            NSInteger curPage = 0;
            NSInteger curRow = 0;
            NSInteger curCol = 0;
            
            curPage = index / (maxRowCount * columnCount);
            curRow = (index - curPage * maxRowCount * columnCount) / columnCount;
            curCol = (index - curPage * maxRowCount * columnCount - curRow * columnCount);
//            NSLog(@"\n\n (%d, %d, %d)", curPage, curRow, curCol);
            
            CGFloat startX = (_screenRect.size.width - columnCount * (itemWidthMargin + horizontalMargin) + horizontalMargin) / 2;
            CGFloat x =  startX + _screenRect.size.width * curPage + (itemWidthMargin + horizontalMargin)*curCol;
            CGFloat y = (itemHeightMargin + verticalMargin / 2) * curRow + verticalMargin / 2;
            
            DOPAction *action = actions[index];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(x, y, iconWidthMargin, iconHeightMargin);
            [button setImage:[UIImage imageNamed:action.iconName] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(handlePress:) forControlEvents:UIControlEventTouchUpInside];
            [self.rowContainer addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, iconHeightMargin + y + 2, titleWidthMargin, titleHeightMargin)];
            label.text = action.actionName;
            label.font = [UIFont systemFontOfSize:13.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = HexColor(0x5f5f5f);
            [self.rowContainer addSubview:label];
            x = x + itemWidthMargin + horizontalMargin;
            
            
            button.center = CGPointMake(label.center.x, button.center.y);
            
            [_buttons addObject:button];
            [_handlers addObject:action.handler];

        }
        
        y+= itemHeightMargin * rows + verticalMargin ;
        
        if (pageCount > 1) {
            self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, y, _screenRect.size.width, verticalMargin)];
            self.pageControl.numberOfPages = pageCount;
            self.pageControl.currentPage = 0;
            self.pageControl.currentPageIndicatorTintColor = HexColor(0xd33a31);
            self.pageControl.pageIndicatorTintColor = HexColor(0xc4c4c4);
            [self addSubview:self.pageControl];
            y+= verticalMargin;
        }
        
        y+= verticalMargin / 2;
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, y, _screenRect.size.width,0.6)];
        separator.backgroundColor = HexColor(0xc1c1c1);
        [self addSubview:separator];
        
        UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, y, _screenRect.size.width, buttonHeightMargin)];
        [cancel setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        [cancel setTitleColor:HexColor(0x5f5f5f) forState:UIControlStateNormal];
        cancel.titleLabel.font = [UIFont systemFontOfSize:20];
        [self addSubview:cancel];
        [cancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)handlePress:(UIButton *)button {
    NSInteger index = [self.buttons indexOfObject:button];
    if (index != self.buttons.count-1) {
        void(^handler)(void) = self.handlers[index];
        handler();
    }
    [self dismiss];
}

- (void)show {
    self.window = [[UIWindow alloc] initWithFrame:self.screenRect];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = [UIViewController new];
    self.window.rootViewController.view.backgroundColor = [UIColor clearColor];
    
    [self.window.rootViewController.view addSubview:self.dimBackground];
    
    [self.window.rootViewController.view addSubview:self];
    
    self.window.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.dimBackground.backgroundColor = [UIColor blackColor];
        self.dimBackground.alpha = 0.5;
        self.frame = CGRectMake(0, self.screenRect.size.height-self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.dimBackground.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, self.screenRect.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        self.window = nil;
    }];
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([scrollView isEqual:self.rowContainer]){
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = scrollView.contentOffset.x / pageWidth;
        self.pageControl.currentPage = page;
    }
}

@end

@implementation DOPAction

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName handler:(void(^)(void))handler {
    self = [super init];
    if (self) {
        _actionName = name;
        _iconName = iconName;
        _handler = handler;
    }
    return self;
}

@end
