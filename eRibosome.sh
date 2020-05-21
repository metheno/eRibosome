#!/bin/bash

#======================================
# eRibosome by metheno
# https://github.com/metheno/eRibosome
#======================================

PROGNAME=$0
PROGVER=0.1.2

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
bold='\033[1m'
plain='\033[0m'

DNA_SEQ=""

declare -a CODON=(ATA ATC ATT ATG ACA ACC ACG ACT AAC AAT AAA AAG AGC AGT AGA AGG CTA CTC CTG CTT CCA CCC CCG CCT CAC CAT CAA CAG CGA CGC CGG CGT GTA GTC GTG GTT GCA GCC GCG GCT GAC GAT GAA GAG GGA GGC GGG GGT TCA TCC TCG TCT TTC TTT TTA TTG TAC TAT TAA TAG TGC TGT TGA TGG)
declare -a AMINO=(I-Ile I-Ile I-Ile ${green}M-Met${plain} T-Thr T-Thr T-Thr T-Thr N-Asn N-Asn K-Lys K-Lys S-Ser S-Ser R-Arg R-Arg L-Leu L-Leu L-Leu L-Leu P-Pro P-Pro P-Pro P-Pro H-His H-His Q-Gln Q-Gln R-Arg R-Arg R-Arg R-Arg V-Val V-Val V-Val V-Val A-Ala A-Ala A-Ala A-Ala D-Asp D-Asp E-Glu E-Glu G-Gly G-Gly G-Gly G-Gly S-Ser S-Ser S-Ser S-Ser F-Phe F-Phe L-Leu L-Leu Y-Tyr Y-Tyr ${red}-----${plain} ${red}-----${plain} C-Cys C-Cys ${red}-----${plain} W-Trp)
declare -a PROPT=(NON-POLAR NON-POLAR NON-POLAR NON-POLAR ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${green}+1${plain} ${green}+1${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${green}+1${plain} ${green}+1${plain} NON-POLAR NON-POLAR NON-POLAR NON-POLAR SPECIAL SPECIAL SPECIAL SPECIAL ${green}+1${plain} ${green}+1${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${green}+1${plain} ${green}+1${plain} ${green}+1${plain} ${green}+1${plain} NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR ${red}-1${plain} ${red}-1${plain} ${red}-1${plain} ${red}-1${plain} SPECIAL SPECIAL SPECIAL SPECIAL ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} ${yellow}POLAR${plain} NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR NON-POLAR STOP STOP SPECIAL SPECIAL STOP NON-POLAR)

purify_file() {
	DNA_SEQ=`echo $(<$1) | tr "[:lower:]U" "[:upper:]T" | tr -d "\n" | sed "s/[^ATGC]*//g"`
	empty_check ${DNA_SEQ}
}

purify_console() {
	DNA_SEQ=`echo "$1" | tr "[:lower:]U" "[:upper:]T" | tr -d "\n" | sed "s/[^ATGC]*//g"`
	empty_check ${DNA_SEQ}
}

empty_check() {
	if [ -z "$1" ]; then
		echo -e "${red}ERROR${plain}: DNA sequence empty."
		exit 1
	fi
	echo -e "DNA sequence:  ${green}${1}${plain}"
	polypeptide ${1}
}

binding_site_p() {
	FSEQ=`echo ${1} | tr "T" "U"`
	SDSEQ="" && AUG="" && i=0 && ELSEQ=""
	echo -e "mRNA sequence: ${yellow}${FSEQ}${plain}"
	while [ $i -lt "${#FSEQ}" ]; do
		if [ "${SDSEQ}" != "AGGAGG" ] && [ "${FSEQ:$i:1}" == "A" ] && [ "${FSEQ:$i+1:5}" == "GGAGG" ]; then
			SDSEQ=`echo "${FSEQ:$i:1}${FSEQ:$i+1:5}"`
		fi
		if [ "${SDSEQ}" == "AGGAGG" ] && [ "${FSEQ:$i:1}" == "A" ] && [ "${FSEQ:$i+1:2}" == "UG" ]; then
			AUG=`echo "${FSEQ:$i:1}${FSEQ:$i+1:2}"`
		fi
		if [ "${SDSEQ}" == "AGGAGG" ] && [ "${AUG}" == "AUG" ]; then
			ELSEQ=`echo "${FSEQ:$i:$((${#FSEQ} - i))}"`
			break
		fi
		i=$(($i + 1))
	done
	echo "Starting point of translation: ${ELSEQ}"
}

cd .g	

polypeptide() {
	echo -ne "Polypeptide: \n"
	for ((i = 0; i < ${#1}; i+=3)); do
		seq=`echo -e "${DNA_SEQ:$i:3}"`
		for ((j = 0; j < 64; j++)); do
			if [ "${seq}" == "${CODON[j]}" ]; then
				echo -e "$((i/3+1)):\t${green}${CODON[j]}${plain}  ${bold}${AMINO[j]}${plain}  ${PROPT[j]}"
			fi
		done
		sleep 0.01
		if [ $(( $((i/3+1)) % 10 )) -eq 0 ]; then
			echo -e "--------------$((i/3+1))--------------"
		fi
	done
	echo -e "Translation complete!"
}

usage() {
	cat << EOF >&2

${PROGNAME}

Usage: ${PROGNAME} [-f <path>] [-h] [-i <seq>] [-v]
-f:	translate a DNA/mRNA sequence from a file
-i:	translate a DNA/mRNA sequence provided in console

-h:	displays help message
-v:	displays version

Note: ${PROGNAME} reads the coding strand of dsDNA.
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
