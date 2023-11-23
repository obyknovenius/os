#include <t.h>
#include <libc.h>

void vseprint(char *buf, char *e, const char *fmt, va_list args) {
	Fmt f;

	if (e <= buf)
		return;
	f.start = buf;
	f.to = buf;
	f.stop = e - 1;
	f.args = args;
	dofmt(&f, fmt);
	*f.to = '\0';
}
