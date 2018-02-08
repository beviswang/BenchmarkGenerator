#!/usr/local/bin/perl
#use strict;
use POSIX;

#-------------------------------#
### Define of HW Module Config Address ###
my $GLB_base = 0x0;
my $GLB_shift = 0;
my $MCIF_base = 0x0;
my $MCIF_shift = 0;
my $SRAMIF_base = 0x0;
my $SRAMIF_shift = 0;
my $BDMA_base = 0xffff1001;
my $BDMA_shift = 12;
my $CDMA_base = 0xffff1401;
my $CDMA_shift = 57;
my $CSC_base = 0xffff1801;
my $CSC_shift = 24;
my $CMAC_A_base = 0xffff1c01;
my $CMAC_A_shift = 2;
my $CMAC_B_base = 0xffff2001;
my $CMAC_B_shift = 2;
my $CACC_base = 0xffff2401;
my $CACC_shift = 12;
my $SDP_RDMA_base = 0xffff2810;
my $SDP_RDMA_shift = 9;
my $SDP_base = 0xffff2c01;
my $SDP_shift = 13;
my $PDP_RDMA_base = 0xffff3001;
my $PDP_RDMA_shift = 15;
my $PDP_base = 0xffff3401;
my $PDP_shift = 32;
my $CDP_RDMA_base = 0x0;
my $CDP_RDMA_shift = 0;
my $CDP_base = 0x0;
my $CDP_shift = 0;
my $RUBIK_base = 0x0;
my $RUBIK_shift = 0;

### Define of HW Module ENABLE Address ###
my $MCIF_EN = 0x0;
my $SRAMIF_EN = 0x0;
my $BDMA_EN = 0xffff100d;
my $CDMA_EN = 0xffff1404;
my $CSC_EN = 0xffff1802;
my $CMAC_A_EN = 0xffff1c02;
my $CMAC_B_EN = 0xffff2002;
my $CACC_EN = 0xffff2402;
my $SDP_RDMA_EN = 0xffff2802;
my $SDP_EN = 0xffff2c0e;
my $PDP_RDMA_EN = 0xffff3002;
my $PDP_EN = 0xffff3402;
my $CDP_RDMA_EN = 0x0;
my $CDP_EN = 0x0;
my $RUBIK_EN = 0x0;

### Default config hash ###
#####################
# Load
my %dataLoad;
# BDMA
my %confBDMA = (
	
);

# CDMA
my %confCDMA;
# CSC
my %confCSC;
# CMAC_A
my %confCMAC_A;
# CMAC_B
my %confCMAC_B;
# CACC
my %confCACC;
# SDP_RDMA
my %confSDP_RDMA;
# SDP
my %confSDP;
# PDP_RDMA
my %confPDP_RDMA;
# PDP
my %confPDP;

#####################

### Print instructions ###
sub printInstr{
	local($op, $base, $shift, %hashTable) = @_;
	local $tmpBase, $tmpVal;
	for(;$shift>=0;$shift--){
		$tmpBase = sprintf("0x%x", $base);
		if($hashTable{$base} == undef){
			print FILEOUT "$op $tmpBase 0x0\n";
		}else{
			$tmpVal = sprintf("0x%x", $hashTable{$base});
			print FILEOUT "$op $tmpBase $tmpVal\n";
		}
		$base++;
	}
}

#-------------------------------#

### Define of Parameters of layer ###
my $index = 0;
my $attribute;

my $numInputFeatureMapsC = $numInputFeatureMapsC0;
my $lenInputHeightH = $lenInputHeightH0;
my $lenInputWidthW = $lenInputWidthW0;
my $numOutputFeatureMapsK;
my $lenFilterHeightR;
my $lenFilterWidthS;
my $swZeroPaddingZ;
my $lenVerticalConvStrideH = 9999;
my $lenHorizontalConvStrideV = 9999;

my $lenHeightAfterConvP;
my $lenWidthAfterConvQ;

my $swPoolingConv;
my $lenPoolingHeightD;
my $lenPoolingWidthE;
my $lenVerticalPoolingStrideF = 9999;
my $lenHorizontalPoolingStrideG = 9999;

my $lenHeightAfterPoolingA;
my $lenWidthAfterPoolingB;

# Activation
my $chOutputFeatureMaps;
my $lenHeightAfter;
my $lenWidthAfter;

#-------------------------------#
### Define of Mid Results ###
my $sizeInputData;
my $sizeWeightData;

#-------------------------------#
### Define of File ###
my $filenameInput = "mnist.json";
my $filenameOutput = "input.txn";

my $command = '';
while(!$command){
	$command = shift;
	if($command eq '-f'){
		$command = shift;
		$filenameInput = $command;
	}
	if($command eq '-o'){
		$command = shift;
		$filenameOutput = $command;
	}
}

# Open files
open (FILEIN, $filenameInput);
open (FILEOUT, '>', $filenameOutput);

# Parameters
my $flag = "none";
my $tmp;
my $resultCnt = 0;
my $tmpHex;

# Input
$numInputFeatureMapsC = $numInputFeatureMapsC0;
$lenInputHeightH = $lenInputHeightH0;
$lenInputWidthW = $lenInputWidthW0;
	
# Main loop for parsing
while ($record = <FILEIN>) {
   # print "$record\n";
   # Decider
   if($record =~ /"op": "(.*)"/i){
		$tmp = $1;
		if($1 =~ /conv/ || $1 =~ /pool/ || $1 =~ /dense/ || $1 =~ /relu/){
			$flag = $tmp;
			print "$tmp\n";
		}
   }elsif($record =~ /},/ && $flag =~ /^((?!none).)*$/){
		if($flag =~ /conv/ || $flag =~ /dense/){
			# Calculate num of layer
			$index++;$swPoolingConv="TRUE";
			# Calculate activation
			$lenHeightAfter = ceil($lenInputHeightH/$lenVerticalConvStrideH);
			$lenWidthAfter = ceil($lenInputWidthW/$lenHorizontalConvStrideV);
			# Record
			$lenHeightAfterConvP = $lenHeightAfter;
			$lenWidthAfterConvQ = $lenWidthAfter;
			# Assign output feature map, show # of Output Feature Maps(K)
			$numOutputFeatureMapsK = $chOutputFeatureMaps;
			
			$sizeInputData = ceil(ceil($numInputFeatureMapsC * $lenVerticalConvStrideH * $lenHorizontalConvStrideV / 16.0)
									* 16.0 
									* ceil($lenInputHeightH / $lenVerticalConvStrideH)
									* ceil($lenInputWidthW / $lenHorizontalConvStrideV)
									* $byteInputData);
			
			$sizeWeightData = ceil(ceil($numInputFeatureMapsC * $lenVerticalConvStrideH * $lenHorizontalConvStrideV / 16.0)
									* 16.0
									* ceil($lenFilterHeightR / $lenVerticalConvStrideH)
									* ceil($lenFilterWidthS / $lenHorizontalConvStrideV)
									* $numOutputFeatureMapsK
									* $byteWeightData);

			
			### Generate (1)input feature map (2)weight instructions ###
			# Gen hash table of load data
			$tmpHex = sprintf("0x%x",$sizeInputData);
			$dataLoad{0x80000000} = $tmpHex;
			$tmpHex = sprintf("0x%x",$sizeWeightData);
			$dataLoad{0x80100000} = $tmpHex;
			print FILEOUT "\n\n";
			printInstr('load_mem', 0x80000000, 0, %dataLoad);
			printInstr('load_mem', 0x80100000, 0, %dataLoad);
			
			### Generate conv and dense instructions ###
			# BDMA
			printInstr('write_reg', $BDMA_base, $BDMA_shift, %confBDMA);
			# CDMA
			printInstr('write_reg', $CDMA_base, $CDMA_shift, %confCDMA);
			# CSC
			printInstr('write_reg', $CSC_base, $CSC_shift, %confCSC);
			# CMAC_A
			printInstr('write_reg', $CMAC_A_base, $CMAC_A_shift, %confCMAC_A);
			# CMAC_B
			printInstr('write_reg', $CMAC_B_base, $CMAC_B_shift, %confCMAC_B);
			# CACC
			printInstr('write_reg', $CACC_base, $CACC_shift, %confCACC);
						
			# Assign activation(assign after output)
			$numInputFeatureMapsC = $chOutputFeatureMaps;
			$lenInputHeightH = $lenHeightAfter;
			$lenInputWidthW = $lenWidthAfter;

			$resultCnt++;
		}
		if($flag =~ /relu/){
			$resultCnt += 2;
			
			### Generate relu instructions
			# SDP_RDMA
			printInstr('write_reg', $SDP_RDMA_base, $SDP_RDMA_shift, %confSDP_RDMA);
			# SDP
			printInstr('write_reg', $SDP_base, $SDP_shift, %confSDP);
			print FILEOUT "";
		}
		if($flag =~ /pool/){
			# Calculate activation
			$lenHeightAfter = ceil(($lenHeightAfter-$lenPoolingHeightD)/$lenVerticalPoolingStrideF);
			$lenWidthAfter = ceil(($lenWidthAfter-$lenPoolingWidthE)/$lenHorizontalPoolingStrideG);

			# Record
			$lenHeightAfterPoolingA = $lenHeightAfter;
			$lenWidthAfterPoolingB = $lenWidthAfter;
		
			# Assign activation(assign after output)
			$numInputFeatureMapsC = $chOutputFeatureMaps;
			$lenInputHeightH = $lenHeightAfter;
			$lenInputWidthW = $lenWidthAfter;
			
			$resultCnt += 4;
			
			### Generate pool instructions
			# PDP_RDMA
			printInstr('write_reg', $PDP_RDMA_base, $PDP_RDMA_shift, %confPDP_RDMA);
			# PDP
			printInstr('write_reg', $PDP_base, $PDP_shift, %confPDP);
			print FILEOUT "";
		}
		$flag = "none";
		
		
   }else{
		if($flag =~ /conv/ || $flag =~ /pool/ || $flag =~ /dense/ || $flag =~ /relu/){
			
		}else{
			next;
		}
   }

   # Check convolution
   if($flag =~ /conv/){
		if($record =~ /"(.*)": "(.*)"/i){
			$tmp = $2;
			if($1 =~ /name/){
				$attribute = $tmp;
				print "$tmp\n";
			}
			if($1 =~ /channels/){
				$chOutputFeatureMaps = $tmp;
				print "$tmp\n";
			}
			if($1 =~ /kernel_size/){
				if($tmp =~ /\[(\d+)L, (\d+)L\]/i){
					$lenFilterHeightR = $1;
					$lenFilterWidthS = $2;
					print "$tmp, lenFilterHeightR = $1, lenFilterWidthS = $2\n";
				}
			}
			if($1 =~ /padding/){
				$swZeroPaddingZ = "TRUE";
			}
			if($1 =~ /strides/){
				if($tmp =~ /\[(\d+)L, (\d+)L\]/i){
					$lenVerticalConvStrideH = $1;
					$lenHorizontalConvStrideV = $2;
					print "$tmp, lenVerticalConvStrideH = $1, lenHorizontalConvStrideV = $2\n";
				}
			}
		}
   }
   # Check relu
   if($flag =~ /conv/){
		if($record =~ /"(.*)": "(.*)"/i){
			$tmp = $2;
			if($1 =~ /name/){
				$attribute = $tmp;
				print "$tmp\n";
			}
		}
   }
   # Check pooling
   if($flag =~ /pool/){
		if($record =~ /"(.*)": "(.*)"/i){
			$tmp = $2;
			if($1 =~ /name/){
				$attribute = $tmp;
				print "$tmp\n";
			}
			if($1 =~ /padding/){
				# Do nothing
			}
			if($1 =~ /pool_size/){
				if($tmp =~ /\[(\d+)L, (\d+)L\]/i){
					$lenPoolingHeightD = $1;
					$lenPoolingWidthE = $2;
					print "$tmp, lenPoolingHeightD = $1, lenPoolingWidthE = $2\n";
				}
			}
			if($1 =~ /strides/){
				if($tmp =~ /\[(\d+)L, (\d+)L\]/i){
					$lenVerticalPoolingStrideF = $1;
					$lenHorizontalPoolingStrideG = $2;
					print "$tmp, lenVerticalPoolingStrideF = $1, lenHorizontalPoolingStrideG = $2\n";
				}
			}
		}
   }
   # Check fully connected
   if($flag =~ /dense/){
		if($record =~ /"(.*)": "(.*)"/i){
			$tmp = $2;
			if($1 =~ /name/){
				$attribute = $tmp;
				print "$tmp\n";
			}
			if($1 =~ /units/){
				$chOutputFeatureMaps = $tmp;
				print "$tmp\n";
			}
			if($1 =~ /use_bias/){
				# Do nothing
			}
		}
		$lenFilterHeightR = 1;
		$lenFilterWidthS = 1;
		$swZeroPaddingZ = "TRUE";
		$lenVerticalConvStrideH = 1;
		$lenHorizontalConvStrideV = 1;
   }
}

close(FILEIN);
close(FILEOUT); 


