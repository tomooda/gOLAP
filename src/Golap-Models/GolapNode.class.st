Class {
	#name : 'GolapNode',
	#superclass : 'Object',
	#instVars : [
		'data',
		'name',
		'edges',
		'hiddenEdges',
		'positivePolishEdges',
		'negativePolishEdges',
		'scores',
		'photoimage'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapNode class >> on: aDataSeries name: aString [

	^ self new
		  setData: aDataSeries name: aString;
		  yourself
]

{ #category : 'adding-removing' }
GolapNode >> addEdge: aGolapEdge [
	^ edges add: aGolapEdge
]

{ #category : 'adding-removing' }
GolapNode >> addHiddenEdge: aGolapEdge [
	^ hiddenEdges add: aGolapEdge
]

{ #category : 'polishing' }
GolapNode >> addNegativePolishEdge: aGolapEdge [

	^ negativePolishEdges add: aGolapEdge
]

{ #category : 'polishing' }
GolapNode >> addPositivePolishEdge: aGolapEdge [

	^ positivePolishEdges add: aGolapEdge
]

{ #category : 'adding-removing' }
GolapNode >> addScore: aNumber node: aGolapNode [
	^ scores at: aGolapNode put: aNumber
]

{ #category : 'enumerating' }
GolapNode >> allEdgesAndNodesDo: aBlock [

	self allEdgesDo: [ :edge |
		aBlock value: edge value: (edge peerOf: self) ]
]

{ #category : 'enumerating' }
GolapNode >> allEdgesDo: aBlock [

	edges do: [ :edge | aBlock value: edge ].
	positivePolishEdges do: [ :edge | aBlock value: edge ]
]

{ #category : 'accessing' }
GolapNode >> at: aString [

	^ data at: aString
]

{ #category : 'accessing' }
GolapNode >> at: aString ifAbsent: errorBlock [

	^ data at: aString ifAbsent: errorBlock
]

{ #category : 'enumerating' }
GolapNode >> basicEdgesAndNodesDo: aBlock [

	edges do: [ :edge | aBlock value: edge value: (edge peerOf: self) ]
]

{ #category : 'accessing' }
GolapNode >> basicPhotoimage [

	^ photoimage
]

{ #category : 'private' }
GolapNode >> basicRemoveEdge: aGolapEdge [
	edges remove: aGolapEdge ifAbsent: [  ].
	positivePolishEdges remove: aGolapEdge ifAbsent: [  ].
	negativePolishEdges remove: aGolapEdge ifAbsent: [  ]
]

{ #category : 'polishing' }
GolapNode >> canHavePositivePolishEdge: aGolapNode [

	self == aGolapNode ifTrue: [ ^ false ].
	self edgesDo: [ :edge |
			((edge node1 == self and: [ edge node2 == aGolapNode ]) or: [
				 edge node1 == aGolapNode and: [ edge node2 == self ] ]) ifTrue: [
				^ false ] ].
	^ true
]

{ #category : 'adding-removing' }
GolapNode >> createEdgeTo: aGolapNode data: aDataSeries [
	| edge |
	edge := GolapEdge on: aDataSeries between: self and: aGolapNode.
	self addEdge: edge.
	^ aGolapNode addEdge: edge
]

{ #category : 'adding-removing' }
GolapNode >> createHiddenEdgeTo: aGolapNode data: aDataSeries [
	| edge |
	edge := GolapEdge on: aDataSeries between: self and: aGolapNode.
	self addHiddenEdge: edge.
	^ aGolapNode addHiddenEdge: edge
]

{ #category : 'accessing' }
GolapNode >> data [

	^ data
]

{ #category : 'arithmetics' }
GolapNode >> diff: aGolapNode [

	data keys do: [ :key |
		| value1 value2 |
		value1 := data at: key.
		(value1 isNumber and: [
			 value2 := aGolapNode at: key ifAbsent: [ nil ].
			 value2 isNumber ]) ifTrue: [ data at: key put: value1 - value2 ] ]
]

{ #category : 'accessing' }
GolapNode >> edgeTo: aGolapNode [

	self edgesAndNodeDo: [ :edge :node |
		aGolapNode == node ifTrue: [ ^ edge ] ].
	^ nil
]

{ #category : 'accessing' }
GolapNode >> edgeTo: aGolapNode ifAbsent: errorBlock [

	^ (self edgeTo: aGolapNode) ifNil: errorBlock
]

{ #category : 'accessing' }
GolapNode >> edges [

	^ Array streamContents: [ :stream |
		  self edgesDo: [ :edge | stream nextPut: edge ] ]
]

{ #category : 'accessing' }
GolapNode >> edges: anOrderedCollection [

	edges := anOrderedCollection.
	positivePolishEdges removeAll.
	negativePolishEdges removeAll
]

{ #category : 'enumerating' }
GolapNode >> edgesAndNodeDo: aBlock [

	self edgesDo: [ :edge |
		aBlock value: edge value: (edge peerOf: self) ]
]

{ #category : 'enumerating' }
GolapNode >> edgesDo: aBlock [
	edges
		do: [ :edge | 
			(negativePolishEdges includes: edge)
				ifFalse: [ aBlock value: edge ] ].
	positivePolishEdges do: aBlock
]

{ #category : 'accessing' }
GolapNode >> flushPhotoimage [

	photoimage := nil
]

{ #category : 'enumerating' }
GolapNode >> hasEdge: aGolapEdge [

	^ ((edges includes: aGolapEdge) and: [
		   (negativePolishEdges includes: aGolapEdge) not ]) or: [
		  positivePolishEdges includes: aGolapEdge ]
]

{ #category : 'enumerating' }
GolapNode >> hasEdgeSuchThat: aBlock [
	self
		edgesDo: [ :edge | 
			(aBlock value: edge)
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'polishing' }
GolapNode >> hasNegativePolishEdgeWith: aGolapNode [

	negativePolishEdges do: [ :edge |
		self == edge node1 ifTrue: [
			aGolapNode == edge node2 ifTrue: [ ^ true ] ].
		self == edge node2 ifTrue: [
			aGolapNode == edge node1 ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : 'testing' }
GolapNode >> hasNode: aGolapNode [
	^ self == aGolapNode
]

{ #category : 'testing' }
GolapNode >> hasPeerNode: aGolapNode [
	self
		edgesDo: [ :edge | 
			(edge peerOf: self) == aGolapNode
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'testing' }
GolapNode >> hasPeerSuchThat: aBlock [

	self edgesDo: [ :edge |
		(aBlock value: (edge peerOf: self)) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'accessing' }
GolapNode >> hiddenEdgeTo: aGolapNode ifAbsent: errorBlock [

	self hiddenEdgesAndNodeDo: [ :edge :node |
		aGolapNode == node ifTrue: [ ^ edge ] ].
	^ errorBlock value
]

{ #category : 'enumerating' }
GolapNode >> hiddenEdgesAndNodeDo: aBlock [
	hiddenEdges
		do: [ :edge | aBlock value: edge value: (edge peerOf: self) ]
]

{ #category : 'accessing' }
GolapNode >> id [

	^ data name ifNil: [ '-' ]
]

{ #category : 'accessing' }
GolapNode >> id: anObject [

	data name: anObject
]

{ #category : 'enumerating' }
GolapNode >> idsDo: aBlock [

	aBlock value: self id
]

{ #category : 'testing' }
GolapNode >> includesId: anObject [

	^ self id = anObject
]

{ #category : 'initialize-release' }
GolapNode >> initialize [

	super initialize.
	edges := OrderedCollection new.
	hiddenEdges := OrderedCollection new.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	scores := Dictionary new
]

{ #category : 'testing' }
GolapNode >> isIsolated [

	self edgesDo: [ :edge | ^ false ].
	^ true
]

{ #category : 'testing' }
GolapNode >> isMergedNode [
	^ false
]

{ #category : 'accessing' }
GolapNode >> name [

	^ name ifNil: [ self id ]
]

{ #category : 'accessing' }
GolapNode >> name: aString [

	name := aString
]

{ #category : 'arithmetics' }
GolapNode >> negated [

	data keys do: [ :key |
		| value1 |
		value1 := data at: key.
		value1 isNumber ifTrue: [ data at: key put: value1 negated ] ]
]

{ #category : 'polishing' }
GolapNode >> negativePolishEdgeWith: aGolapNode [

	negativePolishEdges do: [ :edge |
		((self == edge node1 and: [ aGolapNode == edge node2 ]) or: [
			 self == edge node2 and: [ aGolapNode == edge node1 ] ]) ifTrue: [
			^ edge ] ].
	^ nil
]

{ #category : 'polishing' }
GolapNode >> negativePolishEdgesDo: aBlock [
	negativePolishEdges do: aBlock
]

{ #category : 'enumerating' }
GolapNode >> nodesAndScoresDo: aBlock [
	scores keysAndValuesDo: aBlock
]

{ #category : 'accessing' }
GolapNode >> numberOfEdges [

	^ edges size + positivePolishEdges size - negativePolishEdges size
]

{ #category : 'accessing' }
GolapNode >> photoId [

	^ self id
]

{ #category : 'accessing' }
GolapNode >> photoimage [

	^ photoimage isForm
		  ifTrue: [ photoimage ]
		  ifFalse: [ nil ]
]

{ #category : 'accessing' }
GolapNode >> photoimage: aFormOrAny [
	photoimage := aFormOrAny
]

{ #category : 'polishing' }
GolapNode >> positivePolishEdgesDo: aBlock [
	positivePolishEdges do: aBlock
]

{ #category : 'copying' }
GolapNode >> postCopy [

	super postCopy.
	data := data copy.
	edges := edges copy.
	hiddenEdges := hiddenEdges copy.
	positivePolishEdges := positivePolishEdges copy.
	negativePolishEdges := negativePolishEdges copy.
	scores := Dictionary new
]

{ #category : 'printing' }
GolapNode >> printOn: aStream [

	aStream nextPutAll: 'V('.
	self id printOn: aStream.
	aStream nextPutAll: ', '.
	self name printOn: aStream.
	aStream nextPutAll: ') '
]

{ #category : 'accessing' }
GolapNode >> rankOf: aGolapEdge in: aGolapModel [

	| score rank |
	score := aGolapModel valueAtEdge: aGolapEdge.
	rank := 1.
	self edgesDo: [ :edge |
		score < (aGolapModel valueAtEdge: edge) ifTrue: [ rank := rank + 1 ] ].
	^ rank
]

{ #category : 'adding-removing' }
GolapNode >> remove [

	edges copy do: #remove.
	hiddenEdges copy do: #remove
]

{ #category : 'adding-removing' }
GolapNode >> removeEdge: aGolapEdge [
	^ aGolapEdge
		remove;
		yourself
]

{ #category : 'polishing' }
GolapNode >> removeNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : 'polishing' }
GolapNode >> removePositivePolishEdge: aGolapEdge [
	^ positivePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : 'polishing' }
GolapNode >> resetPolish [
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new
]

{ #category : 'accessing' }
GolapNode >> resetScores [
	scores := Dictionary new
]

{ #category : 'accessing' }
GolapNode >> scoreWith: aGolapNode [
	^ scores at: aGolapNode ifAbsent: [ 0 ]
]

{ #category : 'enumerating' }
GolapNode >> scoresDo: aBlock [
	scores valuesDo: aBlock
]

{ #category : 'private' }
GolapNode >> setData: aDataSeries name: aString [

	data := aDataSeries.
	name := aString
]

{ #category : 'accessing' }
GolapNode >> totalScore [
	^ scores ifEmpty: [ 0 ] ifNotEmpty: #sum
]
