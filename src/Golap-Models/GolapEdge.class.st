Class {
	#name : #GolapEdge,
	#superclass : #Object,
	#instVars : [
		'data',
		'vertex1',
		'vertex2'
	],
	#category : #'Golap-Models'
}

{ #category : #'instance creation' }
GolapEdge class >> on: aDataSeries between: aGolapVertex1 and: aGolapVertex2 [
	^ self new
		data: aDataSeries;
		vertex1: aGolapVertex1;
		vertex2: aGolapVertex2;
		yourself
]

{ #category : #accessing }
GolapEdge >> at: aString [

	^ self data ifNotNil: [ :d | d at: aString ]
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

{ #category : #accessing }
GolapEdge >> data: aDataSeries [
	data := aDataSeries
]

{ #category : #accessing }
GolapEdge >> frequency [
	^ data at: 'frequency'
]

{ #category : #testing }
GolapEdge >> hasVertex: aGolapVertex [

	^ vertex1 == aGolapVertex or: [ vertex2 == aGolapVertex ]
]

{ #category : #accessing }
GolapEdge >> peerOf: aGolapVertex [
	aGolapVertex = vertex1
		ifTrue: [ ^ vertex2 ].
	aGolapVertex = vertex2
		ifTrue: [ ^ vertex1 ].
	^ nil
]

{ #category : #copying }
GolapEdge >> postCopy [
	super postCopy.
	data := Dictionary newFrom: data
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
