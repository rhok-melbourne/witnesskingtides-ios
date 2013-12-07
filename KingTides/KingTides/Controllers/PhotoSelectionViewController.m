#import "PhotoSelectionViewController.h"
#import "UIImage+FixRotation.h"
#import "PhotoDetailsViewController.h"

@interface PhotoSelectionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) UIImage *photo;
@property(nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, strong) PhotoDetailsViewController *photoDetailsViewController;

@end

@implementation PhotoSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAddPhoto)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(progressToDetails)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.photoDetailsViewController = [[PhotoDetailsViewController alloc] init];
//  self.detailSelectionController.delegate = self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)takePhoto:(id)sender {
  UIActionSheet *cameraActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose photo", nil), nil];
  [cameraActionSheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

  NSString *metaDataInfoKey = [info valueForKey:UIImagePickerControllerEditedImage] ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage;
  self.photo = [[info objectForKey:metaDataInfoKey] fixOrientation];
  self.imageView.image = self.photo;
  self.navigationItem.rightBarButtonItem.enabled = YES;
  [self.takeImageButton setTitle:@"" forState:UIControlStateNormal];
  [self.view setNeedsUpdateConstraints];
  [self.imgPicker dismissViewControllerAnimated:YES completion:nil];


}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  self.imgPicker = [[UIImagePickerController alloc] init];
  self.imgPicker.delegate = self;

  switch (buttonIndex) {
    case 0:
      self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
      break;
    case 1:
      self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      break;
  }
  if (buttonIndex < 2) {
    [self presentViewController:self.imgPicker animated:YES completion:nil];
  }
}

- (void)dismissAddPhoto {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)progressToDetails {
  if(!self.photoDetailsViewController ) {
    self.photoDetailsViewController = [[PhotoDetailsViewController alloc] init];
  }
  [self.navigationController pushViewController:self.photoDetailsViewController animated:YES];
  [self.photoDetailsViewController updatePhoto:self.photo];
}

@end