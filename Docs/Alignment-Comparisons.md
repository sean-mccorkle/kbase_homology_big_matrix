_19 Aug 2015_

---

### Day 1, first test of small sample of `diamond` output vs `afree`

**Problems Encountered**

1. `afree` truncates sequence header id to 30 characters, 2 characters shorter than our 32-character long md5 hex codes.  We noted that other bioinformatics programs have been known to do this, such as `clustal`, its not just a problem with `afree`, so we discussed a way to achieve shorter hash codes.  We considered [base64](https://en.wikipedia.org/wiki/Base64) md5 codes as an alternative, which are 22 characters long, but we were concerned about potential problems down the line with the "+" and "/" characters. 
  
   We located a general base converter perl library, [Math::Fleximal](http://search.cpan.org/~tilly/Math-Fleximal-0.06/lib/Math/Fleximal.pm), which allows us to convert md5_hex to base 62, giving short and safe md5 codes.  Example, for the same [protein sequence](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Data/example1.fasta),

        >UPI0000000001 status=active
        MGAAASIQTTVNTLSERISSKLEQEANASAQTKCDIEIGNFYIRQNHGCNLTVKNMCSAD
        ADAQLDAVLSAATETYSGLTPEQKAYVPAMFTAALNIQTSVNTVVRDFENYVKQTCNSSA
        VVDNKLKIQNVIIDECYGAPGSPTNLEFINTGSSKGNCAIKALMQLTTKATTQIAPKQVA
        GTGVQFYMIVIGVIILAALFMYYAKRMLFTSTNDKIKLILANKENVHWTTYMDTFFRTSP
        MVIATTDMQN

    output from [md5_hex](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Scripts/fasta2md5old) and [Fleximal base62 conversion](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Scripts/fasta2flex)

        md5 hex    ef8a186543fe2e2243b5f2c571e8ce69 
        md5 flex   7i0h6t00Bgl4auf6yzNe3f

 (This particular implementation is quite slow, which may not be a problem since we will not need to encode protein md5s very often)

  However, these new base62 md5s were not used for this test.  Here, the hex ids in the `diamond` output files were truncated to match the `afree` output.

2. `diamond` output, like blast output format 7, will report multiple [HSPs](https://en.wikipedia.org/wiki/BLAST#Algorithm) on separate records, which complicated simple joins.  We decided to accept only the top (first) HSP, rather than attempt to merge multiples, because at the end of the day we are most interested in close matches, in which case the top HSP should be the hit we want.

  The script first.pl [first.pl](http://github.com/sean-mccorkle/kbase_homology_big_matrix/Scripts/first-hit.pl) was created to remove all but top HSP hits.

  _Update: after some further discussion of concerns about losing good matches, it was decided to examine merged HSPs as well, using a m8->m8 merging program [stitch](https://github.com/proteinuniverse/pipeline/tree/master/stitch) provided by the PNNL team [described here](https://github.com/proteinuniverse/pipeline/blob/master/README.md).

**Procedure**

On celero, diamond v0.7.9.58, afree v2.0 beta

1. `afree` used to create `xaa-x-xaa.afree.out`
2. `diamond -k 100000` run on 1st 1000 sequences from aa to create `xaa.small.m8`
3. to create scatterplot for comparing afree scores vs diamond values:
 
   1. process diamond output for joining, using script [first_hit.pl](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Scripts/first-hit.pl)

            # unix pipeline
            #
            # discard all but first HSP  
            #
            ./first-hit.pl < xaa.small.m8 | \
            #
            # unix join command will join on one column only, so create one by
            # removing trailing two characters from MD5 ids in first two columns, 
            # then concatenating them with "_".
            #
            perl -ne 'chomp; ($a,$b,@rst)=split(/\s+/); $a=~s/..$//; $b=~s/..$//; print "$a\_$b @rst\n";' | \
            #
            # sort for unix join command
            #
            sort -k1,1 > xaa.small.truncated

  2. process afree output for join

  3. join diamond and afree output on first two columns:

            join -1 1 -2 1 xaa.small.truncated xaa-x-xaa.afree.joinable > test.joined`

  4. Ploting with R:

            R
            > test<-read.table( "test.joined" )
            > png( "diamond_vs_afree.png", width=500, height=400 )
            > plot( test$V12, test$V2, xlab="AFREE SD Score", ylab="Diamond % id", ylim=c(0,100), xlim=c(0,100) )
            > dev.off()

     ![diamond score vs afree score scatterplot](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Images/diamond_vs_afree.png)

**Discussion**

  Compare to figure 3 of [Mahmood et. al. 2012](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3315314/)

  The near 100 afree SD score with 60% identity diamond identity outlier is a self hit 
   (insert sequence)
  Self-test diamond search using the --sensitive option raises the diamond % identity to 95%? (still not 100%).  There appears to be an issue with diamond with some alignments.

---

### Day 2

**Comparison of Diamond and Blast % identity**

1. Procedure


        # diamond versus blast
        #
        # first we process blast output for unix join command
        #
        # remove all but first HSPs
        #
        ./first-hit.pl fd.1000.blast.m8 >fd.1000.blast.first
        #
        # concatenate first two columns into one, and sort on that for unix join
        #
        perl -ne ‘($a,$b,@rst)=split(/\s+/); print “$a\_$b @rst\n”;’ fd.1000.blast.first |\
            sort -k1,1 >fd.1000.blast.joinable
        #
        # repeat for diamond output
        #
        ./first-hit.pl fd.1000.diamond.m8 >fd.1000.diamond.first
        #
        perl -ne ‘($a,$b,@rst)=split(/\s+/); print “$a\_$b @rst\n”;’ fd.1000.diamond.first |\
            sort -k1,1 >fd.1000.diamond.joinable
        #
        # now do the join
        #
        join -1 1 -2 1 fd.1000.diamond.joinable fd.1000.blast.joinable >fd.1000.joined

2. plot with R

        R
        > fd1000<- read.table("fd.1000.joined")
        > png( “blast_vs_diamond.png”, width=500, height=400)
        > plot( fd1000$V2, fd1000$V12,xlab="Diamond %id",ylab="Blast % id",main="FD 1000")
        > dev.off()

    ![Blast vs Diamond % identity scatterplot](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Images/blast_vs_diamond.png)

**Comparison of Diamond and Blast vs afree**

1. Procedure

        #
        # diamond and blast vs afree.  Here we run into the agree 30 character cutoff
        # problem again.   First truncate sequence names to 30 chars
        #
        perl -ne ‘($a,$b,@rst)=split(/\s+/); $a=substr($a,0,30); $b=substr($b,0,30); print “$a $b @rst\n”;’ fd.1000.blast.first  >fd.1k.blast.first
        #
        perl -ne ‘($a,$b,@rst)=split(/\s+/); $a=substr($a,0,30); $b=substr($b,0,30); print “$a $b @rst\n”;’ fd.1000.diamond.first  >fd.1k.diamond.first
        #
        perl -ne ‘($a,$b,@rst)=split(/\s+/); print “$a\_$b @rst\n”;’ fd.1k.blast.first | sort -k1,1 >fd.1k.blast.joinable
        #
        perl -ne ‘($a,$b,@rst)=split(/\s+/); print “$a\_$b @rst\n”;’ fd.1k.diamond.first | sort -k1,1 >fd.1k.diamond.joinable
        #
        # reformat afree output for join
        #
        awk '{print $1"_"$2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12}' fd.1k.diamond.first |\
            sort -k1,1 > fd.1k.diamond.joinable
        #
        sort fd.1k.afree.out | uniq | awk '{print $1"_"$2, $3}' | sort -k1,1 > fd.1k.afree.joinable
        #
        # lastly, do the joins
        #
        join -1 1 -2 1 fd.1k.afree.joinable fd.1k.blast.joinable > fd.1k.afree.blast
        join -1 1 -2 1 fd.1k.afree.joinable fd.1k.diamond.joinable > fd.1k.afree.diamond

2. Plot with R

        R
        > fd_afree_blast <- read.table("fd.1k.afree.blast")
        > fd_afree_diamond <- read.table("fd.1k.afree.diamond")

        > plot( fd_afree_blast$V2, fd_afree_blast$V3,
                main="FD 1000",xlim=c(0,100),ylim=c(0,100),
                xlab="afree SD score",ylab="Blast % id")

        > plot( fd_afree_diamond$V2, fd_afree_diamond$V3,
                main="FD 1000",xlim=c(0,100),ylim=c(0,100),
                xlab="afree SD score",ylab="Diamond % id")


![blast % identity vs afree scatterplot](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Images/blast_vs_afree.f1k.png)

![diamond % identity vs afree scatterplot](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Images/diamond_vs_afree.f1k.png)

**Diamond problems**

   identified one of the Diamond outliers,

        >59088BB1F2D606E66E0CB97FD35C6AF7
        MRKIWQIYLTDWRNVFKVSTGTLLVIGIILLPSVYAWVNLKAMWDPYANTSGIKIAVTSQ
        DQGAEVNGKKINIGDEVLHNLQNNKKLGWTFVNEAEARKGVLNGDYYASLLIPKDFSEKI
        TSVLKENPQKPEIDYAVNEKINAVAPKITSSGATSLTNQISQNFIETASQAVLTKLKEAG
        VKLEEELPTIRNIENRVLELNNRLPDIDKLGKQALELEQNLPKIKAQGQKVIALKEKIPE
        INRAGDLVLKIDKNMPELDKVAAVILDIQKRLPDIQKAGDRIVELDQNFSKVESALATAL
        EDTQTALKVINAAQKALPEVQKIADSGKDFTTGLLEFLDKNEGALDSIGTVVKEDLQLVQ
        QIANEVSQITDIIRGVNFDPKAAQAALNRVSGRLTTAVRVLDHISQLLNRVNGYLPSQPL
        DSLISRVSGVEDRFRRLNSTVTSIGDAIQRGEKPAQNLLDDTDRLAGEISSGIDSILGNY
        DTEYAPAIQKALDQIKSVARNSANVLTTAQEQLPNIEKLLNDAQAAAEFGQQELTRLQQD
        LPQYRQKLHEAATTVQGRMGEFTNAVNKAADFVNNDLPAVKSKIHQAADFVRNDLPKAEQ
        QFVKMADLIENKFPEAEKAVHQVANFVRTDLPAAEDSIRQAADTIRKLKGENALGRAIAL
        LKGDVKKESDFLGSPVSLKQERIYPIPNYGSAMSPFYTTLSIWVGAMLLVSMFRVDVDDP
        EEQFKSYQVYFGRLMTFSTIGIFQALSVSLGDLFLLGAYVDAKVAFVLSSMLISLVFTAM
        TYTLVSVFGNIGKGLAVILLVLQFSSSGGTFPIATSTPFFQALNPFVPFTYAVSLLRETV
        GGMLPSTVIRDVVMLFVFIGVCFLFGLVFKKPLSKHTKKMAERAKETKLIP


   created a diamond database with this as the single entry and then self-searched with diamond

        diamond view -a btest.matches.daa 
        59088BB1F2D606E66E0CB97FD35C6AF7	59088BB1F2D606E66E0CB97FD35C6AF7	59.0	773	235	14	123	891	197	891	2.9e-223	758.8
        59088BB1F2D606E66E0CB97FD35C6AF7	59088BB1F2D606E66E0CB97FD35C6AF7	36.6	673	323	16	1	665	1	577	2.1e-104	364.0
        59088BB1F2D606E66E0CB97FD35C6AF7	59088BB1F2D606E66E0CB97FD35C6AF7	22.2	505	307	17	197	665	123	577	8.8e-18	76.3


   created sam output for viewing alignment

        diamond view -a btest.matches.daa -o btest.matches.sam -f sam

   used  [sam2pairwise](https://www.biostars.org/p/110498/) to make alignment display of one record

        tail -n +6 btest.matches.sam | head -1 | ~/src/sam2pairwise/src/sam2pairwise > junk

   junk has extremely long lines (scroll to the right to view whole alignment)

        59088BB1F2D606E66E0CB97FD35C6AF7	0	59088BB1F2D606E66E0CB97FD35C6AF7	1	255	142M8I30M26I95M11I14M8I30M17I36M2I40M3I12M5D13M2I6M2I6M5I52M1D11M7I10M4I33M1I25M2D14M	*	0	0
        MRKIWQIYLTDWRNVFKVSTGTLLVIGIILLPSVYAWVNLKAMWDPYANTSGIKIAVTSQDQGAEVNGKKINIGDEVLHNLQNNKKLGWTFVNEAEARKGVLNGDYYASLLIPKDFSEKITSVLKENPQKPEIDYAVNEKINAVAPKITSSGATSLTNQISQNFIETASQAVLTKLKEAGVKLEEELPTIRNIENRVLELNNRLPDIDKLGKQALELEQNLPKIKAQGQKVIALKEKIPEINRAGDLVLKIDKNMPELDKVAAVILDIQKRLPDIQKAGDRIVELDQNFSKVESALATALEDTQTALKVINAAQKALPEVQKIADSGKDFTTGLLEFLDKNEGALDSIGTVVKEDLQLVQQIANEVSQITDIIRGVNFDPKAAQAALNRVSGRLTTAVRVLDHISQLLNRVNGYLPSQPLDSLISRVSGVEDRFRRLNSTVTSIGDAIQRGEKPAQNLLDDTDRLAGEISSGID-----SILGNYDTEYAPAIQKALDQIKSVARNSANVLTTAQEQLPNIEKLLNDAQAAAEFGQQELTRLQQDLPQYRQKLHEAATTVQGRMG-EFTNAVNKAADFVNNDLPAVKSKIHQAADFVRNDLPKAEQQFVKMADLIENKFPEAEKAVHQVANFVRTDLPAAEDSIRQAADTIRKLKGE--NALGRAIALLKGDV
        ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||          |   |           ||        |                             ||      ||  || |      |  |    | |   |   |    | |                | |  |||     | |        |  |             || ||  ||  |            || |     |      || |      |                 ||| ||  |                 |    | | |                     |  | |        | ||  |    |  |            | | |    | |     ||      | |                       |   |      |  |                |    |   |  || |         ||     |    | |  |  |      |       ||            |||        || |     ||  ||   |      | 
        MRKIWQIYLTDWRNVFKVSTGTLLVIGIILLPSVYAWVNLKAMWDPYANTSGIKIAVTSQDQGAEVNGKKINIGDEVLHNLQNNKKLGWTFVNEAEARKGVLNGDYYASLLIPKDFSEKITSVLKENPQKPEIDYAVNEKIN--------AVAPKITSSGATSLTNQISQNFIETASQAV--------------------------LTKLKEAGVKLEEELPTIRNIENRVLELNNRLPDIDKLGKQALELEQNLPKIKAQGQKVIALKEKIPEINRAGDLVLKIDKNMPELDKVAAVILD-----------IQKRLPDIQKAGDR--------IVELDQNFSKVESALATALEDTQTALKVIN-----------------AAQKALPEVQKIADSGKDFTTGLLEFLDKNEGALDS--IGTVVKEDLQLVQQIANEVSQITDIIRGVNFDPKAAQAAL---NRVSGRLTTAVRVLDHISQLLNRVNGYLPS--QPLDSL--ISRVSG-----VEDRFRRLNSTVTSIGDAIQRGEKPAQNLLDDTDRLAGEISSGIDSILGNYDTEYAPAIQKALD-------QIKSVARNSA----NVLTTAQEQLPNIEKLLNDAQAAAEFGQQELTR-LQQDLPQYRQKLHEAATTVQGRMGEFTNAVNKAADFVNNDL

