#include <stdio.h>
#include <stdlib.h>

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0') 

extern "C" int turtle(unsigned char *dest_bitmap, unsigned char *commands, unsigned int commands_size);

void print_binary(int number);

int main(void)
{
	FILE *fptr;
	fptr = fopen("./source.bmp", "rb+");

	if (fptr == NULL)
	{
		printf("Error!");
		return 1;
	}

	fseek(fptr, 0, SEEK_END);
	unsigned int length = ftell(fptr);
	fseek(fptr, 0, SEEK_SET);
	unsigned char * buffer = (unsigned char*)malloc(length + 1);
	if (buffer)
	{
		fread(buffer, 1, length, fptr);
	}
	 
	FILE *fptr1;
	fptr1 = fopen("./input.bin", "rb+");

	if (fptr1 == NULL)
	{
		printf("Error1!");
		return 1;
	}
	
	fseek(fptr1, 0, SEEK_END);
	unsigned int length1 = ftell(fptr1);
	fseek(fptr1, 0, SEEK_SET);
	unsigned char * buffer1 = (unsigned char*)malloc(length1 + 1);
	if (buffer1)
	{
		fread(buffer1, 1, length1, fptr1);
	}

printf("=========================================================\n");
	for (int i = 0; i < length1; i++)
	{
		printf(BYTE_TO_BINARY_PATTERN, BYTE_TO_BINARY(buffer1[i]));
	}
	
	printf("\nLength: %d \n", length1);
	
	int result = turtle(buffer, buffer1, length1);
	printf("Returned value: %d bin: ", result);
	
	print_binary(result);
	printf("\n");
printf("=========================================================\n");

	FILE *fout;
	fout = fopen("./output.bmp", "w");
	fwrite(buffer,1,length,fout);

	fclose(fptr);
	fclose(fptr1);
	fclose(fout);
	
	free(buffer);
	free(buffer1);
  
	return 0;
}

void print_binary(int number)
{
    if (number) {
        print_binary(number >> 1);
        putc((number & 1) ? '1' : '0', stdout);
    }
}



