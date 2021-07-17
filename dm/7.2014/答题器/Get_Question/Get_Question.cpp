// Get_Question.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdlib.h>
#include <windows.h>

// 答题器会获取main函数的返回值,1是成功获取到答案 0是失败
// 此EXE的主要作用是从共享内存中获取到问题,然后自己处理(比如从题库中查询答案),把答案再拷贝到原共享内存,并返回1
int main(int argc, char* argv[])
{
	char share_file[256] = {0,};
	HANDLE question_handle;

	// 共享内存名为"Get_Question_当前进程pid"
	sprintf(share_file, "Get_Question_%d", GetCurrentProcessId());
	question_handle = OpenFileMappingA(FILE_MAP_ALL_ACCESS,FALSE,share_file);
	if (question_handle == NULL)
	{
		return 0;
	}

	char * share_memory = (char *)MapViewOfFile(question_handle, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, 0);
	
	// 打印出问题
	printf("question = %s\n",share_memory);

	// 然后自己处理这个问题，比如从题库中查询这个问题，我们这里只是个例子，就不真正的查询了
	// 有答案后，把答案拷贝到这个share_memory中即可,注意必须是GBK编码,然后返回1
	// 如果没有答案，关闭句柄，返回0即可
	// 我们只是简单的返回"我也不知道答案"即可!
	strcpy(share_memory,"我也不知道答案");
	UnmapViewOfFile(share_memory);
	CloseHandle(question_handle);
	return 1;
}

