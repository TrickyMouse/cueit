//
//  DBManager.m
//  CueIt
//
//  Created by Tricky Mouse on 2017-04-02.
//  Copyright © 2017 Space Dog. All rights reserved.
//

#import "DBManager.h"
#import "CueSheet.h"
#import "SongList.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL) createDB {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"cueit.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            // create the cue_sheets table if none exists
            const char *sql_stmt = "create table if not exists cue_sheets (sheetnumber integer primary key autoincrement, name text, location text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            // create the song_list table if none exists
            sql_stmt = "create table if not exists song_lists (listnumber integer primary key autoincrement, sheetnumber integer, name text, volume_level text, fade_time text, sortorder text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            
            sqlite3_close(database);
            return  isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

#pragma mark cue_sheet DB methods
-(BOOL) saveNewSheet:(NSString *)name {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into cue_sheets (name) values (\"%@\")", name];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        } else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

-(BOOL) deleteSheet:(NSString *)sheetNumber {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"delete from cue_sheets where sheetnumber=\"%d\"",[sheetNumber integerValue]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        } else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}


-(BOOL) saveSheetData:(NSString *)sheetNumber name:(NSString *)name {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into cue_sheets (sheetnumber, name) values (\"%d\",\"%@\")",[sheetNumber integerValue], name];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                sqlite3_reset(statement);
                return YES;
            } else {
                sqlite3_reset(statement);
                return NO;
            }
    }
    return NO;
}

-(NSArray *) getAllCuesheets {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select * from cue_sheets"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                CueSheet *cueSheet = [[CueSheet alloc] init];
                NSString *sheetnumber = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                cueSheet.sheetnumber = sheetnumber;
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                cueSheet.name = name;
                // Ignoring the location value.. we'll get back to this one..
//                NSString *location = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
//                cueSheet.location;
                [resultArray addObject:cueSheet];
            }
            sqlite3_reset(statement);
            return resultArray;
        } else {
            NSLog(@"Not found");
            sqlite3_reset(statement);
            return nil;
        }
    }
    return nil;
}


-(NSArray*) findCuesheetBySheetNumber:(NSString*)sheetNumber {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select name from cue_sheets where sheetnumber=\"%@\"",sheetNumber];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
//                NSString *department = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
//                [resultArray addObject:department];
//                NSString *year = [[NSString alloc]initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
//                [resultArray addObject:year];
                sqlite3_reset(statement);
                return resultArray;
            } else{
                NSLog(@"Not found");
                sqlite3_reset(statement);
                return nil;
            }
        }
    }
    return nil;
}

#pragma mark song_list DB methods

-(BOOL) saveSongListData:(NSString *)listNumber sheetNumber:(NSString *)cueSheet songName:(NSString *)name volumeLevel:(NSString *)volume fadeTime:(NSString *)fade sortOrder:(NSString *)sortorder {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into song_lists (listnumber, sheetnumber, name, volume_level, fade_time, sortorder) values (\"%d\",\"%d\",\"%@\", \"%@\", \"%@\", \"%@\")",[listNumber integerValue], [cueSheet integerValue], name, volume, fade, sortorder];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        } else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

-(BOOL) deleteSong:(NSString *)listNumber {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"delete from song_lists where listnumber=\"%d\"",[listNumber integerValue]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
            return YES;
        } else {
            sqlite3_reset(statement);
            return NO;
        }
    }
    return NO;
}

-(NSArray*) findAllSongsByCueSheetNumber:(NSString*)sheetNumber {
    NSLog(@"findAllSongsByCueSheetNumber:%@", sheetNumber);
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *querySQL = [NSString stringWithFormat:@"select * from song_lists where sheetnumber=\"%@\"",sheetNumber];
        NSLog(@"%@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                SongList *songList = [[SongList alloc] init];
                
                NSString *listnumber = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                songList.listnumber = listnumber;
                NSString *sheetnumber = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                songList.sheetnumber = sheetnumber;
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                songList.name = name;
                NSString *volume_level = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                songList.volume_level = volume_level;
                NSString *fade_time = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                songList.fade_time = fade_time;
                NSString *sortorder = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                songList.sortorder = sortorder;
                
                [resultArray addObject:songList];
            }
            sqlite3_reset(statement);
            return resultArray;
        } else {
            NSLog(@"Not found");
            sqlite3_reset(statement);
            return nil;
        }
    }
    return nil;
}

@end
