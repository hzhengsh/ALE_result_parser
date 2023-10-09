#!perl -w

use warnings;
use strict;

opendir (ALEDIR, "$ARGV[0]") or die "can't open file $ARGV[0]";
open (SPECIESTREE, ">species.tre") or die "cna't create file species.tree";
open (EVENTSCOUNT, ">gene_family.events.count.txt") or die "can't create gene_family.events.count.txt";
print EVENTSCOUNT "Cluster	Duplications	Transfers	Losses	Speciations\n";
open (EVENTRATE, ">gene_family.events.rate.txt") or die "can't create gene_family.events.rate.txt";
print EVENTRATE "Cluster	Duplications	Transfers	Losses\n";
open (NODEEVENTSSTA,">node.events.count.txt") or die "can't create file node.events.count.txt";
open (NODEHGT, ">node.hgt.txt") or die "cna't create file node.hgt.txt";
open (NODEDUP, ">node.dup.txt") or die "cna't create file node.dup.txt";
open (NODELOSS, ">node.loss.txt") or die "cna't create file node.loss.txt";
open (NODESPEC, ">node.spec.txt") or die "cna't create file node.spec.txt";

my ($species_tree, %duplication, %loss, %transfer, %speciation, %nodes, %duplication_node, %loss_node, %speciation_node, %transfer_node) = ();
foreach my $file (readdir ALEDIR){
	if($file =~ /.*_(\w+)\.ale\.uml_rec/){
		my $cluster_name = $1;
		open (IN, "$ARGV[0]/$file") or die "can't open file $file";
		while(my $line = <IN>){
			if($line =~ /^S\:\s+(\S+.*)$/){
				$species_tree = $1;
			}
			elsif($line =~ /^rate of\s+Duplications.*/){
				$line = <IN>;
				$line =~ s/\s+$//ig;
				my @fields = split /\s+/,$line;
				print EVENTRATE "$cluster_name	$fields[1]	$fields[2]	$fields[3]\n";
			}
			elsif($line =~ /^\# of\s+Duplications.*Speciations\n/){
				$line = <IN>;
				$line =~ s/\s+$//ig;
				my @fields = split /\s+/,$line;
				print EVENTSCOUNT "$cluster_name	$fields[1]	$fields[2]	$fields[3]	$fields[4]\n";
			}
			elsif($line =~ /^S_[terminal|internal]+_branch/){
				$line =~ s/\s+$//ig;
				my @fields = split /\s+/,$line;
				$fields[1] =~ s/\(.*$//ig;
				$nodes{$fields[1]} = 1;
				
				if($fields[2]>0.30){
					push @{$duplication_node{$fields[1]}}, $cluster_name;
					$duplication{$fields[1]} += $fields[2];
				}
				if($fields[3]>0.30){
					push @{$transfer_node{$fields[1]}}, $cluster_name;
					$transfer{$fields[1]} += $fields[3];
				}
				if($fields[4]>0.30){
					push @{$loss_node{$fields[1]}}, $cluster_name;
					$loss{$fields[1]} += $fields[4];
				}
				if($fields[5]>0.30){
					push @{$speciation_node{$fields[1]}}, $cluster_name;
					$speciation{$fields[1]} += $fields[5];
				}
			}
		}
		close IN;
	}
}
closedir ALEDIR;

print SPECIESTREE "$species_tree";
close SPECIESTREE;
#my $scalar = scalar(keys %nodes); print $scalar;
print NODEEVENTSSTA "Node	Duplication	Transfer	Loss	Speciation\n";
foreach my $key (sort keys %nodes){
	print NODEEVENTSSTA "$key";
	if(exists($duplication{$key})){	
		print NODEEVENTSSTA "	$duplication{$key}";
		my $dups = join ",",@{$duplication_node{$key}};
		print NODEDUP "$key	$dups\n";
	}else{
		print NODEEVENTSSTA "	0";	
	}
	
	if(exists($transfer{$key})){
		print NODEEVENTSSTA "	$transfer{$key}";
		my $hgts = join ",",@{$transfer_node{$key}};
		print NODEHGT "$key	$hgts\n";
	}else{ 
		print NODEEVENTSSTA "	0";
	}
	
	if(exists($loss{$key})){	
		print NODEEVENTSSTA "	$loss{$key}";
		my $losses = join ",",@{$loss_node{$key}};
		print NODELOSS "$key	$losses\n";
	}else{ 
		print NODEEVENTSSTA "	0";
	}
	
	if(exists($speciation{$key})){	
		print NODEEVENTSSTA "	$speciation{$key}";
		my $specs = join ",",@{$speciation_node{$key}};
		print NODESPEC "$key	$specs\n";
	}else{ 
		print NODEEVENTSSTA "	0";
	}
	print NODEEVENTSSTA "\n";
}
close NODELOSS;
close NODEDUP;
close NODEHGT;
close NODESPEC;
