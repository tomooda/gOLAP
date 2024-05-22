Class {
	#name : 'GolapMergedNode',
	#superclass : 'GolapNode',
	#instVars : [
		'oldEdges',
		'oldNodes'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'testing' }
GolapMergedNode >> hasNode: aGolapNode [
	^ (super hasNode: aGolapNode)
		or: [ oldNodes contains: [ :v | v hasNode: aGolapNode ] ]
]

{ #category : 'enumerating' }
GolapMergedNode >> idDo: aBlock [

	aBlock value: self id.
	oldNodes do: [ :v | v idDo: aBlock ]
]

{ #category : 'testing' }
GolapMergedNode >> includesId: anObject [
	^ (super includesId: anObject)
		or: [ oldNodes contains: [ :v | v includesId: anObject ] ]
]

{ #category : 'testing' }
GolapMergedNode >> isMergedNode [
	^ true
]

{ #category : 'accessing' }
GolapMergedNode >> oldEdges [
	^ oldEdges
]

{ #category : 'accessing' }
GolapMergedNode >> oldEdges: aCollectionOfGolapEdges [
	oldEdges := aCollectionOfGolapEdges
]

{ #category : 'enumerating' }
GolapMergedNode >> oldEdgesDo: aBlock [
	oldEdges do: aBlock
]

{ #category : 'accessing' }
GolapMergedNode >> oldNodes [
	^ oldNodes
]

{ #category : 'accessing' }
GolapMergedNode >> oldNodes: aCollectionOfGolapNodes [
	oldNodes := aCollectionOfGolapNodes
]

{ #category : 'enumerating' }
GolapMergedNode >> oldNodesDo: aBlock [
	oldNodes do: aBlock
]

{ #category : 'accessing' }
GolapMergedNode >> photoId [

	^ (oldNodes notNil and: [ oldNodes notEmpty ])
		  ifTrue: [ oldNodes first photoId ]
		  ifFalse: [ self id ]
]

{ #category : 'accessing' }
GolapMergedNode >> photoimage: aFormOrAny [

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
