#!/bin/bash

#======================================
# eRibosome by metheno
# https://github.com/metheno/eRibosome
#======================================

PROGNAME=$0
PROGVER=0.1.1

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
bold='\033[1m'
plain='\033[0m'

DNA_SEQ=""

tabs 6

declare -a CODON=(ATA ATC ATT ATG ACA ACC ACG ACT AAC AAT AAA AAG AGC AGT AGA AGG CTA CTC CTG CTT CCA CCC CCG CCT CAC CAT CAA CAG CGA CGC CGG CGT GTA GTC GTG GTT GCA GCC GCG GCT GAC GAT GAA GAG GGA GGC GGG GGT TCA TCC TCG TCT TTC TTT TTA TTG TAC TAT TAA TAG TGC TGT TGA TGG)
declare -a AMINO=(I-Ile I-Ile I-Ile ${green}M-Met${plain} T-Thr T-Thr T-Thr T-Thr N-Asn N-Asn K-Lys K-Lys S-Ser S-Ser R-Arg R-Arg L-Leu L-Leu L-Leu L-Leu P-Pro P-Pro P-Pro P-Pro H-His H-His Q-Gln Q-Gln R-Arg R-Arg R-Arg R-Arg V-Val V-Val V-Val V-Val A-Ala A-Ala A-Ala A-Ala D-Asp D-Asp E-Glu E-Glu G-Gly G-Gly G-Gly G-Gly S-Ser S-Ser S-Ser S-Ser F-Phe F-Phe L-Leu L-Leu Y-Tyr Y-Tyr ${red}-----${plain} ${red}-----${plain} C-Cys C-Cys ${red}-----${plain} W-Trp)
declare -a PROPT=(NON-POLAR NON-POLAR NON-POLAR NON-POLAR ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${green}+1${plain} ${green}+1${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${green}+1${plain} ${green}+1${plain} NON-POLAR NON-POLAR NON-POLAR NON-POLAR SPECIAL SPECIAL SPECIAL SPECIAL ${green}+1${plain} ${green}+1${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${green}+1${plain} ${green}+1${plain} ${green}+1${plain} ${green}+1${plain} NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR ${red}-1${plain} ${red}-1${plain} ${red}-1${plain} ${red}-1${plain} SPECIAL SPECIAL SPECIAL SPECIAL ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR STOP STOP SPECIAL SPECIAL STOP NON-POLAR)

purify_file() {
	DNA_SEQ=`echo $(<$1) | tr "[:lower:]U" "[:upper:]T" | tr -d "\n" | sed "s/[^ATGC]*//g"`
	sequence_check ${DNA_SEQ}
}

purify_console() {
	DNA_SEQ=`echo "$1" | tr "[:lower:]U" "[:upper:]T" | tr -d "\n" | sed "s/[^ATGC]*//g"`
	sequence_check ${DNA_SEQ}
}

sequence_check() {
	if [ -z "$1" ]; then
		echo -e "${red}ERROR${plain}: DNA sequence empty."
		exit 1
	fi
	echo -e "DNA sequence: ${green}${DNA_SEQ}${plain}"
	polypeptide ${1}
}

polypeptide() {
	if [ `expr ${#1} % 3` == 0 ]; then
		echo -ne "Polypeptide: \n"
		for ((i = 0; i < ${#1}; i+=3)); do
			seq=`echo -e "${DNA_SEQ:$i:3}"`
			for ((j = 0; j < 64; j++)); do
				if [ "${seq}" == "${CODON[j]}" ]; then
					echo -e "$((i/3+1)):\t${green}${CODON[j]}${plain}  ${bold}${AMINO[j]}${plain}  ${bold}${PROPT[j]}${plain}"
				fi
			done
			sleep 0.01
			if [ $(( $((i/3+1)) % 10 )) -eq 0 ]; then
				echo -e "--------------$((i/3+1))--------------"
			fi
		done
		echo -e "Translation complete!"
		exit 0
	else
		echo -e "${red}ERROR${plain}: DNA sequence invalid."
	fi
}

usage() {
	cat << EOF >&2

${PROGNAME}

Usage: ${PROGNAME} [-f <path>] [-h] [-i <seq>] [-v]
-f:	translate a DNA sequence from a file
-h:	displays help message
-i:	translate a DNA sequence provided in console
-v:	displays version

Note: ${PROGNAME} translates DNA from 5' to 3'.
      ${PROGNAME} has mRNA capability.

EOF
	exit 1
}

while getopts ":f:hi:v" o; do
	case "${o}" in
		f)	purify_file ${OPTARG} ;;
		h)	usage
			exit 0
			;;
		i)	purify_console ${OPTARG} ;;
		v)	echo -e "${PROGNAME} version: ${green}${PROGVER}${plain}" 
			;;
		\?)	echo -e "${red}\nERROR${plain}: unknown option -${OPTARG}"
			usage
			exit 1
			;;	
	esac
done

if [ $OPTIND -eq 1 ]; then 
	echo -e "${red}\nERROR${plain}: non-option"
	usage
	exit 1
fi

shift "$((OPTIND - 1))"
