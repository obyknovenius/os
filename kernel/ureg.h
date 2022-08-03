typedef	struct Ureg	Ureg;
struct Ureg {
	uint32	edi;		/* general registers */
	uint32	esi;
	uint32	ebp;
	uint32	esp;
	uint32	ebx;
	uint32	edx;
	uint32	ecx;
	uint32	eax;

	uint32	gs;		/* data segments */
	uint32	fs;
	uint32	es;
	uint32	ds;

	uint32	trap;		/* trap type */

	uint32	errcode;	/* error code (or zero) */
	uint32	eip;
	uint32	cs;
	uint32	eflags;
};
