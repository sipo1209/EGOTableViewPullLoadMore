//
//  EGOLoadMoreTableFooterView.m
//  TableViewPull
//
//  Created by 李 福庆 on 12-11-2.
//
//

#import "EGOLoadMoreTableFooterView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

#define LOAD_MORE_VIEW_HEIGHT 60.0f
#define CHANGE_STATE_RATE 1.2 //set load more view height * 1.2
#define MAINSCREEN_APPLICATIONFRAME_HEIGHT ([UIScreen mainScreen].applicationFrame.size.height)

@interface EGOLoadMoreTableFooterView (Private)
- (void)setState:(EGOPullLoadState)aState;
@end

@implementation EGOLoadMoreTableFooterView
- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%f", [UIScreen mainScreen].applicationFrame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (LOAD_MORE_VIEW_HEIGHT - 20) / 2 + 15, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, (LOAD_MORE_VIEW_HEIGHT - 20) / 2, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, 0.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"blueArrow.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(25.0f, (LOAD_MORE_VIEW_HEIGHT - 20) / 2, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		self.hidden = YES;
		
		[self setState:EGOOPullLoadNormal];
		
    }
    return self;
}
#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoLoadMoreTableFooterDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"AM"];
		[formatter setPMSymbol:@"PM"];
		[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGOLoadMoreTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[formatter release];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}
    
}

- (void)setState:(EGOPullLoadState)aState{
	
	switch (aState) {
		case EGOOPullLoadPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to load more...", @"Release to load more");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
            _arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case EGOOPullLoadNormal:
			
			if (_state == EGOOPullLoadPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull up to load more...", @"Pull pu to load more");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullLoadLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoLoadMoreScrollViewDidScroll:(UIScrollView *)scrollView {
    
	if (_state == EGOOPullLoadLoading) {
		CGFloat offset = MAX(0, -1 * (scrollView.contentSize.height- MAINSCREEN_APPLICATIONFRAME_HEIGHT - scrollView.contentOffset.y));
		offset = MIN(offset, LOAD_MORE_VIEW_HEIGHT);
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
	} else if (scrollView.isDragging) {
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterDataSourceIsLoading:)]) {
			_loading = [_delegate egoLoadMoreTableFooterDataSourceIsLoading:self];
		}
		if (_state == EGOOPullLoadNormal && scrollView.contentOffset.y + MAINSCREEN_APPLICATIONFRAME_HEIGHT > (scrollView.contentSize.height) && !_loading) {
			self.frame = CGRectMake(0, scrollView.contentSize.height, self.frame.size.width, self.frame.size.height);
			self.hidden = NO;
		}
        
		if (_state == EGOOPullLoadPulling && scrollView.contentOffset.y > scrollView.contentSize.height - MAINSCREEN_APPLICATIONFRAME_HEIGHT && scrollView.contentOffset.y < scrollView.contentSize.height - MAINSCREEN_APPLICATIONFRAME_HEIGHT + CHANGE_STATE_RATE * LOAD_MORE_VIEW_HEIGHT && !_loading) {
			[self setState:EGOOPullLoadNormal];
		} else if (_state == EGOOPullLoadNormal && scrollView.contentOffset.y >  scrollView.contentSize.height - MAINSCREEN_APPLICATIONFRAME_HEIGHT + CHANGE_STATE_RATE * LOAD_MORE_VIEW_HEIGHT  && !_loading) {
			[self setState:EGOOPullLoadPulling];
		}
        
        CGFloat bottomInset = 0.0f;
        if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterViewDefaultIsShowing:)]) {
            if ([_delegate egoLoadMoreTableFooterViewDefaultIsShowing:self]) {
                bottomInset = LOAD_MORE_VIEW_HEIGHT;
            }
        }
		if (scrollView.contentInset.bottom != bottomInset) {
            scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset, 0.0f);
		}
		
	}
	
}

- (void)egoLoadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView {
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterDataSourceIsLoading:)]) {
		_loading = [_delegate egoLoadMoreTableFooterDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y > (scrollView.contentSize.height - MAINSCREEN_APPLICATIONFRAME_HEIGHT + CHANGE_STATE_RATE * LOAD_MORE_VIEW_HEIGHT) && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterDidTriggerLoad:)]) {
			[_delegate egoLoadMoreTableFooterDidTriggerLoad:self];
		}
		
		[self setState:EGOOPullLoadLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        CGFloat bottomInset = 0.0f;
        if ([_delegate respondsToSelector:@selector(egoLoadMoreTableFooterViewDefaultIsShowing:)]) {
            if ([_delegate egoLoadMoreTableFooterViewDefaultIsShowing:self]) {
                bottomInset = LOAD_MORE_VIEW_HEIGHT;
            }
        }
		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, bottomInset, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)egoLoadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullLoadNormal];
    
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
