﻿# Copyright (c) Endjin Limited. All rights reserved.
#
# Contains data under the Norwegian licence for Open Government data (NLOD) distributed by
# the Norwegian Costal Administration - https://ais.kystverket.no/
# The license can be found at https://data.norge.no/nlod/en/2.0
# The lines in this file that contain data from this source are annotated with a comment containing "ais.kystverket.no"
# The NLOD applies only to the data in these annotated lines. The license under which you are using this software
# (either the AGPLv3, or a commercial license) applies to the whole file.

Feature: NmeaLineToAisStreamAdapterSpecs
	In order to process the AIS messages in NMEA files
	As a developer
	I want to be able to receive complete AIS message payloads even when they are split over multiple NMEA lines

Scenario: Non-fragmented message received
	# ais.kystverket.no
	When the line to message adapter receives '\s:42,c:1567684904*38\!AIVDM,1,1,,B,33m9UtPP@50wwE:VJW6LS67H01<@,0*3C'
	Then the ais message processor should receive 1 message
    And in ais message 0 the payload should be '33m9UtPP@50wwE:VJW6LS67H01<@' with padding of 0
    And in ais message 0 the source from the first NMEA line should be 42
    And in ais message 0 the timestamp from the first NMEA line should be 1567684904

Scenario: First fragment of two-part message received
	# ais.kystverket.no
	When the line to message adapter receives '\g:1-2-8055,s:99,c:1567685556*4E\!AIVDM,2,1,6,B,53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4l,0*72'
	Then the ais message processor should receive 0 messages

Scenario: Two-fragment message fragments received adjacently
	# ais.kystverket.no
	When the line to message adapter receives '\g:1-2-8055,s:99,c:1567685556*4E\!AIVDM,2,1,6,B,53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4l,0*72'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-2-8055*55\!AIVDM,2,2,6,B,j`888888880,2*2B'
	Then the ais message processor should receive 1 message
	# ais.kystverket.no
    And in ais message 0 the payload should be '53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4lj`888888880' with padding of 2
    And in ais message 0 the source from the first NMEA line should be 99
    And in ais message 0 the timestamp from the first NMEA line should be 1567685556

Scenario: Two-fragment message fragments received with single-fragment message in the middle
	# ais.kystverket.no
	When the line to message adapter receives '\g:1-2-8055,s:99,c:1567685556*4E\!AIVDM,2,1,6,B,53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4l,0*72'
	# ais.kystverket.no
	And the line to message adapter receives '\s:42,c:1567684904*38\!AIVDM,1,1,,B,33m9UtPP@50wwE:VJW6LS67H01<@,0*3C'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-2-8055*55\!AIVDM,2,2,6,B,j`888888880,2*2B'
	Then the ais message processor should receive 2 message
	# ais.kystverket.no
    And in ais message 0 the payload should be '33m9UtPP@50wwE:VJW6LS67H01<@' with padding of 0
    And in ais message 0 the source from the first NMEA line should be 42
    And in ais message 0 the timestamp from the first NMEA line should be 1567684904
	# ais.kystverket.no
    And in ais message 1 the payload should be '53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4lj`888888880' with padding of 2
    And in ais message 1 the source from the first NMEA line should be 99
    And in ais message 1 the timestamp from the first NMEA line should be 1567685556

Scenario: Three-fragment message fragments received adjacently
	# ais.kystverket.no
	When the line to message adapter receives '\g:1-3-3451,s:27,c:1567686150*40\!AIVDM,3,1,9,A,544MR0827oeaD<u0000lDdP4pTf0duAA,0*17'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-3-3451*5F\!AIVDM,3,2,9,A,<uH000167pF=2=nG0:0DRj0CQiC4jh00,0*4A'
	# ais.kystverket.no
	And the line to message adapter receives '\g:3-3-3451*5E\!AIVDM,3,3,9,A,0000000,0*2F'
	Then the ais message processor should receive 1 message
	# ais.kystverket.no
    And in ais message 0 the payload should be '544MR0827oeaD<u0000lDdP4pTf0duAA<uH000167pF=2=nG0:0DRj0CQiC4jh000000000' with padding of 0
    And in ais message 0 the source from the first NMEA line should be 27
    And in ais message 0 the timestamp from the first NMEA line should be 1567686150

Scenario: Interleaved multi-fragment messages
	# ais.kystverket.no
	When the line to message adapter receives '\g:1-3-3451,s:27,c:1567686150*40\!AIVDM,3,1,9,A,544MR0827oeaD<u0000lDdP4pTf0duAA,0*17'
	# ais.kystverket.no
	And the line to message adapter receives '\g:1-2-8055,s:99,c:1567685556*4E\!AIVDM,2,1,6,B,53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4l,0*72'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-3-3451*5F\!AIVDM,3,2,9,A,<uH000167pF=2=nG0:0DRj0CQiC4jh00,0*4A'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-2-8055*55\!AIVDM,2,2,6,B,j`888888880,2*2B'
	# ais.kystverket.no
	And the line to message adapter receives '\g:3-3-3451*5E\!AIVDM,3,3,9,A,0000000,0*2F'
	Then the ais message processor should receive 2 messages
	# ais.kystverket.no
    And in ais message 0 the payload should be '53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4lj`888888880' with padding of 2
    And in ais message 0 the source from the first NMEA line should be 99
    And in ais message 0 the timestamp from the first NMEA line should be 1567685556
	# ais.kystverket.no
    And in ais message 1 the payload should be '544MR0827oeaD<u0000lDdP4pTf0duAA<uH000167pF=2=nG0:0DRj0CQiC4jh000000000' with padding of 0
    And in ais message 1 the source from the first NMEA line should be 27
    And in ais message 1 the timestamp from the first NMEA line should be 1567686150

Scenario: Interleaved single and multi-fragment messages
	# ais.kystverket.no
	When the line to message adapter receives '\s:42,c:1567684904*38\!AIVDM,1,1,,B,33m9UtPP@50wwE:VJW6LS67H01<@,0*3C'
	# ais.kystverket.no
	And the line to message adapter receives '\g:1-3-3451,s:27,c:1567686150*40\!AIVDM,3,1,9,A,544MR0827oeaD<u0000lDdP4pTf0duAA,0*17'
	# ais.kystverket.no
	And the line to message adapter receives '\s:42,c:1567684904*38\!AIVDM,1,1,,A,B3m:H900AP@b:79ae6:<OwnUoP06,0*78'
	# ais.kystverket.no
	And the line to message adapter receives '\s:3,c:1567692251*01\!AIVDM,1,1,,A,13m9WS001d0K==pR=D?HB6WD0pJV,0*54'
	# ais.kystverket.no
	And the line to message adapter receives '\g:1-2-8055,s:99,c:1567685556*4E\!AIVDM,2,1,6,B,53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4l,0*72'
	# ais.kystverket.no
	And the line to message adapter receives '\s:24,c:1567692878*35\!AIVDM,1,1,,B,13o`9@701j1Ej3vc;o3q@7SJ0D02,0*21'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-3-3451*5F\!AIVDM,3,2,9,A,<uH000167pF=2=nG0:0DRj0CQiC4jh00,0*4A'
	# ais.kystverket.no
	And the line to message adapter receives '\s:67,c:1567693000*34\!AIVDM,1,1,,,3CnWHf50000ga40TCHE0D0@R003B,0*4B'
	# ais.kystverket.no
	And the line to message adapter receives '\s:772,c:1567693246*07\!AIVDM,1,1,,,13o7g2001P0Lv<rSdVHf2h3N0000,0*25'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-2-8055*55\!AIVDM,2,2,6,B,j`888888880,2*2B'
	# ais.kystverket.no
	And the line to message adapter receives '\s:722,c:1567693372*04\!AIVDM,1,1,,A,13m63A?P00P`@GFTK3s>4?wR20Sf,0*71'
	# ais.kystverket.no
	And the line to message adapter receives '\g:3-3-3451*5E\!AIVDM,3,3,9,A,0000000,0*2F'
	# ais.kystverket.no
	And the line to message adapter receives '\s:808,c:1567693618*0A\!AIVDM,1,1,,B,B3o8B<00F8:0h694gOtbgwqUoP06,0*73'
	Then the ais message processor should receive 10 messages
	# ais.kystverket.no
    And in ais message 0 the payload should be '33m9UtPP@50wwE:VJW6LS67H01<@' with padding of 0
    And in ais message 0 the source from the first NMEA line should be 42
    And in ais message 0 the timestamp from the first NMEA line should be 1567684904
	# ais.kystverket.no
    And in ais message 1 the payload should be 'B3m:H900AP@b:79ae6:<OwnUoP06' with padding of 0
    And in ais message 1 the source from the first NMEA line should be 42
    And in ais message 1 the timestamp from the first NMEA line should be 1567684904
	# ais.kystverket.no
    And in ais message 2 the payload should be '13m9WS001d0K==pR=D?HB6WD0pJV' with padding of 0
    And in ais message 2 the source from the first NMEA line should be 3
    And in ais message 2 the timestamp from the first NMEA line should be 1567692251
	# ais.kystverket.no
    And in ais message 3 the payload should be '13o`9@701j1Ej3vc;o3q@7SJ0D02' with padding of 0
    And in ais message 3 the source from the first NMEA line should be 24
    And in ais message 3 the timestamp from the first NMEA line should be 1567692878
	# ais.kystverket.no
    And in ais message 4 the payload should be '3CnWHf50000ga40TCHE0D0@R003B' with padding of 0
    And in ais message 4 the source from the first NMEA line should be 67
    And in ais message 4 the timestamp from the first NMEA line should be 1567693000
	# ais.kystverket.no
    And in ais message 5 the payload should be '13o7g2001P0Lv<rSdVHf2h3N0000' with padding of 0
    And in ais message 5 the source from the first NMEA line should be 772
    And in ais message 5 the timestamp from the first NMEA line should be 1567693246
	# ais.kystverket.no
    And in ais message 6 the payload should be '53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4lj`888888880' with padding of 2
    And in ais message 6 the source from the first NMEA line should be 99
    And in ais message 6 the timestamp from the first NMEA line should be 1567685556
	# ais.kystverket.no
    And in ais message 7 the payload should be '13m63A?P00P`@GFTK3s>4?wR20Sf' with padding of 0
    And in ais message 7 the source from the first NMEA line should be 722
    And in ais message 7 the timestamp from the first NMEA line should be 1567693372
	# ais.kystverket.no
    And in ais message 8 the payload should be '544MR0827oeaD<u0000lDdP4pTf0duAA<uH000167pF=2=nG0:0DRj0CQiC4jh000000000' with padding of 0
    And in ais message 8 the source from the first NMEA line should be 27
    And in ais message 8 the timestamp from the first NMEA line should be 1567686150
	# ais.kystverket.no
    And in ais message 9 the payload should be 'B3o8B<00F8:0h694gOtbgwqUoP06' with padding of 0
    And in ais message 9 the source from the first NMEA line should be 808
    And in ais message 9 the timestamp from the first NMEA line should be 1567693618

Scenario: Progress reports
	# ais.kystverket.no
	When the line to message adapter receives '\s:42,c:1567684904*38\!AIVDM,1,1,,B,33m9UtPP@50wwE:VJW6LS67H01<@,0*3C'
	# ais.kystverket.no
	And the line to message adapter receives '\g:1-3-3451,s:27,c:1567686150*40\!AIVDM,3,1,9,A,544MR0827oeaD<u0000lDdP4pTf0duAA,0*17'
	# ais.kystverket.no
	And the line to message adapter receives '\s:42,c:1567684904*38\!AIVDM,1,1,,A,B3m:H900AP@b:79ae6:<OwnUoP06,0*78'
	# ais.kystverket.no
	And the line to message adapter receives '\s:3,c:1567692251*01\!AIVDM,1,1,,A,13m9WS001d0K==pR=D?HB6WD0pJV,0*54,0*63'
	# ais.kystverket.no
	And the line to message adapter receives '\g:1-2-8055,s:99,c:1567685556*4E\!AIVDM,2,1,6,B,53oGfN42=WRDhlHn221<4i@Dr22222222222220`1@O6640Ht50Skp4mR`4l,0*72'
	# ais.kystverket.no
	And the line to message adapter receives '\s:24,c:1567692878*35\!AIVDM,1,1,,B,13o`9@701j1Ej3vc;o3q@7SJ0D02,0*07'
	# ais.kystverket.no
    And the line to message adapter receives a progress report of false, 6, 1234, 6, 1234
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-3-3451*5F\!AIVDM,3,2,9,A,<uH000167pF=2=nG0:0DRj0CQiC4jh00,0*4A'
	# ais.kystverket.no
	And the line to message adapter receives '\s:67,c:1567693000*34\!AIVDM,1,1,,,3CnWHf50000ga40TCHE0D0@R003B,0*4B'
	# ais.kystverket.no
	And the line to message adapter receives '\s:772,c:1567693246*07\!AIVDM,1,1,,,13o7g2001P0Lv<rSdVHf2h3N0000,0*25'
	# ais.kystverket.no
	And the line to message adapter receives '\g:2-2-8055*55\!AIVDM,2,2,6,B,j`888888880,2*2B'
    And the line to message adapter receives a progress report of false, 10, 2345, 4, 1111
	# ais.kystverket.no
	And the line to message adapter receives '\s:722,c:1567693372*04\!AIVDM,1,1,,A,13m63A?P00P`@GFTK3s>4?wR20Sf,0*71'
	# ais.kystverket.no
	And the line to message adapter receives '\g:3-3-3451*5E\!AIVDM,3,3,9,A,0000000,0*2F'
	# ais.kystverket.no
	And the line to message adapter receives '\s:808,c:1567693618*0A\!AIVDM,1,1,,B,B3o8B<00F8:0h694gOtbgwqUoP06,0*73'
    And the line to message adapter receives a progress report of true, 13, 2445, 3, 100
	Then the ais message processor should receive 3 progress reports
    And progress report 0 was false, 6, 4, 1234, 6, 4, 1234
    And progress report 1 was false, 10, 7, 2345, 4, 3, 1111
    And progress report 2 was true, 13, 10, 2445, 3, 3, 100

# TODO:
# Got to end with unclosed fragments (#4067)
# 2nd fragment received without first (#4067)
# 2nd fragment received then first (#4067)
# First fragment has non-zero padding (#4066)