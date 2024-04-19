Class {
	#name : #GolapEdge,
	#superclass : #Object,
	#instVars : [
		'data',
		'vertex1',
		'vertex2'
	],
	#category : #'Golap-Models-Graph'
}

{ #category : #'instance creation' }
GolapEdge class >> on: aDataSeries between: aGolapVertex1 and: aGolapVertex2 [
	^ self new
		setData: aDataSeries;
		vertex1: aGolapVertex1;
		vertex2: aGolapVertex2;
		yourself
]

{ #category : #accessing }
GolapEdge >> at: aString [

	^ self data ifNotNil: [ :d | d at: aString ]
]

{ #category : #accessing }
GolapEdge >> at: aString ifAbsent: errorBlock [

	^ self data
		  ifNotNil: [ :d | d at: aString ifAbsent: errorBlock ]
		  ifNil: errorBlock
]

{ #category : #accessing }
GolapEdge >> at: aString put: anObject [

	^ self data ifNotNil: [ :d | d at: aString put: anObject ]
]

{ #category : #operations }
GolapEdge >> basicReplaceVertex: aGolapVertex1 with: aGolapVertex2 [
	vertex1 == aGolapVertex1
		ifTrue: [ vertex1 := aGolapVertex2.
			^ vertex1 ].
	vertex2 == aGolapVertex1
		ifTrue: [ vertex2 := aGolapVertex2.
			^ vertex2 ].
	^ nil
]

{ #category : #accessing }
GolapEdge >> data [
	^ data
]

{ #category : #arithmetics }
GolapEdge >> diff: aGolapEdge [

	data keys do: [ :key |
		| value1 value2 |
		value1 := data at: key.
		(value1 isNumber and: [
			 value2 := aGolapEdge at: key ifAbsent: [ nil ].
			 value2 isNumber ]) ifTrue: [ data at: key put: value1 - value2 ] ]
]

{ #category : #testing }
GolapEdge >> hasVertex: aGolapVertex [

	^ vertex1 == aGolapVertex or: [ vertex2 == aGolapVertex ]
]

{ #category : #arithmetics }
GolapEdge >> negated [

	data keys do: [ :key |
		| value1 |
		value1 := data at: key.
		value1 isNumber ifTrue: [ data at: key put: value1 negated ] ]
]

{ #category : #accessing }
GolapEdge >> peerOf: aGolapVertex [

	aGolapVertex id = vertex1 id ifTrue: [ ^ vertex2 ].
	aGolapVertex id = vertex2 id ifTrue: [ ^ vertex1 ].
	^ nil
]

{ #category : #copying }
GolapEdge >> postCopy [

	super postCopy.
	data := data copy
]

{ #category : #operations }
GolapEdge >> remove [
	vertex1 ifNotNil: [ :v | v basicRemoveEdge: self ].
	vertex2 ifNotNil: [ :v | v basicRemoveEdge: self ]
]

{ #category : #operations }
GolapEdge >> replaceVertex: aGolapVertex1 with: aGolapVertex2 [
	aGolapVertex1 basicRemoveEdge: self.
	self basicReplaceVertex: aGolapVertex1 with: aGolapVertex2.
	aGolapVertex1 addEdge: self.
	^ aGolapVertex2
]

{ #category : #private }
GolapEdge >> setData: aDataSeries [

	data := aDataSeries
]

{ #category : #accessing }
GolapEdge >> vertex1 [
	^ vertex1
]

{ #category : #accessing }
GolapEdge >> vertex1: aGolapVertex [
	vertex1 := aGolapVertex
]

{ #category : #accessing }
GolapEdge >> vertex2 [
	^ vertex2
]

{ #category : #accessing }
GolapEdge >> vertex2: aGolapVertex [
	vertex2 := aGolapVertex
]
