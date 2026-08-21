unit uStrings; interface


const
MY_PRODUCTS_NAME = 'Quick Hash Checksum';
MY_APP_NAME_CHECKIFY = 'Hash Checkify';
MY_APP_NAME_GENIFY = 'Hash Genify';
MY_APP_VERSION = '3.0';
MY_APP_DEVELOPER='Shohanur Rahman';
MY_APP_PUBLISHER='SR Studio 24 - BD';


//Checkify
  CurrentFileStatus: string = 'Checking...';
  CurrentFileDescription: string = 'Verifying file...';

  FileisOKStr: string = ' Verified';
  FileISOKDescStr: string = 'The file is Genuine and Safe.';

  FileisMissMatchStr: string = ' Not Safe';
  FileISMissMatchDescStr: string = 'The file is not Genuine.';

  FileisMissingStr: string = ' Missing';
  FileISMissingDescStr: string = 'The file does not exist.';

  FileisAbortedStr: string = ' Aborted';
  FileISAbortedDescStr: string = 'Verification stopped.';

  MY_REG_PATH_CHECKIFY = 'Software\SR Studio\Quick Hash Checksum\Checkify';
  QC_HEIGHT = 'Height';
  QC_WIDTH = 'Width';

  ResHashName = 'Hash';      //Resource Hash File
  ResHashType = 'Checksum';  // Resource Hash Folder

//Genify
GeneratingHashStatusCaption = 'Generating...';
QueueItemsStatusCaption = 'Queue...';
AbortedStatusCaption = 'Aborted';

 MY_REG_PATH_GENIFY = 'Software\SR Studio\Quick Hash Checksum\Genify';
  HASH_FORMAT = 'Hash';
  QG_HEIGHT = 'Height';
  QG_WIDTH = 'Width';



implementation

end.
