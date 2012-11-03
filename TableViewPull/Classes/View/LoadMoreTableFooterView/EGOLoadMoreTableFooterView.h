//
//  EGOLoadMoreTableFooterView.h
//  TableViewPull
//
//  Created by 李 福庆 on 12-11-2.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullLoadPulling = 0,
	EGOOPullLoadNormal,
	EGOOPullLoadLoading,
} EGOPullLoadState;

@protocol EGOLoadMoreTableFooterDelegate;
@interface EGOLoadMoreTableFooterView : UIView {
	
	id _delegate;
	EGOPullLoadState _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
    
}

@property(nonatomic,assign) id <EGOLoadMoreTableFooterDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)egoLoadMoreScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoLoadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoLoadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol EGOLoadMoreTableFooterDelegate
- (void)egoLoadMoreTableFooterDidTriggerLoad:(EGOLoadMoreTableFooterView*)view;
- (BOOL)egoLoadMoreTableFooterDataSourceIsLoading:(EGOLoadMoreTableFooterView*)view;
@optional
- (NSDate*)egoLoadMoreTableFooterDataSourceLastUpdated:(EGOLoadMoreTableFooterView*)view;
- (BOOL)egoLoadMoreTableFooterViewDefaultIsShowing:(EGOLoadMoreTableFooterView *)view;
@end

