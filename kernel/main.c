static char* buf = 0xB8000;

void
main() {
	buf[2] = 'C';
	buf[3] = 0x1B;
}