Class {
	#name : 'GolapPolisher',
	#superclass : 'Object',
	#instVars : [
		'polishToConverge',
		'fillerThreshold',
		'burrThreshold',
		'minClusterSize'
	],
	#category : 'Golap-Models-Analysis',
	#package : 'Golap-Models',
	#tag : 'Analysis'
}

{ #category : 'operations' }
GolapPolisher >> applyTo: aGolapModel [

	(self fit: aGolapModel) applyTo: aGolapModel
]

{ #category : 'accessing' }
GolapPolisher >> burrThreshold [

	^ burrThreshold
]

{ #category : 'accessing' }
GolapPolisher >> burrThreshold: aNumber [

	burrThreshold := aNumber
]

{ #category : 'accessing' }
GolapPolisher >> fillerThreshold [

	^ fillerThreshold
]

{ #category : 'accessing' }
GolapPolisher >> fillerThreshold: aNumber [

	fillerThreshold := aNumber
]

{ #category : 'operations' }
GolapPolisher >> fit: aGolapModel [

	| polish |
	polish := GolapPolish new.
	polishToConverge = true
		ifTrue: [
				polish
					fitToConverge: aGolapModel
					fillerThreshold: fillerThreshold
					burrThreshold: burrThreshold
					minClusterSize: minClusterSize ]
		ifFalse: [
				polish
					fit: aGolapModel
					fillerThreshold: fillerThreshold
					burrThreshold: burrThreshold
					minClusterSize: minClusterSize ].
	^ polish
]

{ #category : 'initialization' }
GolapPolisher >> initialize [

	super initialize.
	polishToConverge := false.
	fillerThreshold := 1.0.
	burrThreshold := 0.0.
	minClusterSize := 3
]

{ #category : 'accessing' }
GolapPolisher >> minClusterSize [

	^ minClusterSize
]

{ #category : 'accessing' }
GolapPolisher >> minClusterSize: anInteger [

	minClusterSize := anInteger
]

{ #category : 'accessing' }
GolapPolisher >> polishToConverge [

	^ polishToConverge 
]

{ #category : 'accessing' }
GolapPolisher >> polishToConverge: aBoolean [

	polishToConverge := aBoolean
]
