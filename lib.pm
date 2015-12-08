#!/usr/bin/perl -w
######################################################################################################
#
# Functions useful to many reports and processes.
#    Copyright (C) 2015  Andrew Nisbet
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# Author:  Andrew Nisbet, Edmonton Public Library
# Created: Wed Sep 9 11:29:32 MDT 2015
# Rev: 
#          0.01.w Dec. 03, 2015 - Add further refinement and output of discarded items with holds.
#
###################################################################################################

use strict;
use warnings;

my $VERSION = "0.01.w";

# Creates a hash reference of the pipe delimited data read from a file.
# param:  String name of fully qualified path to the file where data will be read from.
# param:  List reference of integer that are the 0 based indexes to the columns that make up the key to an entry.
#         The key will be made from only existing columns. If no indexes are selected the function issues
#         an error message and then returns an empty hash reference.
# param:  List reference of integers that are the 0 based indexes to the columns that make up the value to an entry.
#         If the list is empty the value '1' is stored as a default value and a warning message is issued.
# return: Reference to the hash created by the process which will be empty if anything fails.
sub read_file_into_hash_reference( $$$ )
{
	my $hash_ref = {};
	my $file     = shift;
	my $indexes  = shift;
	my $values   = shift;
	if ( ! -s $file )
	{
		printf STDERR "** error can't make hash table from missing or empty file '%s'!\n", $file;
		return $hash_ref;
	}
	if ( ! scalar @{$indexes} )
	{
		printf STDERR "** error no indexes defined for hash key\n", $file;
		return $hash_ref;
	}
	if ( ! scalar @{$values} )
	{
		printf STDERR "* warning no values defined setting values to default of 1.\n", $file;
	}
	open IN, "<$file" or die "** error opening $file, $!\n";
	while (<IN>)
	{
		my $line = $_;
		chomp $line;
		my @cols = split '\|', $line;
		my $key = '';
		my $value = '';
		foreach my $index ( @{$indexes} )
		{
			$key .= $cols[ $index ] . "|" if ( $cols[ $index ] );
		}
		foreach my $index ( @{$values} )
		{
			$value .= $cols[ $index ] . "|" if ( $cols[ $index ] );
		}
		$value = "1" if ( ! $value );
		$hash_ref->{"$key"} = "$value" if ( $key );
	}
	close IN;
	return $hash_ref;
}

# Convert the data structure (hash table reference) in which all the keys have similar
# values into a hash table (reference) that has as its keys, the values from the 
# original table, but the values are a list (reference) of keys from the original table.
# Example:
# Given a hash ref like:
# hash_ref{'111'} = 'abc'
# hash_ref{'222'} = 'abc'
# hash_ref{'333'} = 'abc'
# Create a new hash that looks like
# hash_ref_prime{'abc'} =  ('111', '222', '333')
# param:  hash reference of keys and values.
# return: new hash reference.
sub enlist_values( $ )
{
	my $hash_in = shift;
	my $hash_out= {};
	foreach my $key ( keys %$hash_in )
	{
		my $new_key = $hash_in->{ $key };
		my $value_list_ref = ();
		if ( exists $hash_out->{ $new_key } )
		{
			$value_list_ref = $hash_out->{ $new_key };
		}
		push @{ $value_list_ref }, $key;
		$hash_out->{ $new_key } = $value_list_ref;
	}
	return $hash_out;
}

######## Test data #########
# my $hash_ref = {};
# $hash_ref->{'111'} = 'aaa';
# $hash_ref->{'222'} = 'aaa';
# $hash_ref->{'333'} = 'aaa';
# $hash_ref->{'888'} = 'bbb';
# $hash_ref->{'999'} = 'bbb';
# $hash_ref = enlist_values( $hash_ref );

# foreach  my $key ( keys %$hash_ref )
# {
	# printf STDERR "key: '%s'\n", $key;
	# my $values = $hash_ref->{$key};
	# foreach my $value ( @{$values} )
	# {
		# printf STDERR " +- '%s'\n", $value;
	# }
# }
		
# Produces:
# 1000066|36|Picture books D PBK|0|epl000001956
### Here we create two tables; one for the call num key and one for the item ids callnum key values.
# my @key_indexes     = (4,2);
# my @value_indexes   = (0,1);
# my $master_hash_ref = {};
# $master_hash_ref    = read_file_into_hash_reference( $master_list, \@key_indexes, \@value_indexes );
# $master_hash_ref->{'epl000001956|Picture books D PBK|'} = '1000066|36|'

1;