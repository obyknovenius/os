#define	nil	((void*)0)

#define true	1
#define false	0

typedef	unsigned char		bool;

typedef	unsigned char		byte;

typedef	signed char		int8;
typedef	signed short		int16;
typedef	signed long		int32;
typedef	signed long long	int64;

typedef	unsigned int		uint;
typedef	unsigned char		uint8;
typedef	unsigned short		uint16;
typedef	unsigned long		uint32;
typedef	unsigned long long	uint64;

typedef char*	va_list;
#define va_start(list, start) list =\
	(sizeof(start) < 4?\
		(char*)((int*)&(start)+1):\
		(char*)(&(start)+1))
#define va_end(list)
#define va_arg(list, mode)\
	((sizeof(mode) == 1)?\
		((list += 4), (mode*)list)[-4]:\
	(sizeof(mode) == 2)?\
		((list += 4), (mode*)list)[-2]:\
		((list += sizeof(mode)), (mode*)list)[-1])
