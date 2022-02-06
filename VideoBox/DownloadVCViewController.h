//
//  DownloadVCViewController.h
//  VideoBox
//
//  Created by Maxwell on 21/06/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadVCViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *urlField;
- (IBAction)save:(id)sender;

@end

NS_ASSUME_NONNULL_END
