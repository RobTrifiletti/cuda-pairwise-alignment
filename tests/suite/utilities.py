import sys

def fasta_read(f):
	seqs = {}
	name = ""
	seq = " "
	for line in f:
		if line.startswith('>'):
			if name != '' and seq != '':
				seqs[name] = seq
				name = ''
				seq = ' '
			name = line[1:].replace('\n', '').strip()
			continue
		if line.startswith(';'):
			continue
		seq += line.replace(' ', '').replace('\n', '').upper()
	if name != '' and seq != '':
		seqs[name] = seq
	return seqs

def fasta_print(h, alignment):
	i = 0
	print '>' + h
	for (a, b) in alignment:
		i = i + 1
		sys.stdout.write(a)
		if i % 80 == 0: sys.stdout.write('\n')


def matrix_read(f):
	gapcost = None
	matrix = []
	for line in f:
		if line.startswith('#'):
			continue
		if gapcost == None:
			gapcost = int(line.strip())
		else:
			matrix.append(map(int, line.strip().split()))
	
	def subcost(a, b):
		t = { 'A' : 0, 'C' : 1, 'G' : 2, 'T' : 3 }
		return matrix[t[a]][t[b]]
		
	return (gapcost, subcost)
