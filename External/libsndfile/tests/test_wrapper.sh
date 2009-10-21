#!/bin/sh

if [ -f tests/sfversion.exe ]; then
	cd tests
	fi

if [ ! -f sfversion.exe ]; then
	echo "Not able to find test executables."
	exit 1
	fi

sfversion=`./sfversion.exe`

# Force exit on errors.
set -e

# generic-tests
uname -a
./error_test.exe
./pcm_test.exe
./ulaw_test.exe
./alaw_test.exe
./dwvw_test.exe
./command_test.exe ver
./command_test.exe norm
./command_test.exe format
./command_test.exe peak
./command_test.exe trunc
./command_test.exe inst
./command_test.exe current_sf_info
./command_test.exe bext
./command_test.exe bextch
./floating_point_test.exe
./checksum_test.exe
./scale_clip_test.exe
./headerless_test.exe
./locale_test.exe
./win32_ordinal_test.exe
./external_libs_test.exe
./cpp_test.exe
echo "----------------------------------------------------------------------"
echo "  $sfversion passed common tests."
echo "----------------------------------------------------------------------"

# aiff-tests
./write_read_test.exe aiff
./lossy_comp_test.exe aiff_ulaw
./lossy_comp_test.exe aiff_alaw
./lossy_comp_test.exe aiff_gsm610
echo "=========================="
echo "./lossy_comp_test.exe aiff_ima"
echo "=========================="
./peak_chunk_test.exe aiff
./header_test.exe aiff
./misc_test.exe aiff
./string_test.exe aiff
./multi_file_test.exe aiff
./aiff_rw_test.exe
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on AIFF files."
echo "----------------------------------------------------------------------"

# au-tests
./write_read_test.exe au
./lossy_comp_test.exe au_ulaw
./lossy_comp_test.exe au_alaw
./lossy_comp_test.exe au_g721
./lossy_comp_test.exe au_g723
./header_test.exe au
./misc_test.exe au
./multi_file_test.exe au
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on AU files."
echo "----------------------------------------------------------------------"

# caf-tests
./write_read_test.exe caf
./lossy_comp_test.exe caf_ulaw
./lossy_comp_test.exe caf_alaw
./header_test.exe caf
./misc_test.exe caf
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on CAF files."
echo "----------------------------------------------------------------------"

# wav-tests
./write_read_test.exe wav
./lossy_comp_test.exe wav_pcm
./lossy_comp_test.exe wav_ima
./lossy_comp_test.exe wav_msadpcm
./lossy_comp_test.exe wav_ulaw
./lossy_comp_test.exe wav_alaw
./lossy_comp_test.exe wav_gsm610
./lossy_comp_test.exe wav_g721
./peak_chunk_test.exe wav
./header_test.exe wav
./misc_test.exe wav
./string_test.exe wav
./multi_file_test.exe wav
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on WAV files."
echo "----------------------------------------------------------------------"

# w64-tests
./write_read_test.exe w64
./lossy_comp_test.exe w64_ima
./lossy_comp_test.exe w64_msadpcm
./lossy_comp_test.exe w64_ulaw
./lossy_comp_test.exe w64_alaw
./lossy_comp_test.exe w64_gsm610
./header_test.exe w64
./misc_test.exe w64
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on W64 files."
echo "----------------------------------------------------------------------"

# rf64-tests
./write_read_test.exe rf64
./header_test.exe rf64
./misc_test.exe rf64
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on RF64 files."
echo "----------------------------------------------------------------------"

# raw-tests
./write_read_test.exe raw
./lossy_comp_test.exe raw_ulaw
./lossy_comp_test.exe raw_alaw
./lossy_comp_test.exe raw_gsm610
./lossy_comp_test.exe vox_adpcm
./raw_test.exe
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on RAW (header-less) files."
echo "----------------------------------------------------------------------"

# paf-tests
./write_read_test.exe paf
./header_test.exe paf
./misc_test.exe paf
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on PAF files."
echo "----------------------------------------------------------------------"

# svx-tests
./write_read_test.exe svx
./header_test.exe svx
./misc_test.exe svx
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on SVX files."
echo "----------------------------------------------------------------------"

# nist-tests
./write_read_test.exe nist
./lossy_comp_test.exe nist_ulaw
./lossy_comp_test.exe nist_alaw
./header_test.exe nist
./misc_test.exe nist
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on NIST files."
echo "----------------------------------------------------------------------"

# ircam-tests
./write_read_test.exe ircam
./lossy_comp_test.exe ircam_ulaw
./lossy_comp_test.exe ircam_alaw
./header_test.exe ircam
./misc_test.exe ircam
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on IRCAM files."
echo "----------------------------------------------------------------------"

# voc-tests
./write_read_test.exe voc
./lossy_comp_test.exe voc_ulaw
./lossy_comp_test.exe voc_alaw
./header_test.exe voc
./misc_test.exe voc
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on VOC files."
echo "----------------------------------------------------------------------"

# mat4-tests
./write_read_test.exe mat4
./header_test.exe mat4
./misc_test.exe mat4
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on MAT4 files."
echo "----------------------------------------------------------------------"

# mat5-tests
./write_read_test.exe mat5
./header_test.exe mat5
./misc_test.exe mat5
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on MAT5 files."
echo "----------------------------------------------------------------------"

# pvf-tests
./write_read_test.exe pvf
./header_test.exe pvf
./misc_test.exe pvf
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on PVF files."
echo "----------------------------------------------------------------------"

# xi-tests
./lossy_comp_test.exe xi_dpcm
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on XI files."
echo "----------------------------------------------------------------------"

# htk-tests
./write_read_test.exe htk
./header_test.exe htk
./misc_test.exe htk
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on HTK files."
echo "----------------------------------------------------------------------"

# avr-tests
./write_read_test.exe avr
./header_test.exe avr
./misc_test.exe avr
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on AVR files."
echo "----------------------------------------------------------------------"

# sds-tests
./write_read_test.exe sds
./header_test.exe sds
./misc_test.exe sds
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on SDS files."
echo "----------------------------------------------------------------------"

# sd2-tests
./write_read_test.exe sd2
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on SD2 files."
echo "----------------------------------------------------------------------"

# wve-tests
./lossy_comp_test.exe wve
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on WVE files."
echo "----------------------------------------------------------------------"

# mpc2k-tests
./write_read_test.exe mpc2k
./header_test.exe mpc2k
./misc_test.exe mpc2k
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on MPC 2000 files."
echo "----------------------------------------------------------------------"

# flac-tests
./write_read_test.exe flac
./string_test.exe flac
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on FLAC files."
echo "----------------------------------------------------------------------"

# vorbis-tests
./ogg_test.exe
./vorbis_test.exe
./lossy_comp_test.exe ogg_vorbis
./string_test.exe ogg
./misc_test.exe ogg
echo "----------------------------------------------------------------------"
echo "  $sfversion passed tests on OGG/VORBIS files."
echo "----------------------------------------------------------------------"

# io-tests
./stdio_test.exe
./pipe_test.exe
./virtual_io_test.exe
echo "----------------------------------------------------------------------"
echo "  $sfversion passed stdio/pipe/vio tests."
echo "----------------------------------------------------------------------"


