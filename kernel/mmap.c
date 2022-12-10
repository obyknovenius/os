#include "t.h"
#include "mem.h"
#include "print.h"

typedef struct {
	uint32	size;
	uint64	base;
	uint64	len;
	uint32	type;
} MRange;

void
readmmap() {
	MRange *r;

	r = (MRange*)MMAP;

	for (;;) {
		if (r->size == 0) {
			break;
		}
		
		switch (r->type) {
		case 1:
			print("Memory");
			break;
		case 2:
			print("Reserved");
			break;
		case 3:
			print("ACPI");
			break;
		case 4:
			print("NVS");
			break;
		default:
			print("Undefined");
		}
		print("\t%lld\t%lld\n", r->base, r->len);
		r++;
	}
}
