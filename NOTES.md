Noter
=====

Implementation 1
----------------

[Slutcommit](https://github.com/dansondergaard/cuda-pairwise-alignment/commit/c2d1f591a4016bc8268a6a6e7fba4a16f244c07d)

- Naiv implementation hvor en tråd udregner en enkelt celle. For hver diagonal i tabellen kaldes vores kernel. Vi bruger kvadratisk plads, dette gør at vi ret hurtigt løber tør for hukommelse, men det er en start.

- [Husk at vente på at en diagonal er blevet færdig før den anden kaldes.](https://github.com/dansondergaard/cuda-pairwise-alignment/commit/8d8f76f6e04c18137a40e7969b8aca8bd83f62f1) Ikke nødvendigt alligevel da kernels startet i samme stream køres sekventielt på GPU'en selvom kernelkald returnerer på CPU'en med det samme.

- Primære profiling observationer: mange global memory loads og dårlig memory load efficiency.
  - 5 global memory reads per tråd
    - 2 fra sekvens lookup i score funktionen
    - 3 tabel lookups, et for hver celle der bruges


Noter til os selv
------------------
- Størrelse af en block skal bestemmes ud fra hvor meget shared memory der er til rådighed.
- Pruning meget effektiv teknik. Siden vi tester en DNA streng mod en database og vi kun er interesserede i hvilken entry den nuværende streng ligner mest kan vi løbende holde styr på den bedste alignment so far, kald denne værdi P. Inden vi udregner en cell kan vi lave et check for at se om denne celle, i det bedst mulige tilfælde kan bidrage til et større alignment end P, såfremt dette ikke er muligt, pruner vi cellen og udregner den ikke.

Hvis alle omkringliggende celler er prunede bliver den nuværende celle også prunet.
Hvis alle omkringliggende celler af en block er prunede kan hele blokken prunes og behøver derfor ikke beregnes.

Pruning kan også bruges når man kun sammenligner 2 strenge. Dette gøres ved først at lave et trial run, hvor man kun udregner blokke der ligger tæt på diagonalen, altså udregner en lille del af matricen. Dette giver en score i T[M][N] og vi kan nu bruge denne score som P værdi i det efterfølgende fulde gennemløb.