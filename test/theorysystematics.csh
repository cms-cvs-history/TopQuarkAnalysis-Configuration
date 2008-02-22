#! /bin/csh

echo "Make sure that you are in a CMSSW release containing alpgen (e.g. 1_4_6)."

### default settings:

set parp61 = 0.25
set parp72 = 0.25
set parj81 = 0.25
set mstp3 = 1 #?

set parp67 = 1 #?
set parp71 = 4 #?

set parj42 = 0.52
set parj21 = 0.40

set parj54 = -0.031
set parj55 = -0.0041

set parp82 = 2.9

### choose dataset and number of events:
echo "Script designed for ttNj samples. Insert N (0-4):"
set jets=$<

if ( ${jets} > 4 || ${jets} < 0 ) then
    echo "Sorry, unavailable sample. Choose a number between 0 and 4."
    exit
endif

echo "How many events? (Note: this will be approximative...)"
set events=$<

### the number of events to be generated by alpgen is much higher, in order to compensate unweighting and matching inefficiencies:
switch ( ${jets} )
    case 0:
	set unw_eff = 0.023
	set match_eff = 0.77
	breaksw
    case 1:
	set unw_eff = 0.010
	set match_eff = 0.56
	breaksw
    case 2:
	set unw_eff = 0.00098
	set match_eff = 0.43
	breaksw
    case 3:
	set unw_eff = 0.001
	set match_eff = 0.33
	breaksw
    case 4:
	set unw_eff = 0.00062
	set match_eff = 0.43
	breaksw
    default:
	echo "If you see this message, this script has a bug."
	exit
endsw

#set alpgenevents = `echo "${events} / ( ${unw_eff} * ${match_eff} )" | bc`
set alpgenevents = `echo "( ${events} / ${unw_eff} ) / ${match_eff} " | bc`
echo "This corresponds to ${alpgenevents} events before unweighting and matching."

### copying files from the web:

set sample = tt${jets}j_mT_70

if (!(-f cmsGen.py)) wget http://ceballos.web.cern.ch/ceballos/alpgen/bin/cmsGen.py
if (!(-f input_${sample})) wget http://cmsdoc.cern.ch/~mpierini/cms/alpgenCSA07/input_${sample}
if (!(-f ${sample}.grid2)) wget http://cmsdoc.cern.ch/~mpierini/cms/alpgenCSA07/${sample}.grid2
if (!(-f ${sample}_alpgen.cfg)) wget http://cmsdoc.cern.ch/~mpierini/cms/alpgenCSA07/${sample}_alpgen.cfg

### executing cmsGen:

eval `scramv1 ru -csh`
chmod +x cmsGen.py
./cmsGen.py --generator=alpgen --number-of-events=${alpgenevents} --cfg=${sample}_alpgen.cfg

### menu:
echo "-------- Available systematics: ---------"
echo "0: default settings"
echo "1: lambda_qcd"
echo "2: Q2max"
echo "3: light quark fragmentation"
echo "4: heavy quark fragmentation"
echo "5: underlying event"
echo "---------------- Choose: ----------------"

set syst=$<

switch ( ${syst} )
    case 0:
	echo "you chose the default settings"
	set extendedlabel = `echo "default settings"`
	set label = std
	set dir = std
	goto filename
    case 1:
	echo "you chose lambdaqcd"
	set label = lambdaqcd
	set extendedlabel = $label
	breaksw
    case 2:
	echo "you chose Q2max"
	set label = q2max
	set extendedlabel = $label
	breaksw
    case 3:
	echo "you chose light quark fragmentation"
	set label = fragl
	set extendedlabel = `echo "light quark fragmentation"`
	breaksw
    case 4:
	echo "you chose heavy quark fragmentation"
	set label = fragh
	set extendedlabel = `echo "heavy quark fragmentation"`
	breaksw
    case 5:
	echo "you chose underlying event"
	set label = ue
	set extendedlabel = `echo "underlying event"`
	breaksw
    default:
	echo "Sorry, unrecognized option."
	exit
endsw


updown:
echo "---------------- Choose up/down: ----------------"
set dir=$<
switch ( ${dir} )
    case up:
	breaksw
    case down:
	breaksw
    default:
	echo "Sorry, unrecognized option. You must choose up or down."
	goto updown
endsw

### apply new settings:
switch ( ${syst} )
    case 1:
	if (${dir} == up) then
	    set parp61 = 0.35
	    set parp72 = 0.35
	    set parj81 = 0.35
	else
	    set parp61 = 0.15
	    set parp72 = 0.15
	    set parj81 = 0.15
	endif 
	breaksw
    case 2:
	if (${dir} == up) then
	    set parp67 = 4
	    set parp71 = 16
	else
	    set parp67 = 0.25
	    set parp71 = 1
	endif 
	breaksw
    case 3:
	if (${dir} == up) then
	    set parj42 = 0.56
	    set parj21 = 0.43
	else
	    set parj42 = 0.48
	    set parj21 = 0.37
	endif 
	breaksw
    case 4:
	if (${dir} == up) then
	    set parj54 = -0.020
	    set parj55 = -0.0037
	else
	    set parj54 = -0.042
	    set parj55 = -0.0045
	endif 
	breaksw
    case 5:
	if (${dir} == up) then
	    set parp82 = 3.4
	else
	    set parp82 = 2.4
	endif 
	breaksw
endsw

### name of the cfi which has to replace "Configuration/Generator/data/PythiaUESettings.cfi"
filename:
if (${syst} == 0) then
    set cfi=PythiaDefault.cfi
else
    set cfi=Pythia_${label}_${dir}.cfi
endif


### create cfi file:
echo "Creating file ${cfi}..."
if (-f "${cfi}") rm ${cfi}
cat > ${cfi} <<EOF
vstring pythiaUESettings = {
      'PARP(61)=${parp61}',
      'PARP(72)=${parp72}',
      'PARJ(81)=${parj81}',
      'MSTP(3)=${mstp3}',
      'PARP(67)=${parp67}',
      'PARP(71)=${parp71}',
      'PARJ(42)=${parj42}',
      'PARJ(21)=${parj21}',
      'PARJ(54)=${parj54}',
      'PARJ(55)=${parj55}',
      'PARP(82)=${parp82}',
#standard settings:
      'MSTJ(11)=3     ! Choice of the fragmentation function',
      'MSTJ(22)=2     ! Decay those unstable particles',
      'PARJ(71)=10 .  ! for which ctau  10 mm',
      'MSTP(2)=1      ! which order running alphaS',
      'MSTP(33)=0     ! no K factors in hard cross sections',
      'MSTP(51)=7     ! structure function chosen',
      'MSTP(81)=1     ! multiple parton interactions 1 is Pythia default',
      'MSTP(82)=4     ! Defines the multi-parton model',
      'MSTU(21)=1     ! Check on possible errors during program execution',
### check that these two correspond to 2.5 at 14 TeV
#      'PARP(82)=1.9409   ! pt cutoff for multiparton interactions',
#      'PARP(89)=1960. ! sqrts for which PARP82 is set',
      'PARP(83)=0.5   ! Multiple interactions: matter distrbn parameter',
      'PARP(84)=0.4   ! Multiple interactions: matter distribution parameter',
      'PARP(90)=0.16  ! Multiple interactions: rescaling power',
#      'PARP(67)=2.5    ! amount of initial-state radiation',
#      'PARP(85)=1.0  ! gluon prod. mechanism in MI',
      'PARP(85)=0.33  ! from CMS note 2005/013',
#      'PARP(86)=1.0  ! gluon prod. mechanism in MI',
      'PARP(86)=0.66  ! from CMS note 2005/013',
      'PARP(62)=1.25   ! ',
      'PARP(64)=0.2    ! ',
      'MSTP(91)=1     !',
      'PARP(91)=2.1   ! kt distribution',
      'PARP(93)=15.0  ! '
}
EOF

#more ${cfi}

### execute cmsRun in order to create GEN file:
if (${syst} == 0) then
    set cfg=GenDefault.cfg
    set output=${sample}_GEN_default.root
else
    set cfg=Gen_tt${jets}j_${label}_${dir}.cfg
    set output=${sample}_GEN_${label}_${dir}.root
endif
echo "Creating file ${cfg}..."
if (-f "${cfg}") rm ${cfg}
if (-f temp1) rm temp1
if (-f temp2) rm temp2
set dummy1 = `echo '$Revision: 1.5 $'` #this will be modified by cvs, just put Revision between the dollars
set dummy2 = `echo '$Source: /cvs_server/repositories/CMSSW/CMSSW/TopQuarkAnalysis/Configuration/test/theorysystematics.csh,v $'` #this will be modified by cvs, just put Source between the dollars
cat > temp1 <<EOF
process Gen = {

   untracked PSet maxEvents = {untracked int32 input = -1}

   untracked PSet configurationMetadata = {
           untracked string version = "$dummy1"
           untracked string name = "$dummy2"
           untracked string annotation = "tt+jets exclusive sample with ptjet gt 70 GeV and Rmatch eq 0.7, ${extendedlabel} variated ${dir}ward"
   }

   include "FWCore/MessageService/data/MessageLogger.cfi"
   replace MessageLogger.cout.threshold = "ERROR"
   replace MessageLogger.cerr.default.limit = 10
    
   service = RandomNumberGeneratorService
   { 
      untracked uint32 sourceSeed = 123456789
      PSet moduleSeeds =
      {
         untracked uint32 VtxSmeared = 98765432
         untracked uint32 g4SimHits  = 11
         untracked uint32 mix        = 12345
      }
   }
   # physics event generation
   #

  source = AlpgenSource
  { 
     
   untracked vstring fileNames = {"file:${sample}"}
  
   untracked int32 pythiaPylistVerbosity = 1
   untracked bool pythiaHepMCVerbosity = false

   # put here the cross section of your process (in pb)
   untracked double crossSection = 1.0 
   # put here the efficiency of your filter (1. if no filter)
   untracked double filterEfficiency = 1.

   PSet PythiaParameters = {

    # This is a vector of ParameterSet names to be read, in this order
    vstring parameterSets = { 
        "pythiaUESettings",
        "pythia"
    }
EOF
cat > temp2 <<EOF
    vstring pythia = {
        'MSEL=0              !(D=1)',
        'MSTP(143)=1         !Call the matching routine in ALPGEN'
    }	
  }

# Alpgen parameters
    PSet GeneratorParameters = { 
      vstring parameterSets =  { "generator" }
      vstring generator = 
       {         
        "IXpar(2) = 1            ! inclus./exclus. sample: 0/1",
        "RXpar(1) = 70.          ! ETCLUS : minET(CLUS)",
        "RXpar(2) = 0.7          ! RCLUS  : deltaR(CLUS)"
      }
    }
  }



#this filters out empty (rejected by matching) events from the PoolOutputModule
   module filter = AlpgenEmptyEventFilter {}

   path p1 = {filter}

   # Event output
   include "Configuration/EventContent/data/EventContent.cff"
   module GEN = PoolOutputModule 
   { 
	untracked string fileName = "${output}"
        untracked PSet SelectEvents = {
           vstring SelectEvents = {"p1"}
        }
        untracked PSet dataset ={
                untracked string dataTier = "GEN"
                untracked string filterName = "${label}_${dir}"
        }
   }

   endpath outpath = {GEN}

}
EOF

cat temp1 ${cfi} temp2 > ${cfg}
rm temp1
rm temp2

#more ${cfg}
cmsRun ${cfg}

EdmFileUtil -f file:${output}

echo " "
echo "Config file: ${cfg}"
#echo "Output file: ${output}"
#echo "Feed it into your SIM or FastSim job."
