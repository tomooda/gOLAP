Class {
	#name : 'GolapEdge',
	#superclass : 'Object',
	#instVars : [
		'data',
		'node1',
		'node2'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapEdge class >> on: aDataSeries between: aGolapNode1 and: aGolapNode2 [

	^ self new
		  setData: aDataSeries;
		  node1: aGolapNode1;
		  node2: aGolapNode2;
		  yourself
]

{ #category : 'accessing' }
GolapEdge >> at: aString [

	^ self data ifNotNil: [ :d | d at: aString ]
]

{ #category : 'accessing' }
GolapEdge >> at: aString ifAbsent: errorBlock [

	^ self data
		  ifNotNil: [ :d | d at: aString ifAbsent: errorBlock ]
		  ifNil: errorBlock
]

{ #category : 'accessing' }
GolapEdge >> at: aString put: anObject [

	^ self data ifNotNil: [ :d | d at: aString put: anObject ]
]

{ #category : 'operations' }
GolapEdge >> basicReplaceNode: aGolapNode1 with: aGolapNode2 [
	node1 == aGolapNode1
		ifTrue: [ node1 := aGolapNode2.
			^ node1 ].
	node2 == aGolapNode1
		ifTrue: [ node2 := aGolapNode2.
			^ node2 ].
	^ nil
]

{ #category : 'accessing' }
GolapEdge >> data [
	^ data
]

{ #category : 'arithmetics' }
GolapEdge >> diff: aGolapEdge [

	data keys do: [ :key |
		| value1 value2 |
		value1 := data at: key.
		(value1 isNumber and: [
			 value2 := aGolapEdge at: key ifAbsent: [ nil ].
			 value2 isNumber ]) ifTrue: [ data at: key put: value1 - value2 ] ]
]

{ #category : 'testing' }
GolapEdge >> hasNode: aGolapNode [

	^ node1 == aGolapNode or: [ node2 == aGolapNode ]
]

{ #category : 'testing' }
GolapEdge >> isNegativePolishEdge [

	node1 negativePolishEdgesDo: [ :edge |
		self == edge ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'testing' }
GolapEdge >> isPositivePolishEdge [

	node1 positivePolishEdgesDo: [ :edge |
		self == edge ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'arithmetics' }
GolapEdge >> negated [

	data keys do: [ :key |
		| value1 |
		value1 := data at: key.
		value1 isNumber ifTrue: [ data at: key put: value1 negated ] ]
]

{ #category : 'accessing' }
GolapEdge >> node1 [
	^ node1
]

{ #category : 'accessing' }
GolapEdge >> node1: aGolapNode [
	node1 := aGolapNode
]

{ #category : 'accessing' }
GolapEdge >> node2 [
	^ node2
]

{ #category : 'accessing' }
GolapEdge >> node2: aGolapNode [
	node2 := aGolapNode
]

{ #category : 'accessing' }
GolapEdge >> peerOf: aGolapNode [

	aGolapNode id = node1 id ifTrue: [ ^ node2 ].
	aGolapNode id = node2 id ifTrue: [ ^ node1 ].
	^ nil
]

{ #category : 'copying' }
GolapEdge >> postCopy [

	super postCopy.
	data := data copy
]

{ #category : 'accessing' }
GolapEdge >> rankIn: aGolapModel [

	^ (node1 rankOf: self in: aGolapModel) max:
		  (node2 rankOf: self in: aGolapModel)
]

{ #category : 'operations' }
GolapEdge >> remove [
	node1 ifNotNil: [ :v | v basicRemoveEdge: self ].
	node2 ifNotNil: [ :v | v basicRemoveEdge: self ]
]

{ #category : 'operations' }
GolapEdge >> replaceNode: aGolapNode1 with: aGolapNode2 [
	aGolapNode1 basicRemoveEdge: self.
	self basicReplaceNode: aGolapNode1 with: aGolapNode2.
	aGolapNode1 addEdge: self.
	^ aGolapNode2
]

{ #category : 'private' }
GolapEdge >> setData: aDataSeries [

	data := aDataSeries
]
