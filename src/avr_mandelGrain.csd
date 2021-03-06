<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
; Audio out   Audio in    No messages
-odac          ;-iadc          ;;;RT audio I/O
; For Non-realtime ouput leave only the line below:
; -o moogvcf.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

; Initialize the global variables.
sr = 48000 
kr = 480 
ksmps = 100 
nchnls = 2

; Set 0dbfs to 1
0dbfs = 1

giWave  ftgen  3,0,2^10,10,1,1/2,1/4,1/8,1/16,1/32,1/64
giBuzz  ftgen 1,0,4096,11,40,1,0.9
giSine	ftgen 2,0,4096,10,1
giWave	ftgen	4,0,16384,10,1

;window function - used as an amplitude envelope for each grain
;(bartlett window)
giWFn   ftgen 2,0,16384,20,3,1

;**************************************************************************************
instr 1 ; Real-time Spectral Instrument - Environmental Noise 
;**************************************************************************************

; get control value from application
kSineControlVal	chnget	"sineControlVal"

ares	fractalnoise	ampdbfs(-24),	1 ; pink noise generator

ifftsize = 2048
ioverlap = ifftsize / 4
iwinsize = ifftsize * 2
iwinshape = 0

fsig	pvsanal	ares,	ifftsize,	ioverlap,	iwinsize,	iwinshape

; get info from pvsanal and print
ioverlap,	inbins,	iwindowsize,	iformat	pvsinfo	fsig
print	ioverlap,	inbins,	iwindowsize,	iformat		

;inoscs = 250
;kfmod = 0.5 * kSineControlVal
;ibinoffset = 2
;ibinincr = 4

;gaOut	pvsadsyn	fsig,	inoscs,	kfmod,	ibinoffset,	ibinincr

ifn = 1
kdepth = 0.99 + (0.01 * kSineControlVal)

fmask	pvsmaska	fsig,	ifn,	kdepth		

aOut0	pvsynth	fmask
	outs	aOut0 * 0.8,	aOut0 * 0.8

endin

;;**************************************************************************************
;instr 2 ; Modal Instrument
;;**************************************************************************************
;
;; get control value from application
;kSineControlVal	chnget	"sineControlVal"
;
;iamp    init ampdbfs(-12)
;
;kFreqScale chnget "randFreq" ; random frequency scale value sent from application
;kWgbowAmpVal chnget "randAmp"
;kWgbowPressureVal chnget "randPressure"
;kWgbowPosVal chnget "randPos"
;
;; mallet excitator----------------------------------
;
;; to simulate the shock between the excitator and the resonator
;;krand	random	1,	10	
;;ashock  mpulse ampdbfs(-1), krand,	2
;;
;;; felt excitator from mode.csd
;;;aexc1	mode	ashock,	80 * (kFreqScale + 1.0),	8
;;aexc1	mode	ashock,	80,	8
;;aexc1 = aexc1 * iamp
;;
;;;aexc2	mode	ashock,	188 * (kFreqScale * 1.0),	3
;;aexc2	mode	ashock,	188,	3
;;aexc2 = aexc2 * iamp
;;
;;aexc	sum	aexc1,	aexc2
;
;; bow excitator-------------------------------------
;
;kamp = ampdbfs(-24) * kWgbowAmpVal 
;kfreq = 55 + kFreqScale 
;kpres = kWgbowPressureVal
;krat = kWgbowPosVal 
;kvibf = 3
;kvamp = ampdbfs(-24);ampdbfs(-5.995) + (0.01 * kSineControlVal)
;
;aexc	wgbow	kamp,	kfreq,	kpres,	krat,	kvibf,	kvamp
;
;;"Contact" condition : when aexc reaches 0, the excitator looses 
;;contact with the resonator, and stops "pushing it"
;aexc limit	aexc,	0,	3*iamp 
;
;; Wine Glass with ratios from http://www.csounds.com/manual/html/MiscModalFreq.html
;;ares1	mode	aexc,	220 * (kFreqScale + 1),	420 ; A3 fundamental frequency
;ares1	mode	aexc,	220,	420 ; A3 fundamental frequency
;
;ares2	mode	aexc,	510.4,	480
;
;ares3	mode	aexc,	935,	500
;
;ares4	mode	aexc,	1458.6,	520
;
;ares5	mode	aexc,	2063.6,	540; - (kSineControlVal * 100)
;
;ares	sum	ares1,	ares2,	ares3,	ares4,	ares5
;
;gaOut1 = (aexc + ares) * kSineControlVal 
;;gaOut1 = aexc + ares
;	;outs	gaOut1,	gaOut1
;
;kRms	rms	gaOut1
;	chnset	kRms,	"rmsOut"
;
;endin
;
;;**************************************************************************************
;instr 3 ; Real-time Spectral Instrument - Mandelbulb Formula Sonification 
;;**************************************************************************************
;
;;iMandelMaxPoints	chnget	"mandelMaxPoints"
;
;; get sine control value from application
;;kSineControlVal		chnget	"sineControlVal"
;
;;S_EscapeValChannelNames[] init iMandelMaxPoints
;
;ifftsize = 1024 
;ioverlap = ifftsize / 4
;iwinsize = ifftsize * 2
;iwinshape = 0
;
;; route output from instrument 2 above to pvsanal
;fsig	pvsanal	gaOut1,	ifftsize,	ioverlap,	iwinsize,	iwinshape
;
;; get info from pvsanal and print
;ioverlap,	inbins,	iwindowsize,	iformat	pvsinfo	fsig
;print	ioverlap,	inbins,	iwindowsize,	iformat		
;
;; create tables to write frequency data
;iFreqTable	ftgen	0,	0,	inbins,	2,	0
;iAmpTable	ftgen	0,	0,	inbins,	2,	0
;
;; write frequency data to function table
;kFlag	pvsftw	fsig,	iAmpTable,	iFreqTable	
;
; if kFlag == 0 goto contin 
;
;;************** Frequency Processing *****************
;
;; modify frequency data from fsig with mandelbulb escape values from application
;kCount = 0
;
;loop:
;
;	;S_ChannelName sprintfk	"mandelEscapeVal%d",	kCount
;
;	;kMandelVal	chnget	S_ChannelName
;
;	; read frequency data from iFreqTable
;	;kFreq	tablekt	kCount,	iFreqTable
;	
;	; read amplitude data from iAmpTable
;	kAmp	tablekt	kCount,	iAmpTable
;
;	; send val out to application
;	S_ChannelName	sprintfk	"fftAmpBin%d",	kCount
;	chnset	kAmp,	S_ChannelName
;	
;	; multiply kMandelVal with frequency value 
;	;kProcFreqVal = kFreq * kMandelVal
;
;	; write processed freq data back to table
;	;tablewkt	kProcFreqVal,	kCount,	iFreqTable	
;
;	loop_lt	kCount,	1,	inbins,	loop
;
;;pvsftr	fsig,	iAmpTable,	iFreqTable
;
;contin:
;
;; resynthesize the audio signal
;;aFinalSig	pvsynth	fsig
;
;;gaOut2	= aFinalSig
;
;;*********** Amplitude processing ******************
;;ifn = giMandelTable 
;;kdepth = 0.8 * kSineControlVal
;;kdepth = 1 
;
;; use mandelbulb escape values to modify amplitude values of the signal acting as a spectral filter
;;fmask	pvsmaska	fsig,	ifn,	kdepth		
;
;;gaOut2	pvsynth	fmask
;	;outs	aOut0,	aOut0
;
;endin

;**************************************************************************************
instr 8 ; granular instrument using grain3
;**************************************************************************************

kCps	chnget	"grainFreq"
kPhs	chnget	"grainPhase"
kFmd	chnget	"randFreq"
kPmd	chnget	"randPhase"
kGDur	chnget	"grainDur"
kDens	chnget	"grainDensity"
kFrPow	chnget	"grainFreqVariationDistrib"
kPrPow	chnget	"grainPhaseVariationDistrib"
;kFn	chnget	"grainWaveform"

kGDur = 0.01 + kGDur ; initialisation to avoid perf error 0.0
kDens = 1 + kDens

; get control value from application
kSineControlVal	chnget	"sineControlVal"
;kCps = kCps * kSineControlVal + 20

  ;kCPS    =       100
  ;kPhs    =       0
  ;kFmd    transeg 0,1,0,0, 10,4,15, 10,-4,0
  ;kFmd	= 3
  ;kPmd    transeg 0,1,0,0, 10,4,1,  10,-4,0
  ;kPmd	= 7
  ;kGDur   =       0.08
  ;kDens   =       200
  iMaxOvr =       1000
  kFn     =       4
  ;print info. to the terminal
          ;printks "Random Phase:%5.2F%TPitch Random:%5.2F%n",1,kPmd,kFmd
	;printks "Grain Density:%f%n", 1, kDens
  gaOut8    grain3  kCps, kPhs, kFmd, kPmd, kGDur, kDens, iMaxOvr, kFn, giWFn, kFrPow, kPrPow
;          outs     aSig*0.06,aSig*0.06

;kRms	rms	gaOut8
;	chnset	kRms,	"rmsOut"

;ifftsize = 2048
;ioverlap = ifftsize / 4
;iwinsize = ifftsize * 2
;iwinshape = 0
;
;fsig	pvsanal	gaOut8,	ifftsize,	ioverlap,	iwinsize,	iwinshape
;
;kcent	pvscent	fsig
;	chnset	kcent,	"specCentOut"

;printks "Specral Centroid CSound Out:%f%n", 1, kcent

endin

;**************************************************************************************
instr 9 ; Real-time Spectral Analysis Instrument 
;**************************************************************************************

ifftsize = 1024 
ioverlap = ifftsize / 4
iwinsize = ifftsize * 2
iwinshape = 0

; route output from instrument 2 above to pvsanal
fsig	pvsanal	gaOut8,	ifftsize,	ioverlap,	iwinsize,	iwinshape

; get info from pvsanal and print
ioverlap,	inbins,	iwindowsize,	iformat	pvsinfo	fsig
print	ioverlap,	inbins,	iwindowsize,	iformat		

; create tables to write frequency data
iFreqTable	ftgen	0,	0,	inbins,	2,	0
iAmpTable	ftgen	0,	0,	inbins,	2,	0

; write frequency data to function table
kFlag	pvsftw	fsig,	iAmpTable,	iFreqTable	

 if kFlag == 0 goto contin 

;************** Frequency Processing *****************

; modify frequency data from fsig with mandelbulb escape values from application
kCount = 0

loop:

	; read amplitude data from iAmpTable
	kAmp	tablekt	kCount,	iAmpTable

	; send val out to application
	S_ChannelName	sprintfk	"fftAmpBin%d",	kCount
	chnset	kAmp,	S_ChannelName
	
	loop_lt	kCount,	1,	inbins,	loop

contin:

endin

;**************************************************************************************
instr 12 ; Hrtf Instrument
;**************************************************************************************
kPortTime linseg 0.0, 0.001, 0.05 

kAzimuthVal chnget "azimuth" 
kElevationVal chnget "elevation" 
kDistanceVal chnget "distance" 
kDist portk kDistanceVal, kPortTime ;to filter out audio artifacts due to the distance changing too quickly

;asig	sum	gaOut0,	gaOut1
;asig	sum	gaOut3,	gaOut4
asig = gaOut8 * 0.5
;asig = asig * 0.5

;kRmsGran	rms	asig	
;	chnset	kRmsGran,	"rmsOut"

aLeftSig, aRightSig  hrtfmove2	asig, kAzimuthVal, kElevationVal, "hrtf-48000-left.dat", "hrtf-48000-right.dat", 4, 9.0, 48000
aLeftSig = aLeftSig / (kDist + 0.00001)
aRightSig = aRightSig / (kDist + 0.00001)
	
aL = aLeftSig
aR = aRightSig

outs	aL,	aR
endin

</CsInstruments>
<CsScore>

;********************************************************************
; f tables
;********************************************************************
;p1	p2	p3	p4	p5			p6	p7	p8	p9	p10	p11	p12	p13	p14	p15	p16	p17	p18	p19	p20	p21	p22	p23	p24	p25

f1	0	1025	8	0			2	1	3	0	4	1	6	0	10	1	12	0	16	1	32	0	1	0	939	0

;********************************************************************
; score events
;********************************************************************

i1	2	10000

;i2	2	10000

;i3	2	10000	

i8	2	10000

i9	2	10000

i12	2	10000
e
</CsScore>
</CsoundSynthesizer>
