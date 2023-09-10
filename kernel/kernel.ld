OUTPUT_FORMAT("binary")

SECTIONS
{
	. = 0x80010000;

	.text :
	{
		*(.text)
	}

	end = .;
}
