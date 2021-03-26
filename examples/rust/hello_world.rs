#![no_std]

fn print_char(index: i32, ch: u16) {
	unsafe{
		*((0xb8000 + index) as *mut u16) = ch;
	}
}

fn clear_screen() {
	for index in 0..(80 * 25) {
		print_char(index * 2, 0x00);
	}
}

#[no_mangle]
fn kmain() {
	clear_screen();
	print_char(0, 'H' as u16);
	print_char(1, 0x02);
	print_char(2, 'E' as u16);
	print_char(3, 0x02);
	print_char(4, 'L' as u16);
	print_char(5, 0x02);
	print_char(6, 'L' as u16);
	print_char(7, 0x02);
	print_char(8, 'O' as u16);
	print_char(9, 0x02);
	print_char(10, ' ' as u16);
	print_char(11, 0x02);
	print_char(12, 'W' as u16);
	print_char(13, 0x02);
	print_char(14, 'O' as u16);
	print_char(15, 0x02);
	print_char(16, 'R' as u16);
	print_char(17, 0x02);
	print_char(18, 'L' as u16);
	print_char(19, 0x02);
	print_char(20, 'D' as u16);
	print_char(21, 0x02);
}