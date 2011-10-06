/*
 *  MNZipTool.c
 *  MultiNet client
 *
 *  Created by Sergey Prokhorchuk on 5/7/10.
 *  Copyright 2010 PlayPhone. All rights reserved.
 *
 */

#include "sys/stat.h"
#include "errno.h"
#include "stdlib.h"
#include "string.h"

#include "unzip.h"

#include "MNZipTool.h"

#define MNZIP_TRUE  (1)
#define MNZIP_FALSE (0)

#define MNZIP_DIRCHAR_UNIX ('/')
#define MNZIP_DIRCHAR_DOS  ('\\')

#define MNZIP_FILENAME_MAX_LEN (255)

#define MNZIP_BUFFER_SIZE (2 * 1024)

static int charIsDirChar (char ch) {
    return ch == MNZIP_DIRCHAR_UNIX || ch == MNZIP_DIRCHAR_DOS;
}

static int charIsValidPathChar (char ch) {
    if (ch == ':') {
        return MNZIP_FALSE;
    }

    return MNZIP_TRUE;
}

static int pathComponentIsValid (const char *path, size_t pos, size_t len) {
    // '..' value is invalid for our case

    if (len == 2 && path[pos] == '.' && path[pos + 1] == '.') {
        return MNZIP_FALSE;
    }

    return MNZIP_TRUE;
}

static void fileNameSplitToPathAndName (char *dirName, char *baseName, const char *fileName) {
    unsigned int base;
    unsigned int index;
    char ch;

    base  = 0;
    index = 0;

    while ((ch = fileName[index++]) != '\0') {
        if (charIsDirChar(ch)) {
            base = index;
        }
    }

    strcpy(baseName,&fileName[base]);

    memcpy(dirName,fileName,base);

    dirName[base] = '\0';
}

static int getPathComponent (const char *path, int *ok, size_t *index, size_t *len) {
    int done;
    size_t pos;

    done = MNZIP_FALSE;
    *ok  = MNZIP_TRUE;

    while (*ok && !done) {
        pos = *index;

        while (*ok && path[pos] != '\0' && !charIsDirChar(path[pos])) {
            *ok = charIsValidPathChar(path[pos]);
            pos++;
        }

        if (*ok) {
            if (pos > *index) {
                *len = pos - *index;

                *ok = pathComponentIsValid(path,pos,*len);

                done = MNZIP_TRUE;
            }
            else {
                if (path[pos] == '\0') {
                    return MNZIP_FALSE;
                }
                else {
                    (*index)++; // skip redundant slash and read next component
                }
            }
        }
    }

    return *ok;
}

static int getPathComponentFirst (const char *path, int *ok, size_t *index, size_t *len) {
    *index = 0;
    *len   = 0;

    return getPathComponent(path,ok,index,len);
}

static int getPathComponentNext (const char *path, int *ok, size_t *index, size_t *len) {
    *index += *len;
    *len    = 0;

    return getPathComponent(path,ok,index,len);
}

static int createDir (const char *path) {
    if (mkdir(path,0755) == 0) {
        return MNZIP_OK;
    }

    if (errno == EEXIST) {
        return MNZIP_OK;
    }

    return MNZIP_FAIL;
}

static int createDirByPath (const char* prefix, const char *path) {
    int    ok;
    char   dirName[MNZIP_FILENAME_MAX_LEN + 1];
    size_t prefixLen;
    size_t destPos;
    size_t srcPos;
    size_t componentLen;
    int    componentPresent;

    if (charIsDirChar(path[0])) { // deny absolute unix/windows paths
        return MNZIP_FAIL;
    }
    
    prefixLen = strlen(prefix);

    if (prefixLen + 1 + strlen(path) > MNZIP_FILENAME_MAX_LEN) { // directory name too long
        return MNZIP_FAIL;
    }

    strcpy(dirName,prefix);
    destPos = prefixLen;

    componentPresent = getPathComponentFirst(path,&ok,&srcPos,&componentLen);

    while (componentPresent && ok) {
        dirName[destPos++] = MNZIP_DIRCHAR_UNIX;

        memcpy(&dirName[destPos],&path[srcPos],componentLen);
        destPos += componentLen;
        dirName[destPos] = '\0';

        ok = createDir(dirName);

        if (ok) {
            componentPresent = getPathComponentNext(path,&ok,&srcPos,&componentLen);
        }
    }

    return ok;
}

static FILE* openOutputFile (const char *prefix, const char *name) {
    char  fullName[MNZIP_FILENAME_MAX_LEN + 1];
    size_t prefixLen;
    size_t nameLen;

    prefixLen = strlen(prefix);
    nameLen   = strlen(name);

    if (prefixLen + 1 + nameLen > MNZIP_FILENAME_MAX_LEN) { // name too long
        return NULL;
    }

    strcpy(fullName,prefix);
    fullName[prefixLen] = MNZIP_DIRCHAR_UNIX;
    memcpy(&fullName[prefixLen + 1],name,nameLen);

    fullName[prefixLen + 1 + nameLen] = '\0';

    return fopen(fullName,"wb");
}

static int unzipFileData (const char *prefix, unzFile zipFile, char* buffer) {
    int   ok;
    char  fileName[MNZIP_FILENAME_MAX_LEN + 1];
    char  pathName[MNZIP_FILENAME_MAX_LEN + 1];
    char  baseName[MNZIP_FILENAME_MAX_LEN + 1];
    FILE *destFile;
    int   size;

    if (unzGetCurrentFileInfo64(zipFile,NULL,fileName,sizeof(fileName),NULL,0,NULL,0) != UNZ_OK) {
        return MNZIP_FAIL;
    }

    fileNameSplitToPathAndName(pathName,baseName,fileName);

    ok = createDirByPath(prefix,pathName);

    if (ok && baseName[0] != '\0') {
        if (unzOpenCurrentFile(zipFile) == UNZ_OK) {
            destFile = openOutputFile(prefix,fileName);

            if (destFile != NULL) {
                do {
                    size = unzReadCurrentFile(zipFile,buffer,MNZIP_BUFFER_SIZE);

                    if (size > 0) {
                        if (fwrite(buffer,1,size,destFile) != size) {
                            ok = MNZIP_FAIL;
                        }
                    }
                    else if (size < 0) {
                        ok = MNZIP_FAIL;
                    }
                } while (ok && size > 0);

                fclose(destFile);
            }
            else {
                ok = MNZIP_FAIL;
            }

            unzCloseCurrentFile(zipFile);
        }
        else {
            ok = MNZIP_FAIL;
        }
    }

    return ok;
}

extern int MNZipToolUnzipFile (const char *destPath, const char *srcFileName) {
    int               ok;
    unzFile           zipFile;
    unz_global_info64 zipInfo;
    uLong             index;
    void              *buffer;

    ok = MNZIP_OK;

    zipFile = unzOpen64(srcFileName);

    if (zipFile != NULL) {
        if (unzGetGlobalInfo64(zipFile,&zipInfo) == UNZ_OK) {
            buffer = malloc(MNZIP_BUFFER_SIZE);

            if (buffer != NULL) {
                index = 0;

                while (index < zipInfo.number_entry && ok) {
                    if (index > 0) {
                        if (unzGoToNextFile(zipFile) != UNZ_OK) {
                            ok = MNZIP_FAIL;
                        }
                    }

                    if (ok) {
                        ok = unzipFileData(destPath,zipFile,buffer);
                    }

                    index++;
                }
            }
            else {
                free(buffer);
            }
        }
        else {
            ok = MNZIP_FAIL;
        }

        unzClose(zipFile);
    }
    else {
        ok = MNZIP_FAIL;
    }

    return ok;
}

extern int MNZipToolExtractFileData (void **data, size_t *size, const char *zipFileName, const char *dataFileName) {
    int               ok;
    unzFile           zipFile;
    unz_file_info64   dataFileInfo;

    ok = MNZIP_FAIL;
    *data = NULL;
    *size = 0;

    zipFile = unzOpen64(zipFileName);

    if (zipFile != NULL) {
        if (unzLocateFile(zipFile,dataFileName,1) == UNZ_OK) {
            if (unzGetCurrentFileInfo64(zipFile,&dataFileInfo,NULL,0,NULL,0,NULL,0) == UNZ_OK) {
                if (dataFileInfo.uncompressed_size > 0) {
                    *size = dataFileInfo.uncompressed_size;
                    *data = malloc(*size);

                    if (*data != NULL) {
                        if (unzOpenCurrentFile(zipFile) == UNZ_OK) {
                            if (unzReadCurrentFile(zipFile,*data,*size) == *size) {
                                ok = MNZIP_OK;
                            }

                            unzCloseCurrentFile(zipFile);
                        }

                        if (ok != MNZIP_OK) {
                            free(*data);
                        }
                    }
                }
            }
        }

        unzClose(zipFile);
    }

    if (ok != MNZIP_OK) {
        *data = NULL;
        *size = 0;
    }

    return ok;
}
