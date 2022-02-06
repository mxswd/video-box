//
//  ViewController.m
//  VideoBox
//
//  Created by Maxwell on 21/06/21.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Video+CoreDataClass.h"
#import <AVKit/AVKit.h>
#import "VideoCache.h"

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic) UITableViewDiffableDataSource *dataSource;
@property (nonatomic) NSFetchedResultsController *fetchController;
@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // FIXME: Find out what the user agent is. Test it on my own web server.
    
    self.context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    
    
    self.dataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:self.tableView cellProvider:^(UITableView * tableView, NSIndexPath *indexPath, NSManagedObjectID *itemId) {
        Video *video = [self.context objectWithID:itemId];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = video.filename;
        cell.detailTextLabel.text = video.created.description;
        return cell;
    }];
    
    NSFetchRequest *fetch = [Video fetchRequest];
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO];
    fetch.sortDescriptors = @[timeSort];
    fetch.predicate = [NSPredicate predicateWithValue:YES];
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSError *e;
    [self.fetchController performFetch:&e];
    if (e != nil) {
        NSLog(@"%@", e);
    }
    
//    [[[VideoCache alloc] init] runWeb];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showVideo"]) {
        AVPlayerViewController *vc = segue.destinationViewController;
        NSManagedObjectID *itemId = [self.dataSource itemIdentifierForIndexPath:self.tableView.indexPathForSelectedRow];
        Video *video = [self.context existingObjectWithID:itemId error:nil];
        NSURL *documentsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        vc.player = [AVPlayer playerWithURL:[documentsDir URLByAppendingPathComponent:video.filename]];
        [vc.player play];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithSnapshot:(NSDiffableDataSourceSnapshot<NSString *,NSManagedObjectID *> *)snapshot {
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}


@end
