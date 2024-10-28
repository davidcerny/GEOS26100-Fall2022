# GEOS 26100: Phylogenetics and the Fossil Record

This repository hosts materials I developed as a teaching assistant for the course "Phylogenetics and the Fossil Record" (GEOS 26100), taught by Graham Slater at the University of Chicago in Fall 2022.

For my reflections on the experience and some commentary on the files described below, see:

https://davidcerny.github.io/post/teaching_revbayes

## Description

This repository includes the following files:

- PDF handouts for four labs covering the basics of model-based phylogenetic inference from discrete morphological data:
    * Lab 5 focuses on maximum likelihood as implemented in [IQ-TREE 2](https://github.com/iqtree/iqtree2) (Minh et al. 2020);
    * Labs 6, 7, and 8 focus on Bayesian analysis as implemented in [RevBayes](https://github.com/revbayes/revbayes) (Höhna et al. 2016).

  Each subdirectory also contains the corresponding TeX source and graphics to make it easier to create derivative works, should anyone feel so inclined.
  
- Two example data files:
    * A Nexus file with the Tedford et al. (2009) canid matrix (`Tedford_2009-1.nex`), modified from the version available from [Graeme T. Lloyd's phylogenetic dataset repository](https://graemetlloyd.com/matrcarn.html). (Specifically, the file was stripped of the `ASSUMPTIONS` block to make it work with RevBayes.)
    * A tab-separated file with the fossil ages of the corresponding taxa (`Tedford_ages.tsv`).
 
- An R script intended to preprocess Nexus character matrices for IQ-TREE analyses (`partition.R`) by splitting them into separate Phylip (`.phy`) files – first by character type (ordered vs. unordered), and then by the number of observed character states.

- Three RevBayes (`.Rev`) scripts:
    * `archery.Rev` goes with Lab 7;
    * `Tedford_phylo.Rev` goes with Lab 7;
    * `Tedford_FBD_strictclock.Rev` goes with Lab 8.

## Errata and troubleshooting

- In the handout for Lab 5, I say that maximum-likelihood phylogenetic inference was originally developed for DNA sequences. This is not correct; it was actually first developed for continuous characters representing blood-group allele frequencies (Edwards & Cavalli-Sforza 1964).

- Also in the handout for Lab 5, my well-intentioned advice to use the standard/slow (`-b`) rather than ultrafast (`-B`) bootstrap sometimes caused students to run into the following error with IQ-TREE v2.2.0:

  ```
  ERROR: phylokernelnew.h:3332: double PhyloTree::computeLikelihoodFromBufferGenericSIMD() [VectorClass = Vec4d, FMA = true, SITE_MODEL = false]: Assertion `std::isfinite(tree_lh) && "Numerical underflow for lh-from-buffer"' failed. 
  ERROR: 
  ERROR: *** IQ-TREE CRASHES WITH SIGNAL ABORTED 
  ```
  
  I haven't verified if this error occurs still occurs in the most recent version (v2.3.6 as of 2024-10-27), but I would still recommend using the more numerically stable ultrafast bootstrap just in case.
  
- Changing `Tedford_phylo.Rev` as suggested in Exercise 6 of Lab 7 will trigger RevBayes issue [#308](https://github.com/revbayes/revbayes/issues/308) and result in the following error:

  ```
    Error:    Ambiguous call to function 'sum' with arguments ( Probability[] )
    Potentially matching functions are:
    sum (Real[]<any> x)
    sum (RealPos[]<any> x)
    sum (Integer[]<any> x)
    sum (Natural[]<any> x)
   
    Error:    Problem processing line 26 in file ""Tedford_phylo.Rev""
  ```
    
  Unfortunately, this issue is still unsolved, so I'd recommend modifying the exercise by asking the students to try out a different prior – e.g, `dnExponential(5)`.

- The script for Lab 8 (`Tedford_FBD_strictclock.Rev`) *will* run with the current version of RevBayes, but the program will flood the screen with warnings about attempts to set fossil ages to illegal values. As it turns out, this occurs when the root of the tree is a sampled ancestor, and the `mvRootTimeSlideUniform` move attempts to change its age (see RevBayes issue [#544](https://github.com/revbayes/revbayes/issues/544) and pull request [#559](https://github.com/revbayes/revbayes/pull/559)). We can get rid of the warnings simply by deleting this move.

- Also in the script for Lab 8, when the students try to plug their own numbers into the calculation of the origin age prior, it's preferable for type safety reasons to write `abs(upper - lower)/qexp(0.95)` instead of just `(upper - lower)/qexp(0.95)`.

## FAQ

**What about Labs 1–4? What were they about and why are they not here?**

The first four labs of the course were dedicated to finding a pre-existing character matrix in the literature (Lab 1); constructing one's own toy matrix for different types of pasta (Lab 2); parsimony analysis in PAUP\* (Lab 3); and time-scaling parsimony trees using R, RStudio, and [`paleotree`](https://github.com/dwbapst/paleotree) (Lab 4). Unlike the handouts for Labs 6–8, which I wrote pretty much from scratch, the handouts for the first four labs were heavily based on earlier materials prepared by [Anna Wisniewski](https://github.com/wisniewskianna) and [Graham Slater](https://github.com/grahamjslater), so it didn't feel appropriate to upload them to my personal GitHub.
 
## Acknowledgments

As described in the accompanying [blog post](https://davidcerny.github.io/post/teaching_revbayes), Labs 6–8 were developed following the advice of a number of RevBayes developers, some of whom kindly shared with me their own tutorials and workshop slides. When publicly available, these are linked to from the corresponding handouts and credited to their authors, with all such citations highlighted in blue. They include:

- [Jeremy Brown](https://github.com/jembrown)'s slides from the Workshop on Molecular Evolution ([link](https://molevolworkshop.github.io/faculty/brown/pdf/Brown_GraphicalModels_RevBayes.pdf)) (Lab 6)
- [Tracy Heath](https://github.com/trayc7)'s tutorial from the Taming the BEAST workshop ([link](https://taming-the-beast.org/tutorials/FBD-tutorial/FBD-tutorial.pdf)) (Lab 8)

In addition, I made use of a number of official tutorials hosted directly on the [RevBayes website](https://revbayes.github.io):

- [*Introduction to MCMC using RevBayes*](https://revbayes.github.io/tutorials/mcmc/archery.html), written by [Wade Dismukes](https://github.com/wadedismukes), Tracy Heath, and [June Walker](https://github.com/milliescient) (Lab 7)
- [*Discrete morphology - Tree Inference*](https://revbayes.github.io/tutorials/morph_tree/), written by [April Wright](https://github.com/wrightaprilm), [Michael Landis](https://github.com/mlandis), and [Sebastian Höhna](https://github.com/hoehna) (Lab 7)
- [*Nucleotide substitution models*](https://revbayes.github.io/tutorials/ctmc/), written by Sebastian Höhna, Michael Landis, [Brian Moore](https://github.com/brianrmoore), and Tracy Heath (Lab 7)

Valuable feedback and inspiration were further provided by [Jiansi Gao](https://github.com/jsigao), [Bruno Petrucci](https://github.com/brpetrucci), [Orlando Schwery](https://github.com/oschwery), [Carrie Tribble](https://github.com/cmt2), [Rachel Warnock](https://github.com/rachelwarnock), and April Wright.

The markdown file used to apply the CC BY-SA license to the contents of this repo was taken from [this repository](https://github.com/santisoler/cc-licenses) helpfully maintained by Santiago Soler and colleagues.

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
