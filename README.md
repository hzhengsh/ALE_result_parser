# ALE_result_parser
The purpose of this script is to extract information, including the intra-LGT, duplications, losses, and origination events from analyses using ALE. The input should be the directory of the ALE output. A frequency threshold of 0.3 was adopted to identify events, accounting for potential noise that may arise from sequence alignment and tree reconstructions.
example:
perl ale_parser_0.3.pl ALE_output
