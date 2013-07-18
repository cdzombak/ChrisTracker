#import "CDZMusicTracker.h"

@interface CDZMusicTracker ()

@property (nonatomic, strong, readonly) MPMusicPlayerController *musicPlayer;
@property (nonatomic, assign, readwrite) BOOL isMusicTracking;

@end

@implementation CDZMusicTracker

@synthesize musicPlayer = _musicPlayer;

- (void)startMusicTracking
{
    if (self.isMusicTracking) return;
    else self.isMusicTracking = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingItemChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:self.musicPlayer];
    [self.musicPlayer beginGeneratingPlaybackNotifications];
}

- (void)stopMusicTracking
{
    if (!self.isMusicTracking) return;
    else self.isMusicTracking = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object:self.musicPlayer];
    [self.musicPlayer endGeneratingPlaybackNotifications];
}

#pragma mark Notifications

- (void)nowPlayingItemChanged:(id)sender
{
    // ignore this if music isn't actively playing:
    if (self.musicPlayer.playbackState != MPMusicPlaybackStatePlaying) return;

    MPMediaItem *nowPlayingItem = self.musicPlayer.nowPlayingItem;

    // only scrobble actual music; no podcasts, etc:
    NSNumber *mediaType = [nowPlayingItem valueForKey:MPMediaItemPropertyMediaType];
    if ([mediaType integerValue] != MPMediaTypeMusic) return;

    id<CDZMusicTrackerDelegate> delegate = self.delegate;
    if (delegate) {
        [delegate musicTracker:self didUpdateNowPlayingItem:nowPlayingItem];
    }
}

#pragma mark Property overrides

- (MPMusicPlayerController *)musicPlayer
{
    if (!_musicPlayer) _musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    return _musicPlayer;
}

- (MPMediaItem *)nowPlayingItem
{
    return self.musicPlayer.nowPlayingItem;
}

@end
