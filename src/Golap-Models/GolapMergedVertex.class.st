Class {
	#name : #GolapMergedVertex,
	#superclass : #GolapVertex,
	#instVars : [
		'oldEdges',
		'oldVertices'
	],
	#category : #'Golap-Models-Graph'
}

{ #category : #testing }
GolapMergedVertex >> hasVertex: aGolapVertex [
	^ (super hasVertex: aGolapVertex)
		or: [ oldVertices contains: [ :v | v hasVertex: aGolapVertex ] ]
]

{ #category : #enumerating }
GolapMergedVertex >> idDo: aBlock [

	aBlock value: self id.
	oldVertices do: [ :v | v idDo: aBlock ]
]

{ #category : #testing }
GolapMergedVertex >> includesId: anObject [
	^ (super includesId: anObject)
		or: [ oldVertices contains: [ :v | v includesId: anObject ] ]
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
GolapMergedVertex >> photoId [

	^ (oldVertices notNil and: [ oldVertices notEmpty ])
		  ifTrue: [ oldVertices first photoId ]
		  ifFalse: [ self id ]
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
