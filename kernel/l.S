.extern trap

.globl sti

sti:
	sti
	ret

/*
 * Interrupt/exception handling.
 * Each entry in the vector table calls either strayintr or strayintrx
 * depending on whether an error code has been automatically pushed 
 * onto the stack (strayintrx) or not(strayintr), in which case 
 * a dummy zero entry must be pushed before retrieving the trap type
 * from the vector table entry and placing it on the stack as part
 * of the Ureg structure.
 * The size of each entry in the vector table (6 bytes) is known in trapinit().
 */ 
strayintr:
	pushl %eax		/* save EAX */
	movl 4(%esp), %eax	/* return EIP from vectortable */
	movl $0, 4(%esp)	/* set error code to zero */
	jmp intrcommon

strayintrx:
	xchgl %eax, (%esp)	/* swap EAX with return EIP from vectortable */

intrcommon:
	movzbl (%eax), %eax	/* trap type -> EAX */
	xchgl %eax, (%esp)	/* exchange trap type with saved EAX */

	pushl %ds		/* save DS */
	pushl %es		/* save ES */
	pushl %fs		/* save the rest of the Ureg struct */
	pushl %gs
	pushal

	pushl %esp		/* Ureg* argument to trap */
	call trap
	popl %eax

	popal
	popl %gs
	popl %fs
	popl %es
	popl %gs
	addl $8, %esp		/* pop error code and trap type */
	iretl

.globl vectortable
vectortable:
	call strayintr; .byte 0		/* divide error */
	call strayintr; .byte 1		/* debug */
	call strayintr; .byte 2		/* NMI interrupt */
	call strayintr; .byte 3		/* breakpoint */
	call strayintr; .byte 4		/* overflow */
	call strayintr; .byte 5		/* bound range exceeded */
	call strayintr; .byte 6		/* invalid opcode */
	call strayintr; .byte 7		/* device not available */
	call strayintrx; .byte 8	/* double fault */
	call strayintr; .byte 9		/* coprocessor segment overrun */
	call strayintrx; .byte 10	/* invalid TSS */
	call strayintrx; .byte 11	/* segment not present */
	call strayintrx; .byte 12	/* stack fault */
	call strayintrx; .byte 13	/* general protection */ 
	call strayintrx; .byte 14	/* page fault */
	call strayintr; .byte 15	/*  */
	call strayintr; .byte 16	/* FPU floating point error */
	call strayintrx; .byte 17	/* alignment check */
	call strayintr; .byte 18	/* machine check */
	call strayintr; .byte 19	/* SIMD floating point */
	call strayintr; .byte 20	/* virtualization */
	call strayintr; .byte 21	/* control protection */
	call strayintr; .byte 22
	call strayintr; .byte 23
	call strayintr; .byte 24
	call strayintr; .byte 25
	call strayintr; .byte 26
	call strayintr; .byte 27
	call strayintr; .byte 28
	call strayintr; .byte 29
	call strayintr; .byte 30
	call strayintr; .byte 31
	call strayintr; .byte 32
	call strayintr; .byte 33
	call strayintr; .byte 34
	call strayintr; .byte 35
	call strayintr; .byte 36
	call strayintr; .byte 37
	call strayintr; .byte 38
	call strayintr; .byte 39
	call strayintr; .byte 40
	call strayintr; .byte 41
	call strayintr; .byte 42
	call strayintr; .byte 43
	call strayintr; .byte 44
	call strayintr; .byte 45
	call strayintr; .byte 46
	call strayintr; .byte 47
	call strayintr; .byte 48
	call strayintr; .byte 49
	call strayintr; .byte 50
	call strayintr; .byte 51
	call strayintr; .byte 52
	call strayintr; .byte 53
	call strayintr; .byte 54
	call strayintr; .byte 55
	call strayintr; .byte 56
	call strayintr; .byte 57
	call strayintr; .byte 58
	call strayintr; .byte 59
	call strayintr; .byte 60
	call strayintr; .byte 61
	call strayintr; .byte 62
	call strayintr; .byte 63
	call strayintr; .byte 64
	call strayintr; .byte 65
	call strayintr; .byte 66
	call strayintr; .byte 67
	call strayintr; .byte 68
	call strayintr; .byte 69
	call strayintr; .byte 70
	call strayintr; .byte 71
	call strayintr; .byte 72
	call strayintr; .byte 73
	call strayintr; .byte 74
	call strayintr; .byte 75
	call strayintr; .byte 76
	call strayintr; .byte 77
	call strayintr; .byte 78
	call strayintr; .byte 79
	call strayintr; .byte 80
	call strayintr; .byte 81
	call strayintr; .byte 82
	call strayintr; .byte 83
	call strayintr; .byte 84
	call strayintr; .byte 85
	call strayintr; .byte 86
	call strayintr; .byte 87
	call strayintr; .byte 88
	call strayintr; .byte 89
	call strayintr; .byte 90
	call strayintr; .byte 91
	call strayintr; .byte 92
	call strayintr; .byte 93
	call strayintr; .byte 94
	call strayintr; .byte 95
	call strayintr; .byte 96
	call strayintr; .byte 97
	call strayintr; .byte 98
	call strayintr; .byte 99
	call strayintr; .byte 100
	call strayintr; .byte 101
	call strayintr; .byte 102
	call strayintr; .byte 103
	call strayintr; .byte 104
	call strayintr; .byte 105
	call strayintr; .byte 106
	call strayintr; .byte 107
	call strayintr; .byte 108
	call strayintr; .byte 109
	call strayintr; .byte 110
	call strayintr; .byte 111
	call strayintr; .byte 112
	call strayintr; .byte 113
	call strayintr; .byte 114
	call strayintr; .byte 115
	call strayintr; .byte 116
	call strayintr; .byte 117
	call strayintr; .byte 118
	call strayintr; .byte 119
	call strayintr; .byte 120
	call strayintr; .byte 121
	call strayintr; .byte 122
	call strayintr; .byte 123
	call strayintr; .byte 124
	call strayintr; .byte 125
	call strayintr; .byte 126
	call strayintr; .byte 127
	call strayintr; .byte 128
	call strayintr; .byte 129
	call strayintr; .byte 130
	call strayintr; .byte 131
	call strayintr; .byte 132
	call strayintr; .byte 133
	call strayintr; .byte 134
	call strayintr; .byte 135
	call strayintr; .byte 136
	call strayintr; .byte 137
	call strayintr; .byte 138
	call strayintr; .byte 139
	call strayintr; .byte 140
	call strayintr; .byte 141
	call strayintr; .byte 142
	call strayintr; .byte 143
	call strayintr; .byte 144
	call strayintr; .byte 145
	call strayintr; .byte 146
	call strayintr; .byte 147
	call strayintr; .byte 148
	call strayintr; .byte 149
	call strayintr; .byte 150
	call strayintr; .byte 151
	call strayintr; .byte 152
	call strayintr; .byte 153
	call strayintr; .byte 154
	call strayintr; .byte 155
	call strayintr; .byte 156
	call strayintr; .byte 157
	call strayintr; .byte 158
	call strayintr; .byte 159
	call strayintr; .byte 160
	call strayintr; .byte 161
	call strayintr; .byte 162
	call strayintr; .byte 163
	call strayintr; .byte 164
	call strayintr; .byte 165
	call strayintr; .byte 166
	call strayintr; .byte 167
	call strayintr; .byte 168
	call strayintr; .byte 169
	call strayintr; .byte 170
	call strayintr; .byte 171
	call strayintr; .byte 172
	call strayintr; .byte 173
	call strayintr; .byte 174
	call strayintr; .byte 175
	call strayintr; .byte 176
	call strayintr; .byte 177
	call strayintr; .byte 178
	call strayintr; .byte 179
	call strayintr; .byte 180
	call strayintr; .byte 181
	call strayintr; .byte 182
	call strayintr; .byte 183
	call strayintr; .byte 184
	call strayintr; .byte 185
	call strayintr; .byte 186
	call strayintr; .byte 187
	call strayintr; .byte 188
	call strayintr; .byte 189
	call strayintr; .byte 190
	call strayintr; .byte 191
	call strayintr; .byte 192
	call strayintr; .byte 193
	call strayintr; .byte 194
	call strayintr; .byte 195
	call strayintr; .byte 196
	call strayintr; .byte 197
	call strayintr; .byte 198
	call strayintr; .byte 199
	call strayintr; .byte 200
	call strayintr; .byte 201
	call strayintr; .byte 202
	call strayintr; .byte 203
	call strayintr; .byte 204
	call strayintr; .byte 205
	call strayintr; .byte 206
	call strayintr; .byte 207
	call strayintr; .byte 208
	call strayintr; .byte 209
	call strayintr; .byte 210
	call strayintr; .byte 211
	call strayintr; .byte 212
	call strayintr; .byte 213
	call strayintr; .byte 214
	call strayintr; .byte 215
	call strayintr; .byte 216
	call strayintr; .byte 217
	call strayintr; .byte 218
	call strayintr; .byte 219
	call strayintr; .byte 220
	call strayintr; .byte 221
	call strayintr; .byte 222
	call strayintr; .byte 223
	call strayintr; .byte 224
	call strayintr; .byte 225
	call strayintr; .byte 226
	call strayintr; .byte 227
	call strayintr; .byte 228
	call strayintr; .byte 229
	call strayintr; .byte 230
	call strayintr; .byte 231
	call strayintr; .byte 232
	call strayintr; .byte 233
	call strayintr; .byte 234
	call strayintr; .byte 235
	call strayintr; .byte 236
	call strayintr; .byte 237
	call strayintr; .byte 238
	call strayintr; .byte 239
	call strayintr; .byte 240
	call strayintr; .byte 241
	call strayintr; .byte 242
	call strayintr; .byte 243
	call strayintr; .byte 244
	call strayintr; .byte 245
	call strayintr; .byte 246
	call strayintr; .byte 247
	call strayintr; .byte 248
	call strayintr; .byte 249
	call strayintr; .byte 250
	call strayintr; .byte 251
	call strayintr; .byte 252
	call strayintr; .byte 253
	call strayintr; .byte 254
	call strayintr; .byte 255
