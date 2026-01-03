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
		'x',
		'y',
		'label',
		'rectangles',
		'photoimage',
		'markers'
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

{ #category : 'adding-removing' }
GolapNode >> addMarker: aColor [

	^ markers add: aColor
]

{ #category : 'polishing' }
GolapNode >> addNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges add: aGolapEdge
]

{ #category : 'polishing' }
GolapNode >> addPositivePolishEdge: aGolapEdge [
	positivePolishEdges add: aGolapEdge
]

{ #category : 'adding-removing' }
GolapNode >> addRectangle: aRectangle with: aGolapNode [
	rectangles at: aGolapNode put: aRectangle
]

{ #category : 'adding-removing' }
GolapNode >> addScore: aNumber node: aGolapNode [
	^ scores at: aGolapNode put: aNumber
]

{ #category : 'enumerating' }
GolapNode >> argmaxEdge: aBlock [
	| max argmax |
	max := Float negativeInfinity.
	argmax := nil.
	edges
		do: [ :edge | 
			| value |
			value := aBlock value: edge.
			value > max
				ifTrue: [ argmax := edge.
					max := value ] ].
	^ argmax
]

{ #category : 'converting' }
GolapNode >> asPoint [

	^ (x notNil and: [ y notNil ])
		  ifTrue: [ x @ y ]
		  ifFalse: [ nil ]
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
GolapNode >> edgeTo: aGolapNode ifAbsent: errorBlock [

	self edgesAndNodeDo: [ :edge :node |
		aGolapNode == node ifTrue: [ ^ edge ] ].
	^ errorBlock value
]

{ #category : 'accessing' }
GolapNode >> edges [

	^ edges
]

{ #category : 'accessing' }
GolapNode >> edges: anOrderedCollection [

	edges := anOrderedCollection
]

{ #category : 'enumerating' }
GolapNode >> edgesAndNodeDo: aBlock [
	edges
		do: [ :edge | 
			(negativePolishEdges includes: edge)
				ifFalse: [ aBlock value: edge value: (edge peerOf: self) ] ].
	positivePolishEdges
		do: [ :edge | aBlock value: edge value: (edge peerOf: self) ]
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
	^ edges includes: aGolapEdge
]

{ #category : 'enumerating' }
GolapNode >> hasEdgeSuchThat: aBlock [
	self
		edgesDo: [ :edge | 
			(aBlock value: edge)
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'testing' }
GolapNode >> hasMarker: aColor [

	^ markers includes: aColor
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

{ #category : 'enumerating' }
GolapNode >> idDo: aBlock [

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
	scores := Dictionary new.
	rectangles := Dictionary new.
	markers := OrderedCollection new
]

{ #category : 'testing' }
GolapNode >> isIsolated [
	^ edges isEmpty
]

{ #category : 'testing' }
GolapNode >> isMergedNode [
	^ false
]

{ #category : 'accessing' }
GolapNode >> label [
	^ label
]

{ #category : 'accessing' }
GolapNode >> label: aForm [
	label := aForm
]

{ #category : 'accessing' }
GolapNode >> markers [

	^ markers asArray
]

{ #category : 'enumerating' }
GolapNode >> markersDo: aBlock [

	markers do: aBlock
]

{ #category : 'accessing' }
GolapNode >> name [

	^ name ifNil: [ self id ]
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

{ #category : 'accessing' }
GolapNode >> nodeAtPoint: aPoint [

	rectangles keysAndValuesDo: [ :node :rect |
		(rect containsPoint: aPoint - (x @ y)) ifTrue: [ ^ node ] ].
	^ nil
]

{ #category : 'enumerating' }
GolapNode >> nodesAndScoresDo: aBlock [
	scores keysAndValuesDo: aBlock
]

{ #category : 'accessing' }
GolapNode >> numberOfEdges [
	^ edges size
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

{ #category : 'accessing' }
GolapNode >> position: aPoint [
	self x: aPoint x.
	self y: aPoint y
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
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	scores := Dictionary new.
	rectangles := Dictionary new.
	markers := OrderedCollection new.
	markers := markers copy
]

{ #category : 'printing' }
GolapNode >> printOn: aStream [

	aStream nextPutAll: 'V('.
	self id printOn: aStream.
	aStream nextPutAll: ' '.
	x printOn: aStream.
	aStream nextPutAll: ', '.
	y printOn: aStream.
	aStream nextPutAll: ') '
]

{ #category : 'accessing' }
GolapNode >> rankOf: aGolapEdge in: aGolapModel [

	| score rank |
	score := aGolapModel valueAtEdge: aGolapEdge.
	rank := 1.
	edges do: [ :edge |
		score < (aGolapModel valueAtEdge: edge) ifTrue: [ rank := rank + 1 ] ].
	^ rank
]

{ #category : 'accessing' }
GolapNode >> rectangles [
	^ rectangles
]

{ #category : 'enumerating' }
GolapNode >> rectanglesAndNodesAndScoresAt: aPoint do: aBlock [

	rectangles keysAndValuesDo: [ :node :rect |
		(rect containsPoint: aPoint - (x @ y)) ifTrue: [
			aBlock
				value: (rect origin + (x @ y) extent: rect extent)
				value: node
				value: (self scoreWith: node) ] ]
]

{ #category : 'adding-removing' }
GolapNode >> removeAllMarkers [

	markers removeAll
]

{ #category : 'adding-removing' }
GolapNode >> removeEdge: aGolapEdge [
	^ aGolapEdge
		remove;
		yourself
]

{ #category : 'adding-removing' }
GolapNode >> removeMarker: aColor [

	^ markers remove: aColor ifAbsent: [  ]
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

{ #category : 'accessing' }
GolapNode >> x [
	^ x
]

{ #category : 'accessing' }
GolapNode >> x: aNumber [
	x := aNumber
]

{ #category : 'accessing' }
GolapNode >> y [
	^ y
]

{ #category : 'accessing' }
GolapNode >> y: aNumber [
	y := aNumber
]
