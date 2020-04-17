int kmain()
{
	char *video_memory = (char *) 0xb8000;
	video_memory[0] = 'H';
	video_memory[1] = 0x04;
	video_memory[2] = 'E';
	video_memory[3] = 0x04;
	video_memory[4] = 'L';
	video_memory[5] = 0x04;
	video_memory[6] = 'L';
	video_memory[7] = 0x04;
	video_memory[8] = 'O';
	video_memory[9] = 0x04;
	video_memory[10] = ' ';
	video_memory[11] = 0x04;
	video_memory[12] = 'W';
	video_memory[13] = 0x04;
	video_memory[14] = 'O';
	video_memory[15] = 0x04;
	video_memory[16] = 'R';
	video_memory[17] = 0x04;
	video_memory[18] = 'L';
	video_memory[19] = 0x04;
	video_memory[20] = 'D';
	video_memory[21] = 0x04;
}