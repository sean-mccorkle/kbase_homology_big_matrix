**Reprocessing 3 Dec 2015**

Celero MASTER_PROCESSING/PASS2

1.  starting with .md5.tab and .md5.seq files re-generated 27,28 Nov 2015

   (bug fixed in use_md5.pl that left one flex md5 id in at the end of each file)


2. removing (vetoing) weird sequences identified with non-alphabetic characters

   (Relying on previously generated lists MASTER_PROCESSING/Weirds/*.{faa,md5} )

   _(note: discovered that most of the Phytozome weird sequences had more than one * at end.  Still discarding these)_

         foreach g ( CoreSEED Ensebl_Plants KBase_NR NCBI_NR patric Phytozome UniParc )
             ./veto_md5 ../Weirds/$g.weirds.md5 ../../MASTER_NRDB/fasta/$g.md5.tab > $g.filtered.md5.tab
             awk -F"\t" '{print $1,$4}' $g.filtered.md5.tab >$g.filtered.md5.seq
             end
         393.836u 153.200s 10:25.50 87.4%	0+0k 279327312+338291784io 23pf+0w


3. reprocessing metagenomes

   MEGAHIT

         ../use_md5.pl -i mgm_input_list > & capture.out &
         153.528u 11.748s 4:31.49 60.8%	0+0k 14560280+18252352io 17pf+0w


         find . -name final.contigs.gene_calls.md5.tab -exec awk -F"\t" '{print $1"\t"$4}' '{}' \; > all_mgm.md5.seq &
         191.412u 6.028s 3:20.56 98.4%	0+0k 896+10019520io 2pf+0w

4. creation of NR file 

   MASTER_PROCESSING/PASS2

         time sort --parallel=4 --buffer-size=500M -T tmp  {CoreSEED,Ensebl_Plants,KBase_NR,NCBI_NR,patric,Phytozome,UniParc}.filtered.md5.seq ../../MEGAHIT/all_mgm.md5.seq >all.sorted.md5.seq
         2661.196u 465.884s 37:22.07 139.4%	0+0k 974385840+977594232io 1pf+0w

         time uniq all.sorted.md5.seq >all.sorted.nr.md5.seq
         336.256u 71.420s 7:07.56 95.3%	0+0k 256938072+85203848io 1pf+0w

         wc -l all.sorted.md5.seq
         376,902,336 all.sorted.md5.seq

         wc -l all.sorted.nr.md5.seq 
         128,186,968 all.sorted.nr.md5.seq


***
24 Nov 2015
Celero MASTER_NRDB/fasta

Using modified version of [use_md5.pl](https://github.com/sean-mccorkle/kbase_homology_big_matrix/blob/master/Scripts/use_md5.pl) from kbase homology service
create input file of files to be processed, tab separated table, two columns, source and file

         CoreSEED	CoreSEED.faa
         Ensebl_Plants	Ensebl_Plants.faa
         KBase_NR	KBase_NR.faa
         NCBI_NR		NCBI_NR.faa
         patric		patric.faa
         Phytozome	Phytozome.faa
         UniParc		UniParc.faa
   

Create an input file (this was actually done in stages) containing

         time ../../use_md5.pl -i redo_uniparc_input
         UniParc	./UniParc.md5.tab
         626.240u 44.688s 11:19.80 98.6%	0+0k 69318456+76722792io 18pf+0w

 
md5.tab files were then awk'ed to produce md5-sequence only 

         awk -F\t {print $1"\t"$4} patric.md5.tab > patric.md5.seq

         time awk -F'\t' '{print $1"\t"$4}' UniParc.md5.tab >UniParc.md5.seq
         819.732u 28.448s 14:24.08 98.1%	0+0k 17090480+69101008io 0pf+0w


         wc -l UniParc.md5.tab UniParc.md5.seq 
         95179356 UniParc.md5.tab
         95179356 UniParc.md5.seq