import FWCore.ParameterSet.Config as cms

pvSelection = cms.PSet(
  minNdof = cms.double( 7. )
, maxZ    = cms.double( 24. )
, maxRho  = cms.double( 2. )
)

goodOfflinePrimaryVertices = cms.EDFilter(
  "PrimaryVertexObjectFilter" # checks for fake PVs automatically
, filterParams = pvSelection
, filter       = cms.bool( False ) # use only as producer
, src          = cms.InputTag( 'offlinePrimaryVertices' )
)

goodOfflinePrimaryVertexFilter = cms.EDFilter(
#   "VertexSelector"
# , src    = pvSrc
# , cut    = cms.string( '!isFake && ndof > 4 && abs(z) <= 24. && abs(position.rho) <= 2.' )
# , filter = cms.bool( True )
  "PrimaryVertexFilter" # checks for fake PVs automatically
, pvSelection
, pvSrc = cms.InputTag( 'goodOfflinePrimaryVertices' )
)
