//
//  DBManager.h
//  CueIt
//
//  Created by Tricky Mouse on 2017-04-02.
//  Copyright © 2017 Space Dog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject {
    NSString *databasePath;
}

+(DBManager *)getSharedInstance;
-(BOOL) createDB;
-(BOOL) saveNewSheet:(NSString *)name;
-(BOOL) deleteSheet:(NSString *)sheetNumber;
-(BOOL) saveSheetData:(NSString *)sheetNumber name:(NSString *)name;
-(BOOL) saveSongListData:(NSString *)listNumber sheetNumber:(NSString *)cueSheet songName:(NSString *)name volumeLevel:(NSString *)volume fadeTime:(NSString *)fade sortOrder:(NSString *)sortorder;
-(BOOL) saveNewSongListData:(NSString *)cueSheet songName:(NSString *)name volumeLevel:(NSString *)volume fadeTime:(NSString *)fade sortOrder:(NSString *)sortorder;
-(BOOL) deleteSong:(NSString *)listNumber;
-(NSArray *)findCuesheetBySheetNumber:(NSString*)sheetNumber;
-(NSArray *)getAllCuesheets;
-(NSArray*) findAllSongsByCueSheetNumber:(NSString*)sheetNumber;

@end
