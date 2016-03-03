## Query API 

_trying to move towards a concrete document before the BNL hackathon_

### Definitions, terminology

* sequence - string sequence (not the fasta sequence)
* sequence id - a unique identifier for each fasta sequence input.   _i.e._ from header from fasta sequence file
* md5 - hexadecimal md5 computed from protein sequence, all caps and all whitespace and trailing stop removed
* source_type - _i.e._ "reference", "isolate", "metagenome"
     + "reference" - one of several reference databases
     + "isolate"  - a isolated whole genome assembly 
     + "metagenome" - ANL processed metagenome
* match_threshold - some to-be-determined low-end match parameters (%id, length, etc)

### Basal (low-level) utilities

* sequence - md5 relationship

        md5 = seq_to_md5( sequence )

        sequence = md5_to_seq( md5 )

* sequence - sequence_id relationship

        sequence = seq_id_to_seq( seq_id )

        [ seq_id, ... ] = seq_to_seq_id( sequence )

* seq_id - md5 relationship

        md5 = seq_id_to_md5( seq_id )
   
        [ seq_id, ... ] = md5_to_seq_id( md5 )


### Similarity matrix

At the base level, accessed by md5 only.

    get_matches( [ list of md5s ], match_threshold )

    -> [ [query_md5_1, [ matching_md5, match_score_data ],
                       [ matching_md5, match_score_data ], ...
         [query_md5_2, [ matching_md5, match_parameters ] ] ... ]

  

### Metadata

