#!/usr/bin/perl

$last_query_id = "";
$last_subject_id = "";

#while (<stdin>) {
while ( <> ) {

    ($query_id, $subject_id, $percent_identiy, $align_len, $mismatches, $gaps, $q_start, $q_end, $s_start, $s_end, $e_value, $bit_score) = split;

#    print "last ", $last_query_id, "\t", "current ", $query_id, "\n";

#    print "equality test = ", ($last_query_id != $query_id), "\n";

#  was
#    if ($last_query_id ne $query_id) {

    unless ( $last_query_id eq $query_id && $last_subject_id eq $subject_id )  {
	print $query_id,"\t", $subject_id,"\t", $percent_identiy, "\t",$align_len,"\t", $mismatches,"\t", $gaps,"\t", $q_start, "\t",$q_end, "\t",$s_start,"\t", $s_end,"\t", $e_value,"\t", $bit_score,"\n";
    }

    $last_query_id = $query_id;
    $last_subject_id = $subject_id;
}
