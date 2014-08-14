#include <util/bmem.h>
#include <util/dstr.h>
#include "find-font.h"

static char *find_path_font(FT_Library lib, NSFileManager *file_manager,
		NSString *path, const char *face_name)
{
	NSArray *files = NULL;
	NSError *error = NULL;
	char *ret = NULL;

	files = [file_manager contentsOfDirectoryAtPath:path error:&error];

	for (NSString *file in files) {
		FT_Face face;
		if (FT_New_Face(lib, file.UTF8String, 0, &face) != 0)
			continue;

		FT_UInt num_faces = FT_GetSfnt_Name_Count(face);
		for (FT_UInt i = 0; i < num_faces; i++) {
			FT_SfntName aname;

			if (FT_Get_Sfnt_Name(face, i, &aname) != 0)
				continue;

			if (astrcmp_n(aname.string, aname.string_len,
						face_name) == 0) {
				ret = bstrdup(file.UTF8String);
				break;
			}
		}

		FT_Done_Face(face);

		if (ret)
			break;
	}

	return ret;
}

static char *find_font_file_autorel(FT_Library lib, const char *face)
{
	BOOL is_dir;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(
			NSLibraryDirectory, NSAllDomainsMask, true);

	for (NSString *path in paths) {
		NSFileManager *file_manager = [NSFileManager defaultManager];
		NSString *font_path =
			[path stringByAppendingPathComponent:@"Fonts"];

		bool folder_exists = [file_manager fileExistsAtPath:font_path
				isDirectory:&is_dir];

		if (folder_exists && is_dir) {
			char *file = find_path_font(file_manager, path);
			if (file)
				return file;
		}
	}
}

char *find_font_file(FT_Library lib, const char *face)
{
	char *ret = NULL;

	@autoreleasepool {
		ret = find_font_file_autorel(lib, face);
	}

	return ret;
}
