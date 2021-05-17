# Copyright (c) 2019-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#

set -e


#
# Data preprocessing configuration
#
N_MONO=5000000  # number of monolingual sentences for each language
CODES=60000     # number of BPE codes
N_THREADS=16    # number of threads in data preprocessing


#
# Read arguments
#
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  --src)
    SRC="$2"; shift 2;;
  --tgt)
    TGT="$2"; shift 2;;
  --reload_codes)
    RELOAD_CODES="$2"; shift 2;;
  --reload_vocab)
    RELOAD_VOCAB="$2"; shift 2;;
  *)
  POSITIONAL+=("$1")
  shift
  ;;
esac
done
set -- "${POSITIONAL[@]}"


#
# Check parameters
#
if [ "$SRC" == "" -o "$TGT" == "" ]; then SRC="li" TGT="du"; echo "source limburgs target dutch"; fi
if [ "$TGT" == "" ]; then echo "--tgt not provided"; exit; fi
if [ "$SRC" != "de" -a "$SRC" != "en" -a "$SRC" != "li" -a "$SRC" != "du" ]; then echo "unknown source language"; exit; fi
if [ "$TGT" != "de" -a "$TGT" != "en" -a "$TGT" != "li" -a "$TGT" != "du" ]; then echo "unknown target language"; exit; fi
if [ "$SRC" == "$TGT" ]; then echo "source and target cannot be identical"; exit; fi


#
# Initialize tools and data paths
#

N_PATH=/content/drive/My\Drive/facebook_XLM/XLM 

if [ "$SRC" == "li" -a "$TGT" == "du" ];
then 
	echo "--src set as limburgs --tgt set as dutch";
else
	echo "--src set as dutch --tgt set as limburgs";
fi


SRC_PATH=/content/drive/My\Drive/facebook_XLM/Assets/Dutch_corpus
TGT_PATH=/content/drive/My\Drive/facebook_XLM/Assets/Lim_corpus


if [ "$SRC" == "li" -a "$TGT" == "du" ];
	then 	SRC_PATH=/content/drive/My\Drive/facebook_XLM/Assets/Lim_corpus
		TGT_PATH=/content/drive/My\Drive/facebook_XLM/Assets/Dutch_corpus; 
	echo $SRC_PATH $TGT_PATH;
fi 


echo $SRC_PATH;
echo $TGT_PATH;

A_PATH=/content/drive/My\Drive/facebook_XLM/Assets

chmod 755 $SRC_PATH/*;
chmod 755 $TGT_PATH/*;


#Locations inside of drive
SRC_TRAIN=$SRC_PATH/train_n.txt
SRC_TEST=$SRC_PATH/test_n.txt

TGT_TRAIN=$TGT_PATH/train_n.txt
TGT_TEST=$TGT_PATH/test_n.txt

#Folders for parallel data
PARA_PATH=$A_PATH/para


DATA_PATH=$N_PATH/data
TOOLS_PATH=$N_PATH/tools
PROC_PATH=$DATA_PATH/processed/$SRC-$TGT


# create paths
mkdir -p $TOOLS_PATH
mkdir -p $DATA_PATH
mkdir -p $PARA_PATH
mkdir -p $PROC_PATH


########################
#
# FAIR BIT OF WARINING: The tokenized files will NOT be stored in Assets folder
#                       Look at proc folder, might be changed later. 
#                       For now need to get this to work
#
########################

# moses
MOSES=$TOOLS_PATH/mosesdecoder
REPLACE_UNICODE_PUNCT=$MOSES/scripts/tokenizer/replace-unicode-punctuation.perl
NORM_PUNC=$MOSES/scripts/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$MOSES/scripts/tokenizer/remove-non-printing-char.perl
TOKENIZER=$MOSES/scripts/tokenizer/tokenizer.perl
INPUT_FROM_SGM=$MOSES/scripts/ems/support/input-from-sgm.perl

# fastBPE
FASTBPE_DIR=$TOOLS_PATH/fastBPE
FASTBPE=$TOOLS_PATH/fastBPE/fast

# raw and tokenized files
SRC_TRAIN_RAW=$SRC_TRAIN
TGT_TRAIN_RAW=$TGT_TRAIN
SRC_TRAIN_TOK=$SRC_RAW.tok
TGT_TRAIN_TOK=$TGT_RAW.tok

# BPE / vocab files
BPE_CODES=$PROC_PATH/codes
SRC_VOCAB=$PROC_PATH/vocab.$SRC
TGT_VOCAB=$PROC_PATH/vocab.$TGT
FULL_VOCAB=$PROC_PATH/vocab.$SRC-$TGT

# train / valid / test monolingual BPE data
SRC_TRAIN_BPE=$PROC_PATH/train.$SRC
TGT_TRAIN_BPE=$PROC_PATH/train.$TGT
SRC_VALID_BPE=$PROC_PATH/valid.$SRC
TGT_VALID_BPE=$PROC_PATH/valid.$TGT
SRC_TEST_BPE=$PROC_PATH/test.$SRC
TGT_TEST_BPE=$PROC_PATH/test.$TGT

# valid / test parallel BPE data
PARA_SRC_VALID_BPE=$PROC_PATH/valid.$SRC-$TGT.$SRC
PARA_TGT_VALID_BPE=$PROC_PATH/valid.$SRC-$TGT.$TGT
PARA_SRC_TEST_BPE=$PROC_PATH/test.$SRC-$TGT.$SRC
PARA_TGT_TEST_BPE=$PROC_PATH/test.$SRC-$TGT.$TGT

# concatenate monolingual data files

echo "Concatination of traing data not required. If the requirements have changed, please see get-data-nmt.sh and adjust accordingly in this region of the file.";


