
void print_char(int index, char ch) 
{
	((char *) 0xb8000)[index] = ch;
}

void clear_screen()
{
	for (int index = 0; index < (80 * 25); index++) {
		print_char(index * 2, 0x00);
	}
}

int kmain()
{
	clear_screen();
	print_char(0, 'H');
	print_char(1, 0x02);
	print_char(2, 'E');
	print_char(3, 0x02);
	print_char(4, 'L');
	print_char(5, 0x02);
	print_char(6, 'L');
	print_char(7, 0x02);
	print_char(8, 'O');
	print_char(9, 0x02);
	print_char(10, ' ');
	print_char(11, 0x02);
	print_char(12, 'W');
	print_char(13, 0x02);
	print_char(14, 'O');
	print_char(15, 0x02);
	print_char(16, 'R');
	print_char(17, 0x02);
	print_char(18, 'L');
	print_char(19, 0x02);
	print_char(20, 'D');
	print_char(21, 0x02);
}