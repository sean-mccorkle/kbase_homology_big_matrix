Celero

10,000 sequences self

Diamond:

          time diamond makedb --in nruni.samp.1.aaa.fa -d nruni.samp.1.aaa
          1.120u 0.028s 0:00.60 190.0%	0+0k 0+45672io 0pf+0w

          time diamond blastp -k1000000 -d nruni.samp.1.aaa -q nruni.samp.1.aaa.fa -a self.1 -t xxx
          18.696u 11.512s 0:12.19 247.7%	0+0k 0+13736io 0pf+0w

          time diamond blastp -k1000000 -d nruni.samp.1.aaa -q nruni.samp.1.aab.fa -a self.1 -t xxx
          14.052u 11.452s 0:10.42 244.7%	0+0k 464+9992io 4pf+0w

   convert to ascii

          time diamond view -a self.1.daa -o self.1.m8
          0.176u 0.008s 0:00.20 85.0%	0+0k 0+5520io 0pf+0w

BlastP:

          time makeblastdb -in nruni.samp.1.aaa.fa -dbtype prot -out nruni.samp.1.aaa
          Building a new DB, current time: 10/28/2015 10:33:26
          New DB name:   nruni.samp.1.aaa
          New DB title:  nruni.samp.1.aaa.fa
          Sequence type: Protein
          Keep Linkouts: T
          Keep MBits: T
          Maximum file size: 1073741824B
          Adding sequences from FASTA; added 10000 sequences in 0.306596 seconds.
          0.308u 0.000s 0:00.31 96.7%	0+0k 424+7072io 2pf+0w

          time blastp -db nruni.samp.1.aaa -query nruni.samp.1.aaa.fa -outfmt 7 > yyy
          439.880u 0.176s 7:20.31 99.9%	0+0k 1912+28696io 11pf+0w

          time blastp -db nruni.samp.1.aaa -query nruni.samp.1.aab.fa -outfmt 7 > yyy
          475.956u 0.212s 7:56.67 99.8%	0+0k 4936+25080io 40pf+0w

100,000 sequences self

Diamond

          time diamond makedb --in nruni.samp.1 -d nruni.samp.1
          13.464u 0.068s 0:05.14 263.0%	0+0k 0+114480io 0pf+0w

          time diamond blastp -k1000000 -d nruni.samp.1 -q nruni.samp.1 -a bigself.1 -t xxx
          477.076u 15.152s 2:57.60 277.1%	0+0k 0+873928io 0pf+0w

          time diamond view -a bigself.1 -o bigself.1.m8
          8.920u 0.248s 0:06.12 149.6%	0+0k 0+330368io 0pf+0w


***

on Golgi 
10,000 sequences

          time diamond makedb --in nruni.samp.1.aaa.fa -d nruni.samp.1.aaa.fa 
          1.548u 0.036s 0:00.32 490.6%	0+0k 0+45672io 0pf+0w

          time diamond blastp -k1000000 -d nruni.samp.1.aaa.fa -q nruni.samp.1.aaa.fa -a self.1 -t xxx
          25.944u 16.552s 0:05.51 771.1%	0+0k 472+13736io 5pf+0w

100,000 sequences

          time diamond makedb --in nruni.samp.1 -d nruni.samp.1
          19.572u 0.092s 0:03.00 655.3%	0+0k 0+114480io 0pf+0w

          time diamond blastp -k1000000 -d nruni.samp.1 -q nruni.samp.1 -a bigself.1 -t xxx
          591.304u 17.200s 1:17.41 786.0%	0+0k 0+873496io 0pf+0w

          time diamond blastp -k1000000 -d nruni.samp.1 -q one.fasta -a bigself.1 -t xxx
          34.960u 15.744s 0:06.62 765.8%	0+0k 0+48io 0pf+0w


Proposing (Estimates):

1M sequence blocks
1M x 1M run will take about an hour on a beagle node (32 cores) (set wall time to 6hrs)
We anticipate 10,000 1M x 1M runs (jobs)
10,000 Node hours

Mem req estimate:
1M sequence diamond db = 500M

Disk output estimate:
100K X 100K runs is 1,000,000 jobs at 162MB (m8 output) per job would produce: 162 x 10 ^ 12 162 TB
100K x 100K runs is 1,000,000 jobs at 388MB (binary output) per job would produce: 388 x 10 ^ 12 388 TB
Compression will be approximate 162 TB to 60 TB
Job is make_diamomd_db | diamond blastp | diamond view | stitch | gzip

***

1,000,000 sequences

Diamond:

 On Celero

        time diamond makedb --in  nruni.million.samp.1.fasta -d nruni.million.samp.1
        136.336u 7.632s 0:38.83 370.7%	0+0k 16+771040io 0pf+0w

        diamond blastp -k10000000 -d nruni.million.samp.1 -q nruni.million.samp.1.fasta -a bigself.million.1 -t xxx &
        (approximately 1 hour 45 minutes)

        time diamond view -a bigself.million.1 -o bigself.million.1.m8
        628.896u 65.240s 5:54.11 196.0%	0+0k 60034168+25200016io 12pf+0w

sizes

         348M nruni.million.samp.1.fasta
         377M nruni.million.samp.1.dmnd
          29G bigself.million.1.daa
          13G bigself.million.1.m8




