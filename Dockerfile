#
# NCBI BLAST+ Dockerfile
#
# https://github.com/renzok/docker-ncbi-blast-demo
#
# based (not so much anymore) on https://hub.docker.com/r/simonalpha/ncbi-blast-docker/
#
# Provide`s NCBI BLAST+ binaries and demo files

FROM renzok/debian:v1

MAINTAINER Renzo Kottmann <renzo.kottmann@gmail.com> 

ENV BLASTDB=/blast/db \
    BLAST_VERSION="2.2.30"
    
ENV BLAST_DOWNLOAD_FILE=ncbi-blast-${BLAST_VERSION}+-src.tar.gz
    
COPY ${BLAST_DOWNLOAD_FILE} .

RUN apt-get update && apt-get install -y \
      gcc \
      g++ \
      cpio \
      make \
    && curl --remote-name --remote-time \
       "ftp://ftp.ncbi.nih.gov/blast/executables/blast+/${BLAST_VERSION}/${BLAST_DOWNLOAD_FILE}" \
    && tar zxpf ${BLAST_DOWNLOAD_FILE} --strip-components=1 \
    && cd c++ \
    && ./configure  \
       --without-dbapi \
       --without-fastcgi \
       --without-ncbi-c  \
       --without-sss \
       --without-sssdb \
       --without-internal \
       --without-gui \
       --without-local-lbsm \
       --without-connext \
       --without-debug \
       --without-sge \
    && make -j 3 \
    && make install \
    && cd .. \
    && apt-get purge -y g++ gcc cpio make \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf c++ \
    && rm -r /var/lib/apt/lists/* ${BLAST_DOWNLOAD_FILE}

RUN mkdir -p ${BLASTDB}

COPY bet_blaSHV.fasta ${BLASTDB}
COPY query.fasta ${BLASTDB}

VOLUME ${BLASTDB}
