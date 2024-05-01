"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestGolapUI',
	#superclass : 'PackageManifest',
	#category : 'Golap-UI-Manifest',
	#package : 'Golap-UI',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestGolapUI class >> ruleEmptyExceptionHandlerRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#GolapItemView #retrieveSingleImageFor: #false)) #'2023-01-11T11:18:22.297113+09:00') )
]
