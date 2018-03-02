#!/bin/bash

# about to do some parallel work...
declare -A do_parallel

TIME_FORMAT='command:%C\\nreal:%e\\nuser:%U\\nsys:%S\\npctCpu:%P\\ntext:%Xk\\ndata:%Dk\\nmax:%Mk\\n';

# declare function to run parallel processing
run_parallel () {
  # adapted from: http://stackoverflow.com/a/18666536/4460430
  local max_concurrent_tasks=$1
  local -A pids=()

  for key in "${!do_parallel[@]}"; do
    while [ $(jobs 2>&1 | grep -c Running) -ge "$max_concurrent_tasks" ]; do
      sleep 1 # gnu sleep allows floating point here...
    done

    CMD="/usr/bin/time -f $TIME_FORMAT -o $OUTPUT_DIR/timings/${PROTOCOL}_${NAME_MT}_vs_${NAME_WT}.time.$key ${do_parallel[$key]}"

    echo -e "\tStarting $key"
    set -x
    bash -c "$CMD" &
    set +x
    pids+=(["$key"]="$!")
  done

  errors=0
  for key in "${!do_parallel[@]}"; do
    pid=${pids[$key]}
    local cur_ret=0
    if [ -z "$pid" ]; then
      echo "No Job ID known for the $key process" # should never happen
      cur_ret=1
    else
      wait $pid
      cur_ret=$?
    fi
    if [ "$cur_ret" -ne 0 ]; then
      errors=$(($errors + 1))
      echo "$key (${do_parallel[$key]}) failed."
    fi
  done

  return $errors
}

set -e

echo -e "\nStart workflow: `date`\n"

if [[ $# -eq 1 ]] ; then
  PARAM_FILE=$1
elif [ -z ${PARAM_FILE+x} ] ; then
  PARAM_FILE=$HOME/run.params
fi

echo "Loading user options from: $PARAM_FILE"
if [ ! -f $PARAM_FILE ]; then
  echo -e "\tERROR: file indicated by PARAM_FILE not found: $PARAM_FILE" 1>&2
  exit 1
fi
source $PARAM_FILE
env

if [ -z ${CPU+x} ]; then
  CPU=`grep -c ^processor /proc/cpuinfo`
fi

# create area which allows monitoring site to be started, not actively updated until after PRE-EXEC completes
#cp -r /opt/wtsi-cgp/site $OUTPUT_DIR/site

echo -e "\tBAM_MT : $BAM_MT"
echo -e "\tBAM_WT : $BAM_WT"

set -u

TMP=$OUTPUT_DIR/tmp
mkdir -p $TMP
mkdir -p $OUTPUT_DIR/timings

## get sample names from BAM headers
NAME_MT=`samtools view -H $BAM_MT | perl -ne 'chomp; if($_ =~ m/^\@RG/) {($sm) = $_ =~m/\tSM:([^\t]+)/; print "$sm\n";}' | uniq`
NAME_WT=`samtools view -H $BAM_WT | perl -ne 'chomp; if($_ =~ m/^\@RG/) {($sm) = $_ =~m/\tSM:([^\t]+)/; print "$sm\n";}' | uniq`

echo -e "\tNAME_MT : $NAME_MT"
echo -e "\tNAME_WT : $NAME_WT"

# capture index extension type (assuming same from both)
ALN_EXTN='bam'
IDX_EXTN=''
if [[ "$IDX_MT" == *.bam.bai ]]; then
  IDX_EXTN='bam.bai'
elif [[ "$IDX_MT" == *.bam.csi ]]; then
  IDX_EXTN='bam.csi'
elif [[ "$IDX_MT" == *.cram.crai ]]; then
  IDX_EXTN='cram.crai'
  ALN_EXTN='cram'
else
  echo "Alignment is not BAM or CRAM file: $" >&2
  exit 1
fi

BAM_MT_TMP=$TMP/$NAME_MT.$ALN_EXTN
IDX_MT_TMP=$TMP/$NAME_MT.$IDX_EXTN
BAM_WT_TMP=$TMP/$NAME_WT.$ALN_EXTN
IDX_WT_TMP=$TMP/$NAME_WT.$IDX_EXTN

ln -fs $BAM_MT $BAM_MT_TMP
ln -fs $IDX_MT $IDX_MT_TMP
ln -fs $BAM_WT $BAM_WT_TMP
ln -fs $IDX_WT $IDX_WT_TMP

echo "Setting up Parallel block 1"

if [ ! -f "${BAM_MT}.bas" ]; then
  echo -e "\t[Parallel block 1] BAS $NAME_MT added..."
  do_parallel[bas_MT]="bam_stats -i $BAM_MT_TMP -o $BAM_MT_TMP.bas"
else
  ln -fs $BAM_MT.bas $BAM_MT_TMP.bas
fi

if [ ! -f "${BAM_WT}.bas" ]; then
  echo -e "\t[Parallel block 1] BAS $NAME_WT added..."
  do_parallel[bas_WT]="bam_stats -i $BAM_WT_TMP -o $BAM_WT_TMP.bas"
else
  ln -fs $BAM_WT.bas $BAM_WT_TMP.bas
fi

if [ "$ALN_EXTN" == "cram" ]; then
  ## prime the cache
  USER_CACHE=$OUTPUT_DIR/ref_cache
  export REF_CACHE=$USER_CACHE/%2s/%2s/%s
  export REF_PATH=$REF_CACHE:http://www.ebi.ac.uk/ena/cram/md5/%s
  do_parallel[cache_POP]="seq_cache_populate.pl -root $USER_CACHE $REF_BASE/genome.fa"
fi

echo "Starting Parallel block 1: `date`"
run_parallel $CPU do_parallel

# unset and redeclare the parallel array ready for block 2
unset do_parallel
declare -A do_parallel

echo -e "\nSetting up Parallel block 2"

echo -e "\t[Parallel block 2] cgpPindel added..."
do_parallel[cgpPindel]="pindel.pl \
 -o $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/pindel \
 -r $REF_BASE/genome.fa \
 -t $BAM_MT_TMP \
 -n $BAM_WT_TMP \
 -s $REF_BASE/pindel/simpleRepeats.bed.gz \
 -u $REF_BASE/pindel/pindel_np.gff3.gz \
 -f $REF_BASE/pindel/${PROTOCOL}_Rules.lst \
 -g $REF_BASE/vagrent/codingexon_regions.indel.bed.gz \
 -st $PROTOCOL \
 -as $ASSEMBLY \
 -sp $SPECIES \
 -e $CONTIG_EXCLUDE \
 -b $REF_BASE/pindel/HiDepth.bed.gz \
 -c $CPU \
 -sf $REF_BASE/pindel/softRules.lst"

# Need empty cn bed for blanket settings
touch $TMP/empty.cn.bed
# Need a germline bed even though not used
echo '#comment' >  $TMP/empty.germline.bed

echo -e "\t[Parallel block 2] CaVEMan added..."
do_parallel[CaVEMan]="caveman.pl \
 -r $REF_BASE/genome.fa.fai \
 -ig $REF_BASE/caveman/HiDepth.tsv \
 -b $REF_BASE/caveman/flagging \
 -ab $REF_BASE/vagrent \
 -u $REF_BASE/caveman \
 -s $SPECIES \
 -sa $ASSEMBLY \
 -t $CPU \
 -st $PROTOCOL \
 -in $TMP/empty.germline.bed \
 -tc $TMP/empty.cn.bed \
 -nc $TMP/empty.cn.bed \
 -td 5 -nd 2 \
 -tb $BAM_MT_TMP \
 -nb $BAM_WT_TMP \
 -c $SNVFLAG \
 -f $REF_BASE/caveman/flagging/flag.to.vcf.convert.ini \
 -o $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/caveman \
 -np $PROTOCOL \
 -tp $PROTOCOL \
 -x $CONTIG_EXCLUDE"

echo "Starting Parallel block 2: `date`"
run_parallel $CPU do_parallel

# unset and redeclare the parallel array ready for block 3
unset do_parallel
declare -A do_parallel

# annotate pindel
rm -f $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/pindel/${NAME_MT}_vs_${NAME_WT}.annot.vcf.gz*
echo -e "\t[Parallel block 3] Pindel_annot added..."
do_parallel[cgpPindel_annot]="AnnotateVcf.pl -t -c $REF_BASE/vagrent/vagrent.cache.gz \
 -i $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/pindel/${NAME_MT}_vs_${NAME_WT}.flagged.vcf.gz \
 -o $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/pindel/${NAME_MT}_vs_${NAME_WT}.annot.vcf"

# annotate caveman
rm -f $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/caveman/${NAME_MT}_vs_${NAME_WT}.annot.muts.vcf.gz*
echo -e "\t[Parallel block 3] CaVEMan_annot added..."
do_parallel[CaVEMan_annot]="AnnotateVcf.pl -t -c $REF_BASE/vagrent/vagrent.cache.gz \
 -i $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/caveman/${NAME_MT}_vs_${NAME_WT}.flagged.muts.vcf.gz \
 -o $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/caveman/${NAME_MT}_vs_${NAME_WT}.annot.muts.vcf"

echo "Starting Parallel block 3: `date`"
run_parallel $CPU do_parallel

# clean up log files
rm -rf $OUTPUT_DIR/${NAME_MT}_vs_${NAME_WT}/*/logs

# cleanup reference area, see ds-cgpwxs.pl
if [ $CLEAN_REF -gt 0 ]; then
  rm -rf $REF_BASE
fi

# cleanup ref cache
if [ "$ALN_EXTN" == "cram" ]; then
  rm -rf $USER_CACHE
fi

echo 'Package results'
# timings first
tar -C $OUTPUT_DIR -zcf $OUTPUT_DIR/${PROTOCOL}_${NAME_MT}_vs_${NAME_WT}.timings.tar.gz timings
tar -C $OUTPUT_DIR -zcf $OUTPUT_DIR/${PROTOCOL}_${NAME_MT}_vs_${NAME_WT}.result.tar.gz ${NAME_MT}_vs_${NAME_WT}
cp $PARAM_FILE $OUTPUT_DIR/${PROTOCOL}_${NAME_MT}_vs_${NAME_WT}.run.params

echo -e "\nWorkflow end: `date`"
