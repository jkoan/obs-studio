#include <util/bmem.h>
#include <util/dstr.h>
#include "find-font.h"
#include FT_TRUETYPE_IDS_H

#import <Foundation/Foundation.h>

static char *find_path_font(FT_Library lib, NSFileManager *file_manager,
		NSString *path, const char *face_name)
{
	NSArray *files = NULL;
	char *ret = NULL;

	files = [file_manager contentsOfDirectoryAtPath:path error:nil];

	for (NSString *file in files) {
		NSString *full_path =
			[path stringByAppendingPathComponent:file];

		FT_Face face;
		if (FT_New_Face(lib, full_path.UTF8String, 0, &face) != 0)
			continue;

		if (strcmp(face->family_name, face_name) == 0)
			ret = bstrdup(full_path.UTF8String);

		FT_Done_Face(face);

		if (ret)
			break;
	}

	return ret;
}

static char *find_font_file_internal(FT_Library lib, const char *face)
{
	BOOL is_dir;
	char *file = NULL;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(
			NSLibraryDirectory, NSAllDomainsMask, true);

	for (NSString *path in paths) {
		NSFileManager *file_manager = [NSFileManager defaultManager];
		NSString *font_path =
			[path stringByAppendingPathComponent:@"Fonts"];

		bool folder_exists = [file_manager fileExistsAtPath:font_path
				isDirectory:&is_dir];

		if (folder_exists && is_dir)
			file = find_path_font(lib, file_manager, font_path,
					face);

		if (file)
			break;
	}

	return file;
}

char *find_font_file(FT_Library lib, const char *face)
{
	@autoreleasepool {
		return find_font_file_internal(lib, face);
	}
}
