#import "TDLService.h"

@implementation TDLService

- (NSString *)serviceName {
  return @"Base Service";
}

- (NSString *)serviceIdentifier {
  return @"com.kumasan.thedl.service.base";
}

- (void)fetchURL:(NSURL *)url {
  // To be implemented by subclasses.
}

- (NSArray *)activeTasks {
  return [NSArray array];
}

+ (NSDictionary *)sampleURLs {
  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"https://platform.theverge.com/wp-content/uploads/sites/2/2026/03/Installer-118.png?quality=90&strip=all&crop=0%2C0%2C100%2C100&w=1440", @"The Verge (Image)",
    @"https://theverge.com/rss/index.xml", @"The Verge (RSS)",
    @"https://www.shutterstock.com/shutterstock/videos/3462297387/preview/stock-footage-close-up-portrait-shot-of-a-beautiful-confident-fitness-girl-in-black-athletic-top-and-shorts.mp4", @"Shutterstock (Video)",
    @"https://wsb.hostdon.ne.jp/sgm234/cache/media_attachments/files/116/183/417/604/082/991/original/03597a642f0ecfd1.jpeg", @"Hostdon (Image)",
    @"https://wsb.hostdon.ne.jp/sgm234/cache/media_attachments/files/116/184/611/983/940/903/original/dee8c16db13df154.mp4", @"Hostdon (Video)",
    @"https://feeds.macrumors.com/MacRumors-All", @"MacRumors (Text)",
    nil];
}

- (void)dealloc {
  [super dealloc];
}

@end
