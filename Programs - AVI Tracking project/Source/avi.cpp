/*
Copyright (C), 2005, Oleg Kornilov, oleg.kornilov@mail.ru

This software is free, you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
("LGPL") as published by the Free Software Foundation.
See http://www.gnu.org/copyleft/lesser.html for additional information about the GNU LGPL.
*/

#include <stdio.h>		// For <export.h>
#include "export61.h"		// For IDL connection

#include "windows.h"		// For MessageBox function
#include "vfw.h"		// For AVI operation
#include "memory.h"		// For memory operation

#define AVIIF_KEYFRAME	0x00000010L // this frame is a key frame.

// AVI access in IDL consists from next steps:
// 1. "opening" AVI file (avi_open)
// 2. Reading bitmap data (avi_read)
// 3. "closing" AVI file (avi_close)

//avi_open "opens" AVI file and puts pointers for avi acessing to ID value
//due to IDL does't free memory after calling external dll (need do in manually),
//these pointers can be used in future for fast reading and finally freeng memory

int IDL_STDCALL avi_openr(int argc,void* argv[])
{
	PAVIFILE pfile;
	PAVISTREAM ppavi;
	AVIFILEINFO info;
	PGETFRAME getframe;
	LPBITMAPINFOHEADER pbi;
	HRESULT hr;
  	LONG *avi_id, stream, sinfo;
	DWORD i;
	BYTE  *r, *g, *b;
	IDL_STRING* filename;
	CHAR szMsg[256];
	int error_code;

	AVIFileInit();
	avi_id=(LONG *)argv[0];
	filename=(IDL_STRING *)argv[1];
	hr=AVIFileOpen(&pfile,IDL_STRING_STR(filename),0,0l);
	if (hr!=0) {
//	 sprintf(szMsg, "Unable to open %s", IDL_STRING_STR(filename));
//	 MessageBox(NULL, (LPSTR)szMsg, NULL, MB_OK | MB_ICONERROR);
	 error_code=1; goto error; }

	stream=0l; //Usually video stream
	hr=AVIFileGetStream(pfile,&ppavi,0l,stream);
	if (hr!=0) {
//	 sprintf(szMsg, "Unable to open stream %ld", stream);
//	 MessageBox(NULL, (LPSTR)szMsg, NULL, MB_OK | MB_ICONERROR);
	 error_code=2; goto error; }

	getframe=AVIStreamGetFrameOpen(ppavi, NULL);
	if (getframe==NULL) {
//	 MessageBox(NULL, "Unable to get frames at all", NULL,
//	 MB_OK | MB_ICONERROR);
	 error_code=3; goto error; }

	hr=AVIFileInfo(pfile,&info,sinfo);
	if (hr!=0) {
//	 MessageBox(NULL, "Unable to read info", NULL,
//	 MB_OK | MB_ICONERROR);
	 error_code=4; goto error; }

	pbi=(LPBITMAPINFOHEADER)AVIStreamGetFrame(getframe, 0l);
	if (pbi==NULL) {
//	 sprintf(szMsg, "Unable to get frame %ld", 0l);
//	 MessageBox(NULL, (LPSTR)szMsg, NULL, MB_OK | MB_ICONERROR);
	 error_code=5; goto error; }
	
	avi_id[0]=pbi->biBitCount;
	avi_id[1]=info.dwWidth;
	avi_id[2]=info.dwHeight;
	avi_id[3]=info.dwLength;

	if (pbi->biBitCount == 8) {
	r=(BYTE *)argv[2]; g=(BYTE *)argv[3]; b=(BYTE *)argv[4];
	 for (i=0; i<pbi->biClrUsed; i++) {
	  memcpy(b+i, (LPBYTE)pbi+pbi->biSize+i*4, 1);
	  memcpy(g+i, (LPBYTE)pbi+pbi->biSize+i*4+1, 1);
	  memcpy(r+i, (LPBYTE)pbi+pbi->biSize+i*4+2, 1); }}
	
	// Here we copying headers of AVI interface to avi_id value
	memcpy(avi_id+4,&pfile,4);
	memcpy(avi_id+5,&ppavi,4);
	memcpy(avi_id+6,&getframe,4);
	return 0;

	error:
	if(getframe) AVIStreamGetFrameClose(getframe);
	if(ppavi) AVIStreamRelease(ppavi);
	if(pfile) AVIFileRelease(pfile);
	AVIFileExit();
	return error_code; }

//avi_read fill allocated memory with r,g,b components (bitmap) of frame in AVI file

int IDL_STDCALL avi_get(int argc,void* argv[])
{
	PAVIFILE pfile;
	PAVISTREAM ppavi;
	PGETFRAME getframe;
	LPBITMAPINFOHEADER pbi;
	LONG *avi_id, frame;
	DWORD i, pos;
	BYTE *image, r;
	CHAR szMsg[256];
	int error_code;

	// Here we copying headers back from avi_id
	avi_id=(LONG *)argv[0];
	memcpy(&pfile, avi_id+4,4);
	memcpy(&ppavi, avi_id+5,4);
	memcpy(&getframe, avi_id+6,4);

	frame=*(LONG *)argv[1];
	pbi=(LPBITMAPINFOHEADER)AVIStreamGetFrame(getframe, frame);

	if (pbi==NULL) {
//	 sprintf(szMsg, "Unable to get frame %ld", frame);
//	 MessageBox(NULL, (LPSTR)szMsg, NULL, MB_OK | MB_ICONERROR);
	 error_code=1; return error_code; }
	
	image=(BYTE *)argv[2];
	memcpy(image,((LPBYTE)pbi+pbi->biSize+pbi->biClrUsed*sizeof(RGBQUAD)),
	 pbi->biSizeImage);

	if (pbi->biClrUsed==0) {
	 for (i=0; i<pbi->biSizeImage/3; i++) {
	  pos=i*3; r=image[pos]; image[pos]=image[pos+2]; image[pos+2]=r; }}

	return 0; }

//avi_close closes AVI interface and frees memory

int IDL_STDCALL avi_closer(int argc,void* argv[])
{
	PAVIFILE pfile;
	PAVISTREAM ppavi;
	PGETFRAME getframe;
	LONG *avi_id;

	// Here we copying headers back from avi_id
	avi_id=(LONG *)argv[0];
	memcpy(&pfile, avi_id+4,4);
	memcpy(&ppavi, avi_id+5,4);
	memcpy(&getframe, avi_id+6,4);

	AVIStreamGetFrameClose(getframe);
	AVIStreamRelease(ppavi);
	AVIFileRelease(pfile);
	AVIFileExit();

	return 0; }

int IDL_STDCALL avi_openw(int argc,void* argv[])
{
	LPBITMAPINFOHEADER alpbi;
	AVISTREAMINFO strhdr;
	PAVIFILE pfile = NULL;
	PAVISTREAM ps = NULL, psCompressed = NULL;
	AVICOMPRESSOPTIONS opts;
	AVICOMPRESSOPTIONS FAR * aopts[1] = {&opts};
	HRESULT hr;
	LONG *avi_id, bits, width, height, ncolors, i, keyframe, bytepersec;
	BYTE *r, *g, *b, rate, *codec, quality;
	IDL_STRING *filename;
	CHAR szMsg[256];
	int error_code;
	
	AVIFileInit();
	avi_id=(LONG *)argv[0];
	filename=(IDL_STRING *)argv[1];
	codec=(BYTE *)argv[6]; quality=*(BYTE *)argv[7];
	keyframe=*(LONG *)argv[8]; bytepersec=*(LONG *)argv[9];
	bits=avi_id[0]; width=avi_id[1]; height=avi_id[2];
	r=(BYTE *)argv[2]; g=(BYTE *)argv[3]; b=(BYTE *)argv[4];
	rate=*(BYTE *)argv[5];

	_unlink(IDL_STRING_STR(filename));
	hr=AVIFileOpen(&pfile, IDL_STRING_STR(filename),
	 OF_CREATE | OF_WRITE | OF_SHARE_DENY_NONE, NULL);			
	if (hr!=0) {
//	 sprintf(szMsg, "Unable to create %s", IDL_STRING_STR(filename));
//	 MessageBox(NULL, (LPSTR)szMsg, NULL, MB_OK | MB_ICONERROR);
	 error_code=1; goto error; }

	ncolors=(bits <= 8) ? 1<<bits : 0;

	alpbi=(LPBITMAPINFOHEADER)malloc(sizeof(BITMAPINFOHEADER)+sizeof(RGBQUAD)*ncolors);
	if (alpbi==NULL) { error_code=2; goto error; }

	alpbi->biSize = sizeof(BITMAPINFOHEADER) ;
	alpbi->biWidth = width ;
	alpbi->biHeight = height ;
	alpbi->biPlanes = 1 ;
	alpbi->biBitCount = (WORD) bits ;
	alpbi->biCompression = BI_RGB ;
	alpbi->biSizeImage = bits/8l*width*height ;
	alpbi->biXPelsPerMeter = 0 ;
	alpbi->biYPelsPerMeter = 0 ;
	alpbi->biClrUsed = (DWORD) ncolors;
	alpbi->biClrImportant = 0 ;

	if (bits == 8) {
	 for (i=0; i<ncolors; i++) {
	  memcpy((LPBYTE)alpbi+alpbi->biSize+i*4,b+i,1);
	  memcpy((LPBYTE)alpbi+alpbi->biSize+i*4+1,g+i,1);
	  memcpy((LPBYTE)alpbi+alpbi->biSize+i*4+2,r+i,1); }}

	memset(&strhdr, 0, sizeof(strhdr));
	strhdr.fccType                = streamtypeVIDEO;
	strhdr.fccHandler             = 0;
	strhdr.dwScale                = 1;
	strhdr.dwRate                 = rate;		
	strhdr.dwSuggestedBufferSize  = alpbi->biSizeImage;
	SetRect(&strhdr.rcFrame, 0, 0, (int) alpbi->biWidth, (int) alpbi->biHeight);

	hr = AVIFileCreateStream(pfile,	&ps, &strhdr);	
	if (hr != 0) {
//	 MessageBox(NULL, "Unable to create stream", NULL, MB_OK | MB_ICONERROR);
	 error_code=3; goto error; }

	memset(&opts, 0, sizeof(opts));
	if (*codec==0) {
	 if (!AVISaveOptions(NULL, 3, 1, &ps, (LPAVICOMPRESSOPTIONS FAR *) &aopts)) {
	  error_code=4; goto error; }}
	else {
	 opts.fccType=streamtypeVIDEO;
	 opts.fccHandler=mmioFOURCC(*codec,*(codec+1),*(codec+2),*(codec+3));
	 opts.dwQuality=(long)quality*100;
	 if (keyframe!=0) {
	  opts.dwKeyFrameEvery=keyframe;
	  opts.dwFlags=AVICOMPRESSF_KEYFRAMES; }
	 if (bytepersec!=0) {
	  opts.dwBytesPerSecond=bytepersec;
	  opts.dwFlags=opts.dwFlags | AVICOMPRESSF_DATARATE; }}

	hr = AVIMakeCompressedStream(&psCompressed, ps, &opts, NULL);
	if (hr != 0) {
//	 MessageBox(NULL, "Unable to create stream", NULL, MB_OK | MB_ICONERROR);
	 error_code=5; goto error; }

	hr = AVIStreamSetFormat(psCompressed, 0,
	 alpbi,	alpbi->biSize + alpbi->biClrUsed * sizeof(RGBQUAD));
	if (hr != 0) { error_code=6; goto error; }

	// Here we copying headers of AVI interface to avi_id value
	memcpy(avi_id+4, &pfile, 4);
	memcpy(avi_id+5, &ps, 4);
	memcpy(avi_id+6, &psCompressed, 4);
	memcpy(avi_id+7, &alpbi, 4);
	memcpy(avi_id+8, &aopts[0], 4);
	return 0;

	error:
	if(aopts) AVISaveOptionsFree(1,aopts);
	if(psCompressed) AVIStreamClose(psCompressed);
	if(ps) AVIStreamClose(ps);
	if(pfile) AVIFileRelease(pfile);
	AVIFileExit();
	return error_code; }

int IDL_STDCALL avi_put(int argc,void* argv[])
{	
	LPBITMAPINFOHEADER alpbi;
	PAVIFILE pfile;
	PAVISTREAM ps, psCompressed;
	HRESULT hr;
	LONG *avi_id, frame;
	DWORD i, pos;
	BYTE *image, r;
	CHAR szMsg[256];
	int error_code;

	// Here we copying headers back from avi_id
	avi_id=(LONG *)argv[0];
	memcpy(&pfile, avi_id+4,4);
	memcpy(&ps, avi_id+5,4);
	memcpy(&psCompressed, avi_id+6,4);
	memcpy(&alpbi, avi_id+7,4);

	frame=*(LONG *)argv[1];
	image=(BYTE *)argv[2];
	if (alpbi->biClrUsed==0) {
	 for (i=0; i<alpbi->biSizeImage/3; i++) {
	  pos=i*3; r=image[pos]; image[pos]=image[pos+2]; image[pos+2]=r; }}
	
	hr = AVIStreamWrite(psCompressed,	// stream pointer
	 frame,				// time of this frame
	 1,				// number to write
	 image, alpbi->biSizeImage,	// size of this frame
	 AVIIF_KEYFRAME,			 // flags....
	 NULL,
	 NULL);

	if (hr != 0) {
//	 sprintf(szMsg, "Unable to put frame %ld", frame);
//	 MessageBox(NULL, (LPSTR)szMsg, NULL, MB_OK | MB_ICONERROR);
	 error_code=1; return error_code; }
	
	return 0; }

int IDL_STDCALL avi_closew(int argc,void* argv[])
{
	LPBITMAPINFOHEADER alpbi;
	PAVIFILE pfile;
	PAVISTREAM ps, psCompressed;
	AVICOMPRESSOPTIONS opts;
	AVICOMPRESSOPTIONS FAR * aopts[1] = {&opts};
	LONG *avi_id;

	// Here we copying headers back from avi_id
	avi_id=(LONG *)argv[0];
	memcpy(&pfile, avi_id+4,4);
	memcpy(&ps, avi_id+5,4);
	memcpy(&psCompressed, avi_id+6,4);
	memcpy(&alpbi, avi_id+7,4);
	memcpy(&aopts, avi_id+8, 4);

	AVISaveOptionsFree(1,aopts);
	AVIStreamClose(psCompressed);
	AVIStreamClose(ps);
	AVIFileRelease(pfile);
	AVIFileExit();
	
	return 0; }


