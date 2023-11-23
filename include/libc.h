
/*
 * print routines
 */

typedef struct Fmt	Fmt;
struct Fmt {
	char	*start;		/* start of the buffer */
	char	*to;		/* current place in the buffer */
	char	*stop;		/* end of the buffer */
	va_list	args;		/* args passed to dofmt */
	int	c;		/* % format char */
	uint8	flags;
};

void	vseprint(char *buf, char *e, const char *fmt, va_list args);

void	dofmt(Fmt *f, const char *fmt);
