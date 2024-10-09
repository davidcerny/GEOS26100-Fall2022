# GEOS 26100: Phylogenetics and the Fossil Record
This repository hosts materials I developed as a teaching assistant for the course "Phylogenetics and the Fossil Record" (GEOS 26100), taught by Graham Slater at the University of Chicago in Fall 2022.

For my reflections on the experience and some commentary on the files described below, see:

https://davidcerny.github.io/post/teaching_revbayes

## Description

This repository includes the following files:

- PDF handouts for four labs covering the basics of model-based phylogenetic inference from discrete morphological data:
    * Lab 5 focuses on maximum likelihood as implemented in [IQ-TREE 2](https://github.com/iqtree/iqtree2) (Minh et al. 2020)
    * Labs 6, 7, and 8 focus on Bayesian analysis as implemented in [RevBayes](https://github.com/revbayes/revbayes) (Höhna et al. 2016)

  Each subdirectory also contains the corresponding TeX source and graphics to facilitate the creation of derivative works, pursuant to the terms of the license.
  
- Two example data files:
    * A Nexus file with the Tedford et al. (2009) canid matrix (`Tedford_2009-1.nex`), modified from the version available from [Graeme T. Lloyd's phylogenetic dataset repository](https://graemetlloyd.com/matrcarn.html). (Specifically, the file was stripped of the `ASSUMPTIONS` block to make it work with RevBayes.)
    * A tab-separated file with the fossil ages of the corresponding taxa (`Tedford_ages.tsv`)
 
- An R script intended to preprocess Nexus character matrices for IQ-TREE analyses (`partition.R`) by splitting them into separate Phylip (`.phy`) files -- first by character type (ordered vs. unordered), and then by the number of observed character states.

- Three RevBayes (`.Rev`) scripts referenced by the handouts for labs 7 and 8.

## Errata

- In the handout for Lab 5, I say that maximum-likelihood phylogenetic inference was originally developed for DNA sequences. This is not correct; it was actually first developed for continuous characters representing blood-group allele frequencies (Edwards & Cavalli-Sforza 1964).
 
## Acknowledgments

## References

- Edwards AWF, Cavalli-Sforza LL. 1964. Reconstruction of evolutionary trees. Pp. 67–76 *in* Heywood VH, McNeill J, eds. *Phenetic and Phylogenetic Classification*. London, UK: Systematics Association Publ. No. 6
- Höhna S, Landis MJ, Heath TA, Boussau B, Lartillot N, Moore BR, Huelsenbeck JP, Ronquist F. 2016. RevBayes: Bayesian phylogenetic inference using graphical models and an interactive model-specification language. *Syst. Biol.* 65(4): 726–736
- Minh BQ, Schmidt HA, Chernomor O, Schrempf D, Woodhams MD, von Haeseler A, Lanfear R. 2020. IQ-TREE 2: New models and efficient methods for phylogenetic inference in the genomic era. *Mol. Biol. Evol.* 37(5): 1530–1534. Corrigendum: 37(8): 2461
- Tedford RH, Wang X-M, Taylor BE. 2009. Phylogenetic systematics of the North American fossil Caninae (Carnivora: Canidae). *Bull. Am. Mus. Nat. Hist.* 325: 1–218

This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[![CC BY-SA 4.0][cc-by-sa-image]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg
