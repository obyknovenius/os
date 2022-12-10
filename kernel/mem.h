/*
 * Fundamental addresses
 */
#define KZERO	0x10000			/* base of kernel address space */
#define IDTADDR	(KZERO + 0x3000)	/* idt */

#define MMAP	(512*1024)

/*
 * known x86 segments (in GDT) and their selectors
 */
#define NULLSEG	0	/* null segment */
#define KCSEG	1	/* kernel code */
#define KDSEG	2	/* kernel data/stack */

#define	SELECTOR(i)	((i) << 3)

#define KCSEL	SELECTOR(KCSEG)
#define KDSEL	SELECTOR(KDSEG)

/*
 * fields in segment descriptors
 */
#define SEGG	(1 << 23)		/* granularity 1=4k */
#define	SEGB	(1 << 22)		/* big 1=32bit (for stack) */
#define SEGD	(1 << 22)		/* default 1=32bit (for code) */

#define SEGP	(1 << 15)		/* present */
#define	SEGPL(x)((x) << 13)		/* priority level */
#define SEGS	(1 << 12)		/* system */

#define SEGE	(1 << 10)		/* expand down (for data) */
#define SEGW	(1 << 9)		/* writable (for data) */
#define SEGC	(1 << 10)		/* conforming (for code) */
#define SEGR	(1 << 9)		/* readable (for code) */

#define SEGDATA (SEGS)			/* data/stack segment */
#define SEGCODE (SEGS | 1 << 11)	/* code segment */

#define	SEGCG	(0x0C << 8)		/* call gate */
#define SEGIG	(0x0E << 8)		/* interrupt gate */
#define SEGTG	(0x0F << 8)		/* trap gate */
