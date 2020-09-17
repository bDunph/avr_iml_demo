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

ifn = 1
kdepth = 0.99 + (0.01 * kSineControlVal)

fmask	pvsmaska	fsig,	ifn,	kdepth		

aOut0	pvsynth	fmask
	outs	aOut0 * 0.05,	aOut0 * 0.05

endin

;**************************************************************************************
instr 2 ; note scheduler
;**************************************************************************************

kGaussVal gauss 6.0

seed 0
kRand random 0.1, 10.0

seed 0
kRand2 random 1, 5 

kTrigger metro kRand2 
kMinTim	= 0 
kMaxNum = 1 
kInsNum = 3
kWhen = 0
kDur = kRand 

schedkwhen kTrigger, kMinTim, kMaxNum, kInsNum, kWhen, kDur, 1000+kGaussVal, 1400+kGaussVal, 1200+kGaussVal, 800+kGaussVal, 700+kGaussVal, 1000+kGaussVal

aOut oscil 0,	100

outs aOut, aOut

endin

;**************************************************************************************
instr 3 ; Granular Instrument 
;**************************************************************************************

kCps	chnget	"grainFreq"
kPhs	chnget	"grainPhase"
kFmd	chnget	"randFreq"
kPmd	chnget	"randPhase"
kGDur	chnget	"grainDur"
kDens	chnget	"grainDensity"
kFrPow	chnget	"grainFreqVariationDistrib"
kPrPow	chnget	"grainPhaseVariationDistrib"

kGDur = 0.01 + kGDur ; initialisation to avoid perf error 0.0
kDens = 1 + kDens

iMaxOvr = 2000 
kFn = 3

aOut3    grain3  kCps, kPhs, kFmd, kPmd, kGDur, kDens, iMaxOvr, kFn, giWFn, kFrPow, kPrPow

kAmp	linseg 0.0,	p3 * 0.1,	0.95,	p3 * 0.1,	0.8,	p3 * 0.6,	0.8,	p3 * 0.1,	0.0

kfe  expseg p4, p3*0.3, p5, p3*0.1, p6, p3*0.2, p7, p3*0.3, p8, p3*0.1, p9
kres linseg 0.1, p3 * 0.2, 0.3, p3 * 0.4, 0.25, p3 * 0.2, 0.5, p3 * 0.2, 0.35	;vary resonance
afil moogladder aOut3, kfe, kres

gaGranularOut = afil * kAmp

endin

;**************************************************************************************
instr 4 ; Spectral Analysis Instrument 
;**************************************************************************************

ifftsize = 1024 
ioverlap = ifftsize / 4
iwinsize = ifftsize * 2
iwinshape = 0

; route output from the granular instrument to pvsanal
fsig	pvsanal	gaGranularOut,	ifftsize,	ioverlap,	iwinsize,	iwinshape

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
	S_channelName	sprintfk	"fftAmpBin%d",	kCount
	chnset	kAmp,	S_channelName
	
	loop_lt	kCount,	1,	inbins,	loop

contin:

endin

;**************************************************************************************
instr 5 ; 3D Source Location Instrument
;**************************************************************************************
kPortTime linseg 0.0, 0.001, 0.05 

kAzimuthVal chnget "azimuth" 
kElevationVal chnget "elevation" 
kDistanceVal chnget "distance" 
kDist portk kDistanceVal, kPortTime ;to filter out audio artifacts due to the distance changing too quickly

aSig = gaGranularOut * 0.5

aLeftSig, aRightSig  hrtfmove2	aSig, kAzimuthVal, kElevationVal, "hrtf-48000-left.dat", "hrtf-48000-right.dat", 4, 9.0, 48000
aLeftSig = aLeftSig / (kDist + 0.00001)
aRightSig = aRightSig / (kDist + 0.00001)
	
aL = aLeftSig * 0.8
aR = aRightSig * 0.8

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

i2	2	10000

i4	2	10000

i5	2	10000
e
</CsScore>
</CsoundSynthesizer>
