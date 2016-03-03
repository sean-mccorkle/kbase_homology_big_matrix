

**Three subsets in NR.BLOCKS**

        #  NR UniParc
        84196742

        #  get samples of both metagenomes first
        cat ../NR.BLOCKS/bp.*.flex.md5.fa | numseqs
        966013

        cat ../NR.BLOCKS/kpm.*.flex.md5.fa | numseqs
        757968



**100,000 BP metagenome vs NR UniParc**

        Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
           1      29     400    3569    2930  208800 



![]( https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Images/bp_counts.png)
![]( https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Images/kpm_counts.png)
![]( https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Images/nruni_counts.png)

        celero UniDiamondTests: wc -l *.counts
          218,953,739 bp.nruni.counts
          421,573,967 kpm.nruni.counts
          823,705,848 nruni.nruni.counts
