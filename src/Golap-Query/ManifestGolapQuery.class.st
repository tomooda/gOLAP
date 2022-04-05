"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGolapQuery,
	#superclass : #PackageManifest,
	#category : #'Golap-Query-Manifest'
}

{ #category : #'code-critics' }
ManifestGolapQuery class >> ruleGRGuradGuardClauseRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Golap-Query')) #'2020-04-19T09:11:09.236507+09:00') )
]

{ #category : #'code-critics' }
ManifestGolapQuery class >> ruleRBGuardingClauseRuleV1FalsePositive [
	^ #(#(#(#RGPackage #(#'Golap-Query')) #'2020-04-19T09:10:56.782027+09:00') )
]
