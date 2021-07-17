// Put_Question.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdlib.h>
#include <windows.h>


// 答题器需要获取main函数的返回值,0是失败,1是成功
// 此EXE主要完成的功能是从共享内存中获取到问题和答案，然后自己处理(比如保存到题库中)
int main(int argc, char* argv[])
{
	char share_file[256] = {0,};
	HANDLE question_handle;
	HANDLE answer_handle;
	char question[4096] = {0,};
	char answer[4096] = {0,};
	char * share_memory;


	// 问题共享内存名为"Put_Question_当前进程pid"
	sprintf(share_file, "Put_Question_%d", GetCurrentProcessId());
	question_handle = OpenFileMappingA(FILE_MAP_ALL_ACCESS,FALSE,share_file);
	if (question_handle == NULL)
	{
		return 0;
	}

	// 答案共享内存名为"Put_Answer_当前进程pid"
	sprintf(share_file, "Put_Answer_%d", GetCurrentProcessId());
	answer_handle = OpenFileMappingA(FILE_MAP_ALL_ACCESS,FALSE,share_file);
	if (answer_handle == NULL)
	{
		CloseHandle(question_handle);
		return 0;
	}
	
	// 获取问题，并拷贝到缓冲区
	share_memory = (char *)MapViewOfFile(question_handle, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, 0);
	strcpy(question,share_memory);
	UnmapViewOfFile(share_memory);

	// 获取答案，并拷贝到缓冲区
	share_memory = (char *)MapViewOfFile(answer_handle, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, 0);
	strcpy(answer,share_memory);
	UnmapViewOfFile(share_memory);

	CloseHandle(question_handle);
	CloseHandle(answer_handle);
	
	// ok,现在question为问题,answer为答案
	printf("question = %s,answer = %s\n",question,answer);
	// 开始自己的处理,比如放入题库中，我们就不处理了,直接返回就好

	return 1;
}

