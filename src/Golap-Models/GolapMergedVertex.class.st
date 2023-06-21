Class {
	#name : #GolapMergedVertex,
	#superclass : #GolapVertex,
	#instVars : [
		'oldEdges',
		'oldVertices'
	],
	#category : #'Golap-Models'
}

{ #category : #enumerating }
GolapMergedVertex >> dataDo: aBlock [

	aBlock value: self data.
	oldVertices do: [ :v | v dataDo: aBlock ]
]

{ #category : #accessing }
GolapMergedVertex >> frequency: aNumber [
	frequency := aNumber.
	edges
		do: [ :edge | 
			self == edge vertex1
				ifTrue: [ edge data at: 'frequency1' put: frequency ]
				ifFalse: [ edge data at: 'frequency2' put: frequency ] ].
	hiddenEdges
		do: [ :edge | 
			self == edge vertex1
				ifTrue: [ edge data at: 'frequency1' put: frequency ]
				ifFalse: [ edge data at: 'frequency2' put: frequency ] ].
	positivePolishEdges
		do: [ :edge | 
			self == edge vertex1
				ifTrue: [ edge data at: 'frequency1' put: frequency ]
				ifFalse: [ edge data at: 'frequency2' put: frequency ] ].
	negativePolishEdges
		do: [ :edge | 
			self == edge vertex1
				ifTrue: [ edge data at: 'frequency1' put: frequency ]
				ifFalse: [ edge data at: 'frequency2' put: frequency ] ]
]

{ #category : #testing }
GolapMergedVertex >> hasData: anObject [
	^ (super hasData: anObject)
		or: [ oldVertices contains: [ :v | v hasData: anObject ] ]
]

{ #category : #testing }
GolapMergedVertex >> hasVertex: aGolapVertex [
	^ (super hasVertex: aGolapVertex)
		or: [ oldVertices contains: [ :v | v hasVertex: aGolapVertex ] ]
]

{ #category : #testing }
GolapMergedVertex >> isMergedVertex [
	^ true
]

{ #category : #accessing }
GolapMergedVertex >> oldEdges [
	^ oldEdges
]

{ #category : #accessing }
GolapMergedVertex >> oldEdges: aCollectionOfGolapEdges [
	oldEdges := aCollectionOfGolapEdges
]

{ #category : #enumerating }
GolapMergedVertex >> oldEdgesDo: aBlock [
	oldEdges do: aBlock
]

{ #category : #accessing }
GolapMergedVertex >> oldVertices [
	^ oldVertices
]

{ #category : #accessing }
GolapMergedVertex >> oldVertices: aCollectionOfGolapVertices [
	oldVertices := aCollectionOfGolapVertices
]

{ #category : #enumerating }
GolapMergedVertex >> oldVerticesDo: aBlock [
	oldVertices do: aBlock
]

{ #category : #accessing }
GolapMergedVertex >> photoData [

	^ (oldVertices notNil and: [ oldVertices notEmpty ])
		  ifTrue: [ (oldVertices maxWith: #frequency) photoData ]
		  ifFalse: [ self data ]
]

{ #category : #accessing }
GolapMergedVertex >> photoimage: aFormOrAny [

	aFormOrAny isForm
		ifTrue: [
			| extent form |
			extent := aFormOrAny extent.
			form := Form extent: extent + (5 @ 9) depth: 32.
			form getCanvas
				fillColor: Color white;
				paintImage: aFormOrAny at: 0 @ 0;
				line: 0 @ extent y
				to: extent x @ extent y
				width: 1
				color: Color lightGray;
				line: 1 @ (extent y + 2)
				to: extent x + 1 @ (extent y + 2)
				width: 1
				color: Color lightGray;
				line: 2 @ (extent y + 4)
				to: extent x + 2 @ (extent y + 4)
				width: 1
				color: Color lightGray;
				line: 3 @ (extent y + 6)
				to: extent x + 3 @ (extent y + 6)
				width: 1
				color: Color lightGray;
				line: extent x @ 0
				to: extent x @ extent y
				width: 1
				color: Color lightGray;
				line: extent x + 1 @ 2
				to: extent x + 1 @ (extent y + 2)
				width: 1
				color: Color lightGray;
				line: extent x + 2 @ 4
				to: extent x + 2 @ (extent y + 4)
				width: 1
				color: Color lightGray;
				line: extent x + 3 @ 6
				to: extent x + 3 @ (extent y + 6)
				width: 1
				color: Color lightGray;
				flush.
			super photoimage: form ]
		ifFalse: [ super photoimage: aFormOrAny ]
]
