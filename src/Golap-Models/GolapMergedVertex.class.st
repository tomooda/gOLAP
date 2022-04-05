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
