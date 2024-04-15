Class {
	#name : #GolapVertex,
	#superclass : #Object,
	#instVars : [
		'data',
		'nameKey',
		'frequencyKey',
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
	#category : #'Golap-Models'
}

{ #category : #'instance creation' }
GolapVertex class >> id: anObject name: aString frequency: aNumber [

	^ self
		  on: (DataSeries
				   withKeys: { 'name'. 'frequency' }
				   values: {
						   aString.
						   aNumber }
				   name: anObject)
		  nameKey: 'name'
		  frequencyKey: 'frequency'
]

{ #category : #'instance creation' }
GolapVertex class >> on: aDataSeries nameKey: aString frequencyKey: anotherString [

	^ self new
		  setData: aDataSeries nameKey: aString frequencyKey: anotherString;
		  yourself
]

{ #category : #'adding-removing' }
GolapVertex >> addEdge: aGolapEdge [
	^ edges add: aGolapEdge
]

{ #category : #'adding-removing' }
GolapVertex >> addHiddenEdge: aGolapEdge [
	^ hiddenEdges add: aGolapEdge
]

{ #category : #'adding-removing' }
GolapVertex >> addMarker: aColor [

	^ markers add: aColor
]

{ #category : #polishing }
GolapVertex >> addNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges add: aGolapEdge
]

{ #category : #polishing }
GolapVertex >> addPositivePolishEdge: aGolapEdge [
	positivePolishEdges add: aGolapEdge
]

{ #category : #'adding-removing' }
GolapVertex >> addRectangle: aRectangle with: aGolapVertex [
	rectangles at: aGolapVertex put: aRectangle
]

{ #category : #'adding-removing' }
GolapVertex >> addScore: aNumber vertex: aGolapVertex [
	^ scores at: aGolapVertex put: aNumber
]

{ #category : #enumerating }
GolapVertex >> argmaxEdge: aBlock [
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

{ #category : #converting }
GolapVertex >> asPoint [

	^ (x notNil and: [ y notNil ])
		  ifTrue: [ x @ y ]
		  ifFalse: [ nil ]
]

{ #category : #accessing }
GolapVertex >> at: aString [

	^ data at: aString
]

{ #category : #enumerating }
GolapVertex >> basicEdgesAndVerticesDo: aBlock [

	edges do: [ :edge | aBlock value: edge value: (edge peerOf: self) ]
]

{ #category : #accessing }
GolapVertex >> basicPhotoimage [

	^ photoimage
]

{ #category : #private }
GolapVertex >> basicRemoveEdge: aGolapEdge [
	edges remove: aGolapEdge ifAbsent: [  ].
	positivePolishEdges remove: aGolapEdge ifAbsent: [  ].
	negativePolishEdges remove: aGolapEdge ifAbsent: [  ]
]

{ #category : #'adding-removing' }
GolapVertex >> createEdgeTo: aGolapVertex data: aDataSeries [
	| edge |
	edge := GolapEdge on: aDataSeries between: self and: aGolapVertex.
	self addEdge: edge.
	^ aGolapVertex addEdge: edge
]

{ #category : #'adding-removing' }
GolapVertex >> createHiddenEdgeTo: aGolapVertex data: aDataSeries [
	| edge |
	edge := GolapEdge on: aDataSeries between: self and: aGolapVertex.
	self addHiddenEdge: edge.
	^ aGolapVertex addHiddenEdge: edge
]

{ #category : #accessing }
GolapVertex >> edgeTo: aGolapVertex ifAbsent: errorBlock [
	self
		edgesAndVerticesDo: [ :edge :vertex | 
			aGolapVertex == vertex
				ifTrue: [ ^ edge ] ].
	^ errorBlock value
]

{ #category : #enumerating }
GolapVertex >> edgesAndVerticesDo: aBlock [
	edges
		do: [ :edge | 
			(negativePolishEdges includes: edge)
				ifFalse: [ aBlock value: edge value: (edge peerOf: self) ] ].
	positivePolishEdges
		do: [ :edge | aBlock value: edge value: (edge peerOf: self) ]
]

{ #category : #enumerating }
GolapVertex >> edgesDo: aBlock [
	edges
		do: [ :edge | 
			(negativePolishEdges includes: edge)
				ifFalse: [ aBlock value: edge ] ].
	positivePolishEdges do: aBlock
]

{ #category : #accessing }
GolapVertex >> flushPhotoimage [

	photoimage := nil
]

{ #category : #accessing }
GolapVertex >> frequency [

	^ data at: frequencyKey
]

{ #category : #enumerating }
GolapVertex >> hasEdge: aGolapEdge [
	^ edges includes: aGolapEdge
]

{ #category : #enumerating }
GolapVertex >> hasEdgeSuchThat: aBlock [
	self
		edgesDo: [ :edge | 
			(aBlock value: edge)
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #testing }
GolapVertex >> hasMarker: aColor [

	^ markers includes: aColor
]

{ #category : #polishing }
GolapVertex >> hasNegativePolishEdgeWith: aGolapVertex [
	negativePolishEdges
		do: [ :edge | 
			self == edge vertex1
				ifTrue: [ aGolapVertex == edge vertex2
						ifTrue: [ ^ true ] ].
			self == edge vertex2
				ifTrue: [ aGolapVertex == edge vertex1
						ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : #testing }
GolapVertex >> hasPeerVertex: aGolapVertex [
	self
		edgesDo: [ :edge | 
			(edge peerOf: self) == aGolapVertex
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #testing }
GolapVertex >> hasVertex: aGolapVertex [
	^ self == aGolapVertex
]

{ #category : #accessing }
GolapVertex >> hiddenEdgeTo: aGolapVertex ifAbsent: errorBlock [
	self
		hiddenEdgesAndVerticesDo: [ :edge :vertex | 
			aGolapVertex == vertex
				ifTrue: [ ^ edge ] ].
	^ errorBlock value
]

{ #category : #enumerating }
GolapVertex >> hiddenEdgesAndVerticesDo: aBlock [
	hiddenEdges
		do: [ :edge | aBlock value: edge value: (edge peerOf: self) ]
]

{ #category : #accessing }
GolapVertex >> id [

	^ data name
]

{ #category : #enumerating }
GolapVertex >> idDo: aBlock [

	aBlock value: self id
]

{ #category : #testing }
GolapVertex >> includesId: anObject [

	^ self id = anObject
]

{ #category : #'initialize-release' }
GolapVertex >> initialize [

	super initialize.
	edges := OrderedCollection new.
	hiddenEdges := OrderedCollection new.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	scores := Dictionary new.
	rectangles := Dictionary new.
	markers := OrderedCollection new
]

{ #category : #testing }
GolapVertex >> isIsolated [
	^ edges isEmpty
]

{ #category : #testing }
GolapVertex >> isMergedVertex [
	^ false
]

{ #category : #accessing }
GolapVertex >> label [
	^ label
]

{ #category : #accessing }
GolapVertex >> label: aForm [
	label := aForm
]

{ #category : #accessing }
GolapVertex >> markers [

	^ markers
]

{ #category : #enumerating }
GolapVertex >> markersDo: aBlock [

	markers do: aBlock
]

{ #category : #accessing }
GolapVertex >> name [

	^ data at: self nameKey
]

{ #category : #accessing }
GolapVertex >> nameKey [

	^ nameKey
]

{ #category : #polishing }
GolapVertex >> negativePolishEdgeWith: aGolapVertex [
	negativePolishEdges
		do: [ :edge | 
			((self == edge vertex1 and: [ aGolapVertex == edge vertex2 ])
				or: [ self == edge vertex2 and: [ aGolapVertex == edge vertex1 ] ])
				ifTrue: [ ^ edge ] ].
	^ nil
]

{ #category : #polishing }
GolapVertex >> negativePolishEdgesDo: aBlock [
	negativePolishEdges do: aBlock
]

{ #category : #accessing }
GolapVertex >> numberOfEdges [
	^ edges size
]

{ #category : #accessing }
GolapVertex >> photoId [

	^ self id
]

{ #category : #accessing }
GolapVertex >> photoimage [

	^ photoimage isForm
		  ifTrue: [ photoimage ]
		  ifFalse: [ nil ]
]

{ #category : #accessing }
GolapVertex >> photoimage: aFormOrAny [
	photoimage := aFormOrAny
]

{ #category : #accessing }
GolapVertex >> position: aPoint [
	self x: aPoint x.
	self y: aPoint y
]

{ #category : #polishing }
GolapVertex >> positivePolishEdgesDo: aBlock [
	positivePolishEdges do: aBlock
]

{ #category : #printing }
GolapVertex >> printOn: aStream [

	aStream nextPutAll: 'V('.
	self id printOn: aStream.
	aStream nextPutAll: ' '.
	x printOn: aStream.
	aStream nextPutAll: ', '.
	y printOn: aStream.
	aStream nextPutAll: ') '
]

{ #category : #accessing }
GolapVertex >> rectangles [
	^ rectangles
]

{ #category : #enumerating }
GolapVertex >> rectanglesAndVerticesAndScoresAt: aPoint do: aBlock [
	rectangles
		keysAndValuesDo: [ :vertex :rect | 
			(rect containsPoint: aPoint - (x @ y))
				ifTrue: [ aBlock
						value: (rect origin + (x @ y) extent: rect extent)
						value: vertex
						value: (self scoreWith: vertex) ] ]
]

{ #category : #'adding-removing' }
GolapVertex >> removeAllMarkers [

	markers removeAll
]

{ #category : #'adding-removing' }
GolapVertex >> removeEdge: aGolapEdge [
	^ aGolapEdge
		remove;
		yourself
]

{ #category : #'adding-removing' }
GolapVertex >> removeMarker: aColor [

	^ markers remove: aColor ifAbsent: [  ]
]

{ #category : #polishing }
GolapVertex >> removeNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : #polishing }
GolapVertex >> removePositivePolishEdge: aGolapEdge [
	^ positivePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : #polishing }
GolapVertex >> resetPolish [
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new
]

{ #category : #accessing }
GolapVertex >> resetScores [
	scores := Dictionary new
]

{ #category : #accessing }
GolapVertex >> scoreWith: aGolapVertex [
	^ scores at: aGolapVertex ifAbsent: [ 0 ]
]

{ #category : #enumerating }
GolapVertex >> scoresDo: aBlock [
	scores valuesDo: aBlock
]

{ #category : #private }
GolapVertex >> setData: aDataSeries nameKey: aString frequencyKey: anotherString [

	data := aDataSeries.
	nameKey := aString.
	frequencyKey := anotherString
]

{ #category : #accessing }
GolapVertex >> totalScore [
	^ scores ifEmpty: [ 0 ] ifNotEmpty: #sum
]

{ #category : #accessing }
GolapVertex >> vertexAtPoint: aPoint [
	rectangles
		keysAndValuesDo: [ :vertex :rect | 
			(rect containsPoint: aPoint - (x @ y))
				ifTrue: [ ^ vertex ] ].
	^ nil
]

{ #category : #enumerating }
GolapVertex >> verticesAndScoresDo: aBlock [
	scores keysAndValuesDo: aBlock
]

{ #category : #accessing }
GolapVertex >> x [
	^ x
]

{ #category : #accessing }
GolapVertex >> x: aNumber [
	x := aNumber
]

{ #category : #accessing }
GolapVertex >> y [
	^ y
]

{ #category : #accessing }
GolapVertex >> y: aNumber [
	y := aNumber
]
