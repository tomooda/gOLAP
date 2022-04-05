"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestGolapUI,
	#superclass : #PackageManifest,
	#category : #'Golap-UI-Manifest'
}

{ #category : #'code-critics' }
ManifestGolapUI class >> ruleRBCollectionMessagesToExternalObjectRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#Golap #minimalSpanningTree #false)) #'2019-07-22T09:37:00.490577+09:00') )
]
