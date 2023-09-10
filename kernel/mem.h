/*
 * Sizes
 */
#define KB		1024
#define MB		(1024 * KB)

#define BY2PG		4096		/* bytes per page */

#define	PGSHIFT		12		/* log(BY2PG) */

/*
 * Fundamental addresses
 */
#define KZERO		0x80000000	/* base of kernel address space */
#define IDTADDR		(KZERO + 0x3000)/* idt */
#define PXEBASE		0x7c00		/* pxe loads us here */
#define PBSBASE		0x10000		/* pbs loads us here */

#define MMAP		(512 * 1024)

/*
 * MEMMIN is whate the bootstrap code in l*.s has already mapped;
 */
#define MEMMIN		(20 * MB)

#define LOWPTEPAGES	(MEMMIN / (4 * MB))

/*
 * known x86 segments (in GDT) and their selectors
 */
#define NULLSEG		0		/* null segment */
#define KCSEG		1		/* kernel code */
#define KDSEG		2		/* kernel data/stack */

#define	SELECTOR(i)	((i) << 3)

#define KCSEL		SELECTOR(KCSEG)
#define KDSEL		SELECTOR(KDSEG)

/*
 * fields in segment descriptors
 */
#define SEGG		(1 << 23)	/* granularity 1=4k */
#define	SEGB		(1 << 22)	/* big 1=32bit (for stack) */
#define SEGD		(1 << 22)	/* default 1=32bit (for code) */

#define SEGP		(1 << 15)	/* present */
#define	SEGPL(x)	((x) << 13)	/* priority level */
#define SEGS		(1 << 12)	/* system */

#define SEGE		(1 << 10)	/* expand down (for data) */
#define SEGW		(1 << 9)	/* writable (for data) */
#define SEGC		(1 << 10)	/* conforming (for code) */
#define SEGR		(1 << 9)	/* readable (for code) */

#define SEGDATA 	(SEGS)		/* data/stack segment */
#define SEGCODE 	(SEGS | 1 << 11)/* code segment */

#define	SEGCG		(0x0c << 8)	/* call gate */
#define SEGIG		(0x0e << 8)	/* interrupt gate */
#define SEGTG		(0x0f << 8)	/* trap gate */

/*
 * physical MMU
 */
#define PTEP		(1 << 0)	/* present */
#define PTERW		(1 << 1)	/* read/write */

/* CR0 */
#define CR0PE		(1 << 0)	/* protection enable */
#define CR0WP		(1 << 16)	/* write protect */
#define CR0PG		(1 << 31)	/* paging */
