/*
 *  MNZipTool.h
 *  MultiNet client
 *
 *  Created by Sergey Prokhorchuk on 5/7/10.
 *  Copyright 2010 PlayPhone. All rights reserved.
 *
 */

#ifndef __MNZIPTOOL_H__
#define __MNZIPTOOL_H__

#define MNZIP_OK   (1)
#define MNZIP_FAIL (0)

#ifdef __cplusplus
extern "C" {
#endif

extern int MNZipToolUnzipFile (const char *destPath, const char *srcFileName);
extern int MNZipToolExtractFileData (void **data, size_t *size, const char *zipFileName, const char *dataFileName);

#ifdef __cplusplus
}
#endif

#endif
