#!/bin/bash

##
#  Switch the TP-LINK HS100 wlan smart plug on and off
#  Tested with firmware 1.0.8
#
ip=$1
port=$2
cmd=$3

check_binaries() {
  command -v nc >/dev/null 2>&1 || { echo >&2 "The nc programme for sending data over the network isn't installed"; exit 2; }
  command -v base64 >/dev/null 2>&1 || { echo >&2 "The base64 programme for decoding base64 encoded strings isn't installed"; exit 2; }
}

payload_on="AAAAKtDygfiL/5r31e+UtsWg1Iv5nPCR6LfEsNGlwOLYo4HyhueT9tTu36Lfog=="

payload_off="AAAAKtDygfiL/5r31e+UtsWg1Iv5nPCR6LfEsNGlwOLYo4HyhueT9tTu3qPeowAAAC3Q8oH4i/+a
99XvlLbFoNSL+Zzwkei3xLDRpcDi2KOB5Jbku9i307aUrp7jnuM="

payload_query="AAAAI9Dw0qHYq9+61/XPtJS20bTAn+yV5o/hh+jK8J7rh+vLtpbr"

payload_uptime="AAAAP9DygeKK74v+kvfV75S20bTAn/GU7JjHpsWx2LfZ+8G6x7qWtMe+zbncsZOp0vCX8obZqtOgyafBroy2zbDNsA=="

# runtime / uptime
#0000003fd0f281e28aef8bfe92f7d5ef94b6d1b4c09ff194ec98c7a6c5b1d8b7d9fbc1bac7ba96b4c7becdb9dcb193a9d2f097f286d9aad3a0c9a7c1ae8cb6cdb0cdb0
#AAAAP9DygeKK74v+kvfV75S20bTAn/GU7JjHpsWx2LfZ+8G6x7qWtMe+zbncsZOp0vCX8obZqtOgyafBroy2zbDNsA==

# set shedule
#00000030d0f281e28aef8bfe92f7d5ef94b6c5a0d48be492f785e488e4bbdeb0d1b3dfba98a2d9fb9ef091f39ffad8e2d3aed3ae
#AAAAMNDygeKK74v+kvfV75S2xaDUi+SS94XkiOS73rDRs9+6mKLZ+57wkfOf+tji067Trg==

# set away
#0000001fd0f293fd89e0bfcba3c6a0d4f6ccb795f297e3bccebbd7b2c1e3d9a2dfa2df
#AAAAH9Dyk/2J4L/Lo8ag1PbMt5Xyl+O8zrvXssHj2aLfot8=


usage() {
 echo Usage:
 echo $0 ip port on/off/query
 echo e.g.: $0 11.11.0.4 9999 on
 exit 1
}

checkarg() {
 name="$1"
 value="$2"

 if [ -z "$value" ]
  then
    echo "missing argument $name"
    usage
 fi
}

checkargs() {
  checkarg "ip" $ip
  checkarg "port" $port
  checkarg "command" $cmd
}

sendtoplug() {
  ip="$1"
  port="$2"
  payload="$3"
  echo -n "$payload" | base64 -d | nc -v $ip $port  || echo couldn''t connect to $ip:$port, nc failed with exit code $?
}


##
#  Main programme
##
checkargs
case "$cmd" in
  on)
  sendtoplug $ip $port "$payload_on" > /dev/null
  ;;
  off)
  sendtoplug $ip $port "$payload_off" > /dev/null
  ;;
  query)
  output=`sendtoplug $ip $port "$payload_query" | base64`
  #outputHex=`sendtoplug $ip $port "$payload_query" | hexdump -v -C`
  #echo $output
  #if [[ $output == AAACJ* ]] ;
  if [[ $output == AAACKND* ]] ;
  then
     echo OFF
  fi
  #if [[ $output == AAACK* ]] ;
  if [[ $output == AAACKdD* ]] ;
  then
     echo ON
  fi
  ;;

  uptime)
  output=`sendtoplug $ip $port "$payload_uptime" | base64`
  #outputx=`sendtoplug $ip $port "$payload_uptime" | hexdump -v -C`
  #echo ---------------------------------
  echo $output
  #echo ---------------------------------
  #echo $outputx
  #echo ---------------------------------

  ;;

  *)
  usage
  ;;
esac
exit 0

