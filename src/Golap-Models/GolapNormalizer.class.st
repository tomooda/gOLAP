Class {
	#name : 'GolapNormalizer',
	#superclass : 'Object',
	#instVars : [
		'scale',
		'offset'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapNormalizer class >> from: anArrayOfNumber [

	^ anArrayOfNumber
		  ifEmpty: [ self min: 0.0 max: 0.0 ]
		  ifNotEmpty: [
		  self min: anArrayOfNumber min max: anArrayOfNumber max ]
]

{ #category : 'instance creation' }
GolapNormalizer class >> min: aNumber1 max: aNumber2 [

	^ self new
		  setMin: aNumber1 max: aNumber2;
		  yourself
]

{ #category : 'accessing' }
GolapNormalizer >> denormalize: aNumber [

	^ scale abs < 1.0e-12
		  ifTrue: [ 0.5 ]
		  ifFalse: [ aNumber - offset / scale ]
]

{ #category : 'accessing' }
GolapNormalizer >> normalize: aNumber [

	^ aNumber * scale + offset
]

{ #category : 'private' }
GolapNormalizer >> setMin: aNumber1 max: aNumber2 [

	| width |
	width := aNumber2 - aNumber1.
	width abs < 1.0e-8 ifTrue: [
			scale := 0.0.
			offset := 0.5.
			^ self ].
	scale := width abs reciprocal.
	offset := (aNumber1 min: aNumber2) * scale negated
]
