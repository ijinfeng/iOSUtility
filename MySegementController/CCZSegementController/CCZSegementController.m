//
//  CCZSegementController.m
//  MySegementController
//
//  Created by 金峰 on 16/9/11.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import "CCZSegementController.h"


typedef void(^indexBlock)(NSInteger index);

@interface CCZSegementController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *containerView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIButton *selectedButton; /**< 当前被选中的按钮*/
@property (nonatomic, strong) UIView *indicateView;     /**< 指示杆*/
@property (nonatomic, assign) CGFloat indicateHeight;   /**< 指示杆高度*/
@property (nonatomic, assign) NSTimeInterval duration;  /**< 滑动时间*/
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat segementHeight;   /**< 头部segementView的高度*/
@property (nonatomic, assign) CGFloat buttonSpace;      /**< 按钮title到边的间距*/
@property (nonatomic, assign) CGFloat minItemSpace;     /**< 最小Item之间的间距*/
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *normalColor;     /**< 标题未被选中时的颜色*/
@property (nonatomic, copy)   indexBlock resultBlock;
@property (nonatomic, strong) NSMutableArray *widthArr; /**< 存放按钮的宽度*/
@end

@implementation CCZSegementController

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles {
    if (self = [super init]) {
        _titles = titles;
        _size = frame.size;
        self.view.frame = frame;
        [self segementBasicSetting];
        [self segementPageSetting];
        [self containerViewSetting];
    }
    return self;
}

+ (instancetype)segementControllerWithFrame:(CGRect)frame titles:(NSArray<NSString *> *)titles {
    return [[self alloc] initWithFrame:frame titles:titles];
}

- (void)segementBasicSetting {
    self.view.backgroundColor = [UIColor clearColor];
    _widthArr = [NSMutableArray array];
    _segementHeight = 44.;
    _minItemSpace = 20.;
    _segementTintColor = [UIColor blackColor];
    _normalColor = [UIColor lightGrayColor];
    _font = [UIFont systemFontOfSize:16];
    _buttonSpace = [self calculateSpace];
    _indicateHeight = 3.;
    _duration = .3;
}

- (void)segementPageSetting {
    _segementView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _size.width, _segementHeight)];
    _segementView.backgroundColor = [UIColor colorWithWhite:1. alpha:.5];
    _segementView.showsHorizontalScrollIndicator = NO;
    _segementView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_segementView];
    
    _indicateView = [[UIView alloc] init];
    _indicateView.backgroundColor = _segementTintColor;
    
    CGFloat item_x = 0;
    for (int i = 0; i < _titles.count; i++) {
        NSString *title = _titles[i];
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: _font}];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(item_x, 0, _buttonSpace * 2 + titleSize.width, _segementHeight);
        [button setTag:i];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:_normalColor forState:UIControlStateNormal];
        [button setTitleColor:_segementTintColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [_segementView addSubview:button];
        
        [_widthArr addObject:[NSNumber numberWithDouble:CGRectGetWidth(button.frame)]];
        item_x += _buttonSpace * 2 + titleSize.width;
        
        if (i == 0) {
            button.selected = YES;
            _selectedButton = button;
            
            // 添加指示杆
            _indicateView.frame = CGRectMake(_buttonSpace, _segementHeight - _indicateHeight, titleSize.width, _indicateHeight);
            [_segementView addSubview:_indicateView];
        }
    }
    
    self.segementView.contentSize = CGSizeMake(item_x, _segementHeight);
}

- (void)containerViewSetting {
    _containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _segementHeight, _size.width, _size.height - _segementHeight)];
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.showsVerticalScrollIndicator = NO;
    _containerView.showsHorizontalScrollIndicator = NO;
    _containerView.delegate = self;
    _containerView.pagingEnabled = YES;
    _containerView.bounces = NO;
    [self.view addSubview:_containerView];
}

- (CGFloat)calculateSpace {
    CGFloat space = 0.;
    CGFloat totalWidth = 0.;
    
    for (NSString *title in _titles) {
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : _font}];
        totalWidth += titleSize.width;
    }
    
    space = (_size.width - totalWidth) / _titles.count / 2;
    if (space > _minItemSpace / 2) {
        return space;
    } else {
        return _minItemSpace / 2;
    }
}

- (void)selectedAtIndex:(void (^)(NSInteger))indexBlock {
    if (indexBlock) {
        _resultBlock = indexBlock;
        _resultBlock([self selectedAtIndex]);
    }
}

#pragma mark -- 按钮方法

- (void)didClickButton:(UIButton *)button {
    if (button != _selectedButton) {
        button.selected = YES;
        _selectedButton.selected = !_selectedButton.selected;
        _selectedButton = button;
        
        [self scrollIndicateView];
        [self scrollSegementView];
    }
    
    if (_resultBlock) {
        _resultBlock(_selectedButton.tag);
    }
}

/**
 根据选中的按钮滑动指示杆
 */
- (void)scrollIndicateView {
    NSInteger index = [self selectedAtIndex];
    CGSize titleSize = [_selectedButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : _font}];
    [UIView animateWithDuration:_duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_style == CCZSegementStyleDefault) {
            _indicateView.frame = CGRectMake(CGRectGetMinX(_selectedButton.frame) + _buttonSpace, CGRectGetMinY(_indicateView.frame), titleSize.width, _indicateHeight);
        } else {
            _indicateView.frame = CGRectMake(CGRectGetMinX(_selectedButton.frame), CGRectGetMinY(_indicateView.frame), [self widthAtIndex:index], _indicateHeight);
        }
        
        [_containerView setContentOffset:CGPointMake(index * _size.width, 0)];
    } completion:^(BOOL finished) {
        
    }];
}

/**
 根据选中调整segementView的offset
 */
- (void)scrollSegementView {
    CGFloat selectedWidth = _selectedButton.frame.size.width;
    CGFloat offsetX = (_size.width - selectedWidth) / 2;
    
    if (_selectedButton.frame.origin.x <= _size.width / 2) {
        [_segementView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (CGRectGetMaxX(_selectedButton.frame) >= (_segementView.contentSize.width - _size.width / 2)) {
        [_segementView setContentOffset:CGPointMake(_segementView.contentSize.width - _size.width, 0) animated:YES];
    } else {
        [_segementView setContentOffset:CGPointMake(CGRectGetMinX(_selectedButton.frame) - offsetX, 0) animated:YES];
    }
}

#pragma mark -- index

- (NSInteger)selectedAtIndex {
    return _selectedButton.tag;
}

- (void)setSelectedItemAtIndex:(NSInteger)index {
    for (UIView *view in _segementView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag == index) {
            UIButton *button = (UIButton *)view;
            [self didClickButton:button];
        }
    }
}

- (CGFloat)widthAtIndex:(NSInteger)index {
    if (index < 0 || index > _titles.count - 1) {
        return .0;
    }
    return [[_widthArr objectAtIndex:index] doubleValue];
}

#pragma mark -- scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = round(scrollView.contentOffset.x / _size.width);
    [self setSelectedItemAtIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    
    NSInteger currentIndex = [self selectedAtIndex];
    
    // 当当前的偏移量大于被选中index的偏移量的时候，就是在右侧
    CGFloat offset; // 在同一侧的偏移量
    NSInteger buttonIndex = currentIndex;
    if (offsetX >= [self selectedAtIndex] * _size.width) {
        offset = offsetX - [self selectedAtIndex] * _size.width;
        buttonIndex += 1;
    } else {
        offset = [self selectedAtIndex] * _size.width - offsetX;
        buttonIndex -= 1;
        currentIndex -= 1;
    }
    
    CGFloat originMovedX = _style == CCZSegementStyleDefault? (CGRectGetMinX(_selectedButton.frame) + _buttonSpace) : CGRectGetMinX(_selectedButton.frame);
    CGFloat targetMovedWidth = [self widthAtIndex:currentIndex];//需要移动的距离
    
    CGFloat targetButtonWidth = _style == CCZSegementStyleDefault? ([self widthAtIndex:buttonIndex] - 2 * _buttonSpace) : [self widthAtIndex:buttonIndex]; // 这个会影响width
    CGFloat originButtonWidth = _style == CCZSegementStyleDefault? ([self widthAtIndex:[self selectedAtIndex]] - 2 * _buttonSpace) : [self widthAtIndex:[self selectedAtIndex]];
    
    
    CGFloat moved; // 移动的距离
    moved = offsetX - [self selectedAtIndex] * _size.width;
    _indicateView.frame = CGRectMake(originMovedX + targetMovedWidth / _size.width * moved, _indicateView.frame.origin.y,  originButtonWidth + (targetButtonWidth - originButtonWidth) / _size.width * offset, _indicateView.frame.size.height);
}

#pragma mark -- set

- (void)setSegementTintColor:(UIColor *)segementTintColor {
    _segementTintColor = segementTintColor;
    _indicateView.backgroundColor = segementTintColor;
    for (UIView *view in _segementView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setTitleColor:segementTintColor forState:UIControlStateSelected];
        }
    }
}

- (void)setSegementViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    _containerView.contentSize = CGSizeMake(viewControllers.count * _size.width, _size.height - _segementHeight);
    for (int i = 0; i < viewControllers.count; i++) {
        UIViewController *viewController = viewControllers[i];
        viewController.view.frame = CGRectOffset(_containerView.bounds, i * _size.width, 0);
        [_containerView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }
}

- (void)setStyle:(CCZSegementStyle)style {
    _style = style;
    
    if (style == CCZSegementStyleDefault) {
        
    } else {
        _indicateView.frame = CGRectMake(_selectedButton.frame.origin.x, _segementHeight - _indicateHeight, [self widthAtIndex:0], _indicateHeight);
    }
}

@end
