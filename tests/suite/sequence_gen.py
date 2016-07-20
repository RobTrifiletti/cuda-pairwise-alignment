import random
import sys
from utilities import *
s = []
p = ['A', 'C', 'G', 'T']
for i in range(int(sys.argv[1])):
	c1 = random.choice(p)
	q = p[:]
	q.remove(c1)
	c2 = random.choice(q)
	s.append((c1, c2))
fasta_print(sys.argv[2], s)
