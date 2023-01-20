regs = ['DI', 'SI', 'BP', 'SP',
	'BX', 'DX', 'CX', 'AX',
	'DS', 'ES', 'SS', 'CS',
	'FS', 'GS', 'FL']

enc_regs = []
for r in regs:
	first_ch = ord(r[0]) - ord('A')
	second_ch = ord(r[1]) - ord('I')

	enc_lo = first_ch - 6 if first_ch > 9 else first_ch
	enc_hi = second_ch
	enc = (enc_lo & 0x0F) | ((enc_hi & 0x0F) << 4)

	enc_regs.append(f'{enc:#04x}')

print('db', ', '.join(enc_regs))
