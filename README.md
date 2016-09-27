# CCZSegementController
---
* 使用方法
```Objective-C
// 这两个是初始化方法，其中titles是索引标题
+ (instancetype)segementControllerWithFrame:(CGRect)frame titles:(NSArray <NSString *>*)titles;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;

CCZSegementController *segement = [CCZSegementController segementControllerWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height) titles:@[@"热门",@"游戏直播",@"天天向上",@"天气",@"我的天这是复哈风",@"新闻",@"直播",@"哈哈哈哈哈",@"Top10",@"新闻",@"直播",@"Top10"]];
```
* 主要属性及方法介绍
```Objective-C
// 这个方法反回当前选中的控制器下标，注意。更新下标是在UIScrollView减速结束时。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = round(scrollView.contentOffset.x / _size.width);
    [self setSelectedItemAtIndex:index];
}

- (void)setSelectedItemAtIndex:(NSInteger)index {
    for (UIView *view in _segementView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag == index) {
            UIButton *button = (UIButton *)view;
            [self didClickButton:button];
        }
    }
}

- (NSInteger)selectedAtIndex {
    return _selectedButton.tag;
}

// 没更新一次选中的下标，都会触发这个回调
- (void)selectedAtIndex:(void(^)(NSInteger index))indexBlock;

// 在创建的时候就指定第几个控制器被选中
- (void)setSelectedItemAtIndex:(NSInteger)index;
```
* 注意
```Objective-C
// 这个是在实现内部的，是承载传入的控制器的视图用的。如果要做一些特殊需求，可以将它提到外部。比如设置 containerView.scrollEnabled = NO;
@property (nonatomic, strong) UIScrollView *containerView;
...
```
  使用中是通过把segementController当成载体控制器添加到自己的目标控制器上。类似于UITabbar、UINavigationController，因此不要忘记这两句话：
  ```Objective-C
[self.view addSubview:segement.view];
[self addChildViewController:segement];


