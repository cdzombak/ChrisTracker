#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol CDZMusicTrackerDelegate;

@interface CDZMusicTracker : NSObject

@property (nonatomic, strong) id<CDZMusicTrackerDelegate> delegate;
@property (nonatomic, readonly) MPMediaItem *nowPlayingItem;
@property (nonatomic, readonly) BOOL isMusicTracking;

- (void)startMusicTracking;
- (void)stopMusicTracking;

@end

@protocol CDZMusicTrackerDelegate <NSObject>

- (void)musicTracker:(CDZMusicTracker *)tracker didUpdateNowPlayingItem:(MPMediaItem *)nowPlayingItem;

@end
