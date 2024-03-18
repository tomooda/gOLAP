Class {
	#name : #GolapModel,
	#superclass : #Model,
	#instVars : [
		'dataframe',
		'nodeKey1',
		'nodeKey2',
		'nodeNameKey1',
		'nodeNameKey2',
		'frequencyKey',
		'totalKey',
		'liftKey',
		'edgeKey',
		'jaccardKey',
		'pmiKey',
		'vertices',
		'frequencyKey1',
		'frequencyKey2',
		'treeEdges',
		'aggregation',
		'friendsEdges',
		'friendsRank',
		'graphEdges',
		'positivePolishEdges',
		'negativePolishEdges',
		'mergedVertices'
	],
	#category : #'Golap-Models'
}

{ #category : #storage }
GolapModel class >> chooseCoocurrenceDataDo: aBlock [
	^ (UIManager default
		chooseExistingFileReference: 'Select a coocurrence file'
		extensions: #('csv')
		path: self coocurrenceDataDirectory) ifNotNil: aBlock
]

{ #category : #'instance creation' }
GolapModel class >> chooseFromFile [
	^ self
		chooseCoocurrenceDataDo: [ :ref | 
			ref isFile
				ifTrue: [ self
						dataframe: (DataFrame readFromCsv: ref forceStringColumns: self stringColumns) ]
				ifFalse: [ nil ] ]
]

{ #category : #storage }
GolapModel class >> chooseItemsDataDo: aBlock [
	^ (UIManager default
		chooseExistingFileReference: 'Select an items file'
		extensions: #('csv')
		path: self itemsDataDirectory) ifNotNil: aBlock
]

{ #category : #storage }
GolapModel class >> coocurrenceDataDirectory [
	^ self localDirectory
]

{ #category : #'instance creation' }
GolapModel class >> dataframe: aDataFrame [
	^ self new
		dataframe: aDataFrame;
		setJaccardMode;
		vertices;
		yourself
]

{ #category : #storage }
GolapModel class >> itemsDataDirectory [
	^ self localDirectory
]

{ #category : #storage }
GolapModel class >> localDirectory [
	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : #defaults }
GolapModel class >> queryFromArray: anArrayOfString [
	^ (String lf join: anArrayOfString) , String lf
]

{ #category : #'instance creation' }
GolapModel class >> readFrom: aFileReferenceOrReadStream [
	| line |
	line := aFileReferenceOrReadStream isStream
		ifTrue: [ | position |
			position := aFileReferenceOrReadStream position.
			[ aFileReferenceOrReadStream upTo: Character lf ]
				ensure: [ aFileReferenceOrReadStream position: position ] ]
		ifFalse: [ aFileReferenceOrReadStream
				readStreamDo: [ :stream | stream upTo: Character lf ] ].
	(line includes: $:)
		ifFalse: [ ^ self
				dataframe:
					(DataFrame
						readFromCsv: aFileReferenceOrReadStream
						forceStringColumns: self stringColumns) ]
]

{ #category : #defaults }
GolapModel class >> stringColumns [
	^ #('node1' 'node2' 'node1n' 'node2n') asSet
]

{ #category : #arithmetics }
GolapModel >> + aGolapOverviewModel [
	| dataframe2 sumDataframe frequencies1 frequencies2 sumFrequencies |
	dataframe2 := aGolapOverviewModel dataframe.
	sumDataframe := DataFrame withColumnNames: dataframe columnNames.
	frequencies1 := Dictionary new.
	dataframe
		do: [ :row | 
			frequencies1 at: (row at: 'node1') ifAbsentPut: (row at: 'frequency1').
			frequencies1
				at: (row at: 'node2')
				ifAbsentPut: (row at: 'frequency2') ].
	frequencies2 := Dictionary new.
	dataframe2
		do: [ :row | 
			frequencies2 at: (row at: 'node1') ifAbsentPut: (row at: 'frequency1').
			frequencies2
				at: (row at: 'node2')
				ifAbsentPut: (row at: 'frequency2') ].
	sumFrequencies := frequencies1.
	frequencies2
		keysAndValuesDo: [ :node :freq | 
			sumFrequencies
				at: node
				put: (sumFrequencies at: node ifAbsent: [ 0 ]) + freq ].
	frequencies1 := nil.
	frequencies2 := nil.
	1 to: dataframe numberOfRows do: [ :index | 
		| dataseries |
		dataseries := DataSeries newFrom: (dataframe rowAt: index).
		dataseries
			name:
				{(dataseries at: self nodeKey1).
				(dataseries at: self nodeKey2)}.
		dataseries
			at: 'frequency1'
			put: (sumFrequencies at: (dataseries at: 'node1')).
		dataseries
			at: 'frequency2'
			put: (sumFrequencies at: (dataseries at: 'node2')).
		sumDataframe addRow: dataseries ].
	1 to: dataframe2 numberOfRows do: [ :index | 
		| dataseries2 node1 node2 sumDataseries |
		dataseries2 := dataframe2 rowAt: index.
		node1 := dataseries2 at: self nodeKey1.
		node2 := dataseries2 at: self nodeKey2.
		sumDataseries := sumDataframe
			row:
				{node1.
				node2}
			ifAbsent: [ | ds |
				ds := (DataSeries newFrom: dataseries2)
					at: self frequencyKey put: 0;
					at: self frequencyKey1 put: (sumFrequencies at: node1);
					at: self frequencyKey2 put: (sumFrequencies at: node2);
					at: self totalKey put: 0;
					at: 'support' put: 0.0;
					at: 'confidence' put: 0.0;
					at: self liftKey put: 0.0;
					at: self jaccardKey put: 0.0;
					at: self pmiKey put: 0.0;
					name:
						{node1.
						node2};
					yourself.
				sumDataframe addRow: ds.
				ds ].
		{self frequencyKey.
		self totalKey.
		'support'.
		'confidence'.
		self liftKey.
		self jaccardKey.
		self pmiKey}
			do: [ :key | 
				sumDataseries
					at: key
					transform: [ :v | v + (dataseries2 at: key) min: 1 ] ].
		sumDataseries
			at: 'effective'
			transform: [ :v | v + (dataseries2 at: 'effective') ].
		sumDataframe
			row:
				{node1.
				node2}
			put: sumDataseries asArray ].
	^ self class dataframe: sumDataframe
]

{ #category : #arithmetics }
GolapModel >> - aGolapOverviewModel [
	| dataframe2 diff rowNames diffDataframe frequencies1 frequencies2 diffFrequencies |
	dataframe2 := aGolapOverviewModel dataframe.
	diff := Dictionary
		new: dataframe numberOfRows + dataframe2 numberOfRows.
	frequencies1 := Dictionary new.
	dataframe
		do: [ :row | 
			frequencies1 at: (row at: 'node1') ifAbsentPut: (row at: 'frequency1').
			frequencies1
				at: (row at: 'node2')
				ifAbsentPut: (row at: 'frequency2') ].
	frequencies2 := Dictionary new.
	dataframe2
		do: [ :row | 
			frequencies2 at: (row at: 'node1') ifAbsentPut: (row at: 'frequency1').
			frequencies2
				at: (row at: 'node2')
				ifAbsentPut: (row at: 'frequency2') ].
	diffFrequencies := frequencies1.
	frequencies2
		keysAndValuesDo: [ :node :freq | 
			diffFrequencies
				at: node
				put: (diffFrequencies at: node ifAbsent: [ 0 ]) - freq ].
	frequencies1 := nil.
	frequencies2 := nil.
	1 to: dataframe numberOfRows do: [ :index | 
		| dataseries |
		dataseries := DataSeries newFrom: (dataframe rowAt: index).
		dataseries
			name:
				{(dataseries at: self nodeKey1).
				(dataseries at: self nodeKey2)}.
		dataseries
			at: 'frequency1'
			put: (diffFrequencies at: (dataseries at: 'node1')).
		dataseries
			at: 'frequency2'
			put: (diffFrequencies at: (dataseries at: 'node2')).
		diff at: dataseries name put: dataseries ].
	1 to: dataframe2 numberOfRows do: [ :index | 
		| dataseries2 node1 node2 diffDataseries |
		dataseries2 := dataframe2 rowAt: index.
		node1 := dataseries2 at: self nodeKey1.
		node2 := dataseries2 at: self nodeKey2.
		diffDataseries := diff
			at:
				{node1.
				node2}
			ifAbsent: [ | ds |
				ds := (DataSeries newFrom: dataseries2)
					at: self frequencyKey put: 0;
					at: self frequencyKey1 put: (diffFrequencies at: node1);
					at: self frequencyKey2 put: (diffFrequencies at: node2);
					at: self totalKey put: 0;
					at: 'support' put: 0.0;
					at: 'confidence' put: 0.0;
					at: self liftKey put: 0.0;
					at: self jaccardKey put: 0.0;
					at: self pmiKey put: 0.0;
					at: 'effective' put: 0;
					name:
						{node1.
						node2};
					yourself.
				diff at: ds name put: ds.
				ds ].
		{self frequencyKey.
		self totalKey.
		'support'.
		'confidence'.
		self liftKey.
		self jaccardKey.
		self pmiKey}
			do: [ :key | 
				diffDataseries
					at: key
					transform: [ :v | 
						v
							ifNil: [ (dataseries2 at: key) ifNil: [ 0.0 ] ]
							ifNotNil: [ v - ((dataseries2 at: key) ifNil: [ 0.0 ]) ] ] ].
		diffDataseries
			at: 'effective'
			transform: [ :v | v + (dataseries2 at: 'effective') ].
		diff
			at:
				{node1.
				node2}
			put: diffDataseries ].
	rowNames := (diff keys
		asSortedCollection: [ :less :more | 
			less first < more first
				or: [ more second isNil
						or: [ less second notNil and: [ less second <= more second ] ] ] ])
		asArray.
	diffDataframe := DataFrame
		withRows: (rowNames collect: [ :key | (diff at: key) asArray ])
		rowNames: rowNames
		columnNames: dataframe columnNames.
	^ self class dataframe: diffDataframe
]

{ #category : #polishing }
GolapModel >> addNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges add: aGolapEdge
]

{ #category : #polishing }
GolapModel >> addPositivePolishEdge: aGolapEdge [
	^ positivePolishEdges add: aGolapEdge
]

{ #category : #accessing }
GolapModel >> aggregation [
	^ aggregation
]

{ #category : #accessing }
GolapModel >> aggregation: aSymbol [
	aggregation := aSymbol asSymbol
]

{ #category : #accessing }
GolapModel >> averageEdgeValueAtVertex: aGolapVertex [
	^ (self sumEdgeValueAtVertex: aGolapVertex)
		/ (self vertices size - 1) asFloat
]

{ #category : #enumerating }
GolapModel >> bindingEdgesDo: aBlock [
	(friendsEdges ifNil: [ treeEdges ifNil: [ self graphEdges ] ])
		do: [ :edge | 
			(negativePolishEdges includes: edge)
				ifFalse: [ aBlock value: edge ] ].
	positivePolishEdges do: aBlock
]

{ #category : #private }
GolapModel >> computeFriendsEdges: anInteger [

	| edges |
	edges := IdentityBag new: self vertices size * anInteger.
	self verticesDo: [ :v |
		edges addAll: ((((Array streamContents: [ :stream |
				    v edgesDo: [ :e |
					    e data ifNotNil: [
						    stream nextPut: e -> (self valueAtEdge: e) ] ] ])
				   asSortedCollection: [ :more :less | less value <= more value ])
				  readStream next: anInteger) collect: #key) ].
	^ Array streamContents: [ :stream |
		  edges doWithOccurrences: [ :e :n |
			  n >= 2 ifTrue: [ stream nextPut: e ] ] ]
]

{ #category : #'accessing-vertex' }
GolapModel >> createVertex: anInteger name: aString [
	^ GolapVertex on: anInteger name: aString
]

{ #category : #'accessing-vertex' }
GolapModel >> createVerticesFromDataframe [
	| newVertices |
	newVertices := Dictionary new.
	dataframe
		do: [ :data | 
			| node1 node2 vertex1 vertex2 |
			node1 := data at: self nodeKey1.
			node2 := data at: self nodeKey2.
			vertex1 := newVertices
				at: node1
				ifAbsentPut: [ self createVertex: node1 name: (data at: self nodeNameKey1) ].
			node2
				ifNotNil: [ vertex2 := newVertices
						at: node2
						ifAbsentPut: [ self createVertex: node2 name: (data at: self nodeNameKey2) ].
					(data at: 'effective' ifAbsent: [ 1 ]) > 0
						ifTrue: [ vertex1 createEdgeTo: vertex2 data: data ]
						ifFalse: [ vertex1 createHiddenEdgeTo: vertex2 data: data ] ] ].
	^ newVertices
]

{ #category : #accessing }
GolapModel >> dataframe [
	^ dataframe
]

{ #category : #accessing }
GolapModel >> dataframe: aDataFrame [
	aDataFrame
		columnNames:
			(aDataFrame columnNames
				collect: [ :string | 
					(string includes: $%)
						ifTrue: [ string copyFrom: 1 to: (string indexOf: $%) - 1 ]
						ifFalse: [ string ] ]).
	dataframe := aDataFrame
]

{ #category : #defaults }
GolapModel >> defaultEdgeKey [
	^ 'frequency'
]

{ #category : #defaults }
GolapModel >> defaultFrequencyKey [
	^ 'frequency'
]

{ #category : #defaults }
GolapModel >> defaultFrequencyKey1 [
	^ 'frequency1'
]

{ #category : #defaults }
GolapModel >> defaultFrequencyKey2 [
	^ 'frequency2'
]

{ #category : #defaults }
GolapModel >> defaultJaccardKey [
	^ 'jaccard'
]

{ #category : #defaults }
GolapModel >> defaultLiftKey [
	^ 'lift'
]

{ #category : #defaults }
GolapModel >> defaultName [
	^ 'vanilla' copy
]

{ #category : #defaults }
GolapModel >> defaultNodeKey1 [
	^ 'node1'
]

{ #category : #defaults }
GolapModel >> defaultNodeKey2 [
	^ 'node2'
]

{ #category : #defaults }
GolapModel >> defaultNodeNameKey1 [
	^ 'node1n'
]

{ #category : #defaults }
GolapModel >> defaultNodeNameKey2 [
	^ 'node2n'
]

{ #category : #defaults }
GolapModel >> defaultPMIKey [
	^ 'PMI'
]

{ #category : #defaults }
GolapModel >> defaultTotalKey [
	^ 'total'
]

{ #category : #accessing }
GolapModel >> degreeEdgeValueAtVertex: aGolapVertex [
	^ aGolapVertex numberOfEdges
]

{ #category : #accessing }
GolapModel >> edgeBetween: data1 and: data2 ifAbsent: errorBlock [
	^ self
		edgeBetween: data1
		and: data2
		ifPresent: [ :edge | edge ]
		ifAbsent: errorBlock
]

{ #category : #accessing }
GolapModel >> edgeBetween: data1 and: data2 ifPresent: aBlock [
	^ self
		edgeBetween: data1
		and: data2
		ifPresent: aBlock
		ifAbsent: [  ]
]

{ #category : #accessing }
GolapModel >> edgeBetween: data1 and: data2 ifPresent: aBlock ifAbsent: errorBlock [
	| vertex1 vertex2 edge |
	vertex1 := self vertexAt: data1 ifAbsent: [ ^ errorBlock value ].
	vertex2 := self vertexAt: data2 ifAbsent: [ ^ errorBlock value ].
	edge := vertex1 edgeTo: vertex2 ifAbsent: [ ^ errorBlock value ].
	^ aBlock value: edge
]

{ #category : #'accessing-keys' }
GolapModel >> edgeKey [
	^ edgeKey ifNil: [ edgeKey := self defaultEdgeKey ]
]

{ #category : #'accessing-keys' }
GolapModel >> edgeKey: aString [
	edgeKey := aString
]

{ #category : #'visualizing-labels' }
GolapModel >> font [
	^ TextStyle defaultFont
]

{ #category : #accessing }
GolapModel >> frequencyAtVertex: aGolapVertex [
	^ aGolapVertex frequency
]

{ #category : #'accessing-keys' }
GolapModel >> frequencyKey [
	^ frequencyKey ifNil: [ frequencyKey := self defaultFrequencyKey ]
]

{ #category : #'accessing-keys' }
GolapModel >> frequencyKey1 [
	^ frequencyKey1 ifNil: [ frequencyKey1 := self defaultFrequencyKey1 ]
]

{ #category : #'accessing-keys' }
GolapModel >> frequencyKey1: aString [
	frequencyKey1 := aString
]

{ #category : #'accessing-keys' }
GolapModel >> frequencyKey2 [
	^ frequencyKey2 ifNil: [ frequencyKey2 := self defaultFrequencyKey2 ]
]

{ #category : #'accessing-keys' }
GolapModel >> frequencyKey2: aString [
	frequencyKey2 := aString
]

{ #category : #'accessing-keys' }
GolapModel >> frequencyKey: aString [
	frequencyKey := aString
]

{ #category : #operations }
GolapModel >> frequencyMode [
	self setFrequencyMode.
	graphEdges := nil.
	treeEdges := nil
]

{ #category : #accessing }
GolapModel >> friendsEdges [
	^ self friendsEdges: self friendsRank
]

{ #category : #accessing }
GolapModel >> friendsEdges: anInteger [

	| num |
	anInteger ifNil: [
		friendsEdges := nil.
		friendsRank := nil.
		^ Array new ].
	num := anInteger asInteger max: 1.
	friendsRank ~= num ifTrue: [ friendsEdges := nil ].
	^ friendsEdges ifNil: [
		  friendsRank := num.
		  friendsEdges := self computeFriendsEdges: friendsRank ]
]

{ #category : #accessing }
GolapModel >> friendsRank [
	^ friendsRank
]

{ #category : #accessing }
GolapModel >> graphEdges [
	^ graphEdges
		ifNil: [ | edges |
			edges := IdentitySet new.
			self
				verticesDo: [ :vertex | vertex edgesDo: [ :edge | edges add: edge ] ].
			edges := edges
				asSortedCollection: [ :more :less | 
					(self valueAtEdge: less)
						ifNil: [ true ]
						ifNotNil:
							[ :l | (self valueAtEdge: more) ifNil: [ false ] ifNotNil: [ :m | l <= m ] ] ].
			graphEdges := edges ]
]

{ #category : #accessing }
GolapModel >> hiddenEdgeBetween: data1 and: data2 ifAbsent: errorBlock [
	^ self
		hiddenEdgeBetween: data1
		and: data2
		ifPresent: [ :edge | edge ]
		ifAbsent: errorBlock
]

{ #category : #accessing }
GolapModel >> hiddenEdgeBetween: data1 and: data2 ifPresent: aBlock [
	^ self
		hiddenEdgeBetween: data1
		and: data2
		ifPresent: aBlock
		ifAbsent: [  ]
]

{ #category : #accessing }
GolapModel >> hiddenEdgeBetween: data1 and: data2 ifPresent: aBlock ifAbsent: errorBlock [
	| vertex1 vertex2 edge |
	vertex1 := self vertexAt: data1 ifAbsent: [ ^ errorBlock value ].
	vertex2 := self vertexAt: data2 ifAbsent: [ ^ errorBlock value ].
	edge := vertex1 hiddenEdgeTo: vertex2 ifAbsent: [ ^ errorBlock value ].
	^ aBlock value: edge
]

{ #category : #'accessing-vertex' }
GolapModel >> idForVertex: aGolapVertex [
	^ self vertices keyAtValue: aGolapVertex
]

{ #category : #initialization }
GolapModel >> initialize [
	super initialize.
	aggregation := #frequency.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedVertices := IdentityDictionary new
]

{ #category : #'accessing-keys' }
GolapModel >> jaccardKey [
	^ jaccardKey ifNil: [ jaccardKey := self defaultJaccardKey ]
]

{ #category : #'accessing-keys' }
GolapModel >> jaccardKey: aString [
	jaccardKey := aString
]

{ #category : #operations }
GolapModel >> jaccardMode [
	self setJaccardMode.
	graphEdges := nil.
	treeEdges := nil
]

{ #category : #'accessing-keys' }
GolapModel >> liftKey [
	^ liftKey ifNil: [ liftKey := self defaultLiftKey ]
]

{ #category : #'accessing-keys' }
GolapModel >> liftKey: aString [
	liftKey := aString
]

{ #category : #operations }
GolapModel >> liftMode [
	self setLiftMode.
	graphEdges := nil.
	treeEdges := nil
]

{ #category : #accessing }
GolapModel >> maxEdgeValueAtVertex: aGolapVertex [
	| value |
	value := 0.
	aGolapVertex
		edgesDo: [ :edge | value := value max: (self valueAtEdge: edge) ].
	^ value
]

{ #category : #'accessing-vertex' }
GolapModel >> mergeVertices: aCollectionOfGolapVertex named: aString [
	| frequency newVertex newEdges oldEdges |
	frequency := aCollectionOfGolapVertex
		inject: 0
		into: [ :subtotal :v | v frequency + subtotal ].
	newVertex := GolapMergedVertex on: aString name: aString.
	newEdges := IdentityDictionary new.
	oldEdges := OrderedCollection
		new: aCollectionOfGolapVertex size * aCollectionOfGolapVertex size.
	aCollectionOfGolapVertex
		do: [ :vertex | 
			(Array
				streamContents: [ :stream | vertex edgesDo: [ :e | stream nextPut: e ] ])
				do: [ :edge | 
					| peer |
					peer := edge peerOf: vertex.
					newVertex == peer
						ifTrue: [ edge remove.
							newEdges removeKey: vertex ]
						ifFalse: [ (newEdges includesKey: peer)
								ifTrue: [ | newEdge |
									newEdge := newEdges at: peer.
									newEdge data
										at: 'frequency'
										put: (newEdge data at: 'frequency') + (edge at: 'frequency').
									#('support' 'jaccard' 'lift' 'PMI')
										do: [ :key | 
											newEdge data
												at: key
												put:
													(newEdge data at: key)
														+ ((edge data at: key) * (edge data at: 'frequency')) ].
									edge remove.
									oldEdges add: edge ]
								ifFalse: [ | newEdge |
									newEdge := edge copy.
									#('support' 'jaccard' 'lift' 'PMI')
										do: [ :key | 
											newEdge data
												at: key
												put: (newEdge data at: key) * (newEdge data at: 'frequency') ].
									edge remove.
									newEdge basicReplaceVertex: vertex with: newVertex.
									newVertex addEdge: newEdge.
									peer addEdge: newEdge.
									oldEdges add: edge.
									newEdges at: peer put: newEdge ] ] ].
			self vertices removeKey: vertex data ].
	newEdges
		do: [ :edge | 
			#('support' 'jaccard' 'lift' 'PMI')
				do: [ :key | 
					edge data
						at: key
						put: (edge data at: key) / (edge data at: 'frequency') ] ].
	newVertex
		x:
			((aCollectionOfGolapVertex collect: #x thenSelect: #notNil)
				ifEmpty: [ nil ]
				ifNotEmpty: #average);
		y:
			((aCollectionOfGolapVertex collect: #y thenSelect: #notNil)
				ifEmpty: [ nil ]
				ifNotEmpty: #average);
		frequency: frequency;
		oldEdges: oldEdges asArray;
		oldVertices: aCollectionOfGolapVertex asArray.
	self vertices at: aString put: newVertex.
	treeEdges := nil.
	graphEdges := nil.
	friendsEdges := nil.
	self friendsEdges: self friendsRank.
	^ newVertex
]

{ #category : #polishing }
GolapModel >> negativePolishEdgesDo: aBlock [
	negativePolishEdges do: aBlock
]

{ #category : #'accessing-keys' }
GolapModel >> nodeKey1 [
	^ nodeKey1 ifNil: [ nodeKey1 := self defaultNodeKey1 ]
]

{ #category : #'accessing-keys' }
GolapModel >> nodeKey1: aString [
	nodeKey1 := aString
]

{ #category : #'accessing-keys' }
GolapModel >> nodeKey2 [
	^ nodeKey2 ifNil: [ nodeKey2 := self defaultNodeKey2 ]
]

{ #category : #'accessing-keys' }
GolapModel >> nodeKey2: aString [
	nodeKey2 := aString
]

{ #category : #'accessing-keys' }
GolapModel >> nodeNameKey1 [
	^ nodeNameKey1 ifNil: [ nodeNameKey1 := self defaultNodeNameKey1 ]
]

{ #category : #'accessing-keys' }
GolapModel >> nodeNameKey1: aString [
	nodeNameKey1 := aString
]

{ #category : #'accessing-keys' }
GolapModel >> nodeNameKey2 [
	^ nodeNameKey2 ifNil: [ nodeNameKey2 := self defaultNodeNameKey2 ]
]

{ #category : #'accessing-keys' }
GolapModel >> nodeNameKey2: aString [
	nodeNameKey2 := aString
]

{ #category : #visualization }
GolapModel >> openSunburst [

	(GolapHierarchicalClustering on: self)
		rank: 2;
		rank: 4;
		rank: 8;
		rank: 16;
		rank: 32;
		rank: 64;
		rank: 128;
		rank: 256;
		openSunburst
]

{ #category : #'accessing-keys' }
GolapModel >> pmiKey [
	^ pmiKey ifNil: [ pmiKey := self defaultPMIKey ]
]

{ #category : #'accessing-keys' }
GolapModel >> pmiKey: aString [
	pmiKey := aString
]

{ #category : #operations }
GolapModel >> pmiMode [
	self setPMIMode.
	graphEdges := nil.
	treeEdges := nil
]

{ #category : #polishing }
GolapModel >> polishAddAbove: aNumber1 removeBelow: aNumber2 minDenominator: anInteger [
	| changed hop2peers edges |
	changed := false.
	hop2peers := IdentityDictionary new.
	edges := IdentitySet new.
	self
		verticesDo: [ :v1 | 
			| peers |
			peers := hop2peers at: v1 put: IdentityDictionary new.
			v1
				edgesAndVerticesDo: [ :e1 :v2 | 
					edges add: e1.
					v2
						edgesAndVerticesDo: [ :e2 :v3 | 
							v1 data < v3 data
								ifTrue: [ peers at: v3 put: (peers at: v3 ifAbsent: [ 0 ]) + 1 ] ] ] ].
	hop2peers
		keysAndValuesDo: [ :v1 :peersAndDups | 
			peersAndDups
				keysAndValuesDo: [ :v2 :dups | 
					(v1 hasPeerVertex: v2)
						ifFalse: [ | denominator |
							denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
							denominator > anInteger
								ifTrue: [ dups asFloat / (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat
										> aNumber1
										ifTrue: [ changed := true.
											(self removeNegativePolishEdgeBetween: v1 and: v2)
												ifNil: [ | newEdge |
													newEdge := GolapEdge on: nil between: v1 and: v2.
													v1 addPositivePolishEdge: newEdge.
													v2 addPositivePolishEdge: newEdge.
													self addPositivePolishEdge: newEdge ] ] ] ] ] ].
	edges
		do: [ :edge | 
			| v1 v2 peersAndDups |
			edge vertex1 data <= edge vertex2 data
				ifTrue: [ v1 := edge vertex1.
					v2 := edge vertex2 ]
				ifFalse: [ v1 := edge vertex2.
					v2 := edge vertex1 ].
			peersAndDups := hop2peers at: v1.
			((peersAndDups includesKey: v2) not
				or: [ | dups denominator |
					dups := peersAndDups at: v2.
					denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
					denominator > anInteger
						and: [ dups asFloat / (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat
								< aNumber2 ] ])
				ifTrue: [ changed := true.
					(self removePositivePolishEdgeBetween: v1 and: v2)
						ifNil: [ v1 addNegativePolishEdge: edge.
							v2 addNegativePolishEdge: edge.
							self addNegativePolishEdge: edge ] ] ].
	graphEdges := nil.
	treeEdges := nil.
	friendsEdges := nil.
	^ changed
]

{ #category : #polishing }
GolapModel >> positivePolishEdgesDo: aBlock [
	positivePolishEdges do: aBlock
]

{ #category : #copying }
GolapModel >> postCopy [
	super postCopy.
	friendsEdges := nil.
	friendsRank := nil.
	graphEdges := nil.
	treeEdges := nil
]

{ #category : #'accessing-vertex' }
GolapModel >> recreateVertices [
	vertices := self createVerticesFromDataframe.
	self resetPolish
]

{ #category : #polishing }
GolapModel >> removeNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : #polishing }
GolapModel >> removeNegativePolishEdgeBetween: aGolapVertex1 and: aGolapVertex2 [
	^ (aGolapVertex1 negativePolishEdgeWith: aGolapVertex2)
		ifNotNil: [ :edge | 
			aGolapVertex1 removeNegativePolishEdge: edge.
			aGolapVertex2 removeNegativePolishEdge: edge.
			self removeNegativePolishEdge: edge.
			edge ]
]

{ #category : #polishing }
GolapModel >> removePositivePolishEdge: aGolapEdge [
	^ positivePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : #polishing }
GolapModel >> removePositivePolishEdgeBetween: aGolapVertex1 and: aGolapVertex2 [
	self
		positivePolishEdgesDo: [ :edge | 
			((aGolapVertex1 == edge vertex1 and: [ aGolapVertex2 == edge vertex2 ])
				or:
					[ aGolapVertex1 == edge vertex2 and: [ aGolapVertex2 == edge vertex1 ] ])
				ifTrue: [ aGolapVertex1 removePositivePolishEdge: edge.
					aGolapVertex2 removePositivePolishEdge: edge.
					self removePositivePolishEdge: edge.
					^ edge ] ].
	^ nil
]

{ #category : #polishing }
GolapModel >> repeat: anInteger1 polishAddAbove: aNumber1 removeBelow: aNumber2 minDenominator: anInteger2 [
	self resetPolish.
	anInteger1
		timesRepeat: [ (self
				polishAddAbove: aNumber1
				removeBelow: aNumber2
				minDenominator: anInteger2)
				ifFalse: [ ^ self ] ]
]

{ #category : #polishing }
GolapModel >> resetPolish [
	self verticesDo: [ :v | v resetPolish ].
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new
]

{ #category : #operations }
GolapModel >> setFrequencyMode [
	self edgeKey: self frequencyKey
]

{ #category : #operations }
GolapModel >> setFullGraphMode [
	self friendsEdges: nil.
	friendsEdges := nil.
	treeEdges := nil.
	self graphEdges
]

{ #category : #operations }
GolapModel >> setJaccardMode [
	self edgeKey: self jaccardKey
]

{ #category : #operations }
GolapModel >> setLiftMode [
	self edgeKey: self liftKey
]

{ #category : #operations }
GolapModel >> setPMIMode [
	self edgeKey: self pmiKey
]

{ #category : #operations }
GolapModel >> setTreeMode [
	self friendsEdges: nil.
	friendsEdges := nil.
	self treeEdges
]

{ #category : #accessing }
GolapModel >> sumEdgeValueAtVertex: aGolapVertex [

	| value |
	value := 0.
	aGolapVertex edgesDo: [ :edge | 
		value := value + (self valueAtEdge: edge) ].
	^ value
]

{ #category : #'accessing-keys' }
GolapModel >> totalKey [
	^ totalKey ifNil: [ totalKey := self defaultTotalKey ]
]

{ #category : #'accessing-keys' }
GolapModel >> totalKey: aString [
	totalKey := aString
]

{ #category : #accessing }
GolapModel >> treeEdges [
	^ treeEdges
		ifNil: [ | edges subgraphs spanEdges |
			edges := self graphEdges.
			subgraphs := self vertices asArray collect: [ :vertex | Set with: vertex ].
			spanEdges := OrderedCollection new: self vertices size // 2 + 1.
			edges
				do: [ :edge | 
					| v1 v2 g1 g2 |
					v1 := edge vertex1.
					v2 := edge vertex2.
					g1 := subgraphs detect: [ :s | s includes: v1 ] ifNone: [ nil ].
					g2 := subgraphs detect: [ :s | s includes: v2 ] ifNone: [ nil ].
					g1 ~~ g2
						ifTrue: [ spanEdges add: edge.
							g1 addAll: g2.
							subgraphs := subgraphs reject: [ :g | g == g2 ] ] ].
			treeEdges := spanEdges ]
]

{ #category : #'accessing-vertex' }
GolapModel >> unmergeVertex: aGolapVertex [
	aGolapVertex isMergedVertex
		ifFalse: [ ^ self ].
	aGolapVertex
		oldVerticesDo: [ :vertex | self vertices at: vertex data put: vertex ].
	aGolapVertex
		oldEdgesDo: [ :edge | 
			(edge vertex1 hasEdge: edge)
				ifFalse: [ edge vertex1 addEdge: edge ].
			(edge vertex2 hasEdge: edge)
				ifFalse: [ edge vertex2 addEdge: edge ] ].
	aGolapVertex
		edgesAndVerticesDo: [ :edge :peer | peer removeEdge: edge ].
	self vertices removeKey: aGolapVertex data.
	^ aGolapVertex
]

{ #category : #accessing }
GolapModel >> valueAtEdge: aGolapEdge [

	^ aGolapEdge at: self edgeKey
]

{ #category : #accessing }
GolapModel >> valueAtVertex: aGolapVertex [
	aggregation = #max
		ifTrue: [ ^ self maxEdgeValueAtVertex: aGolapVertex ].
	aggregation = #sum
		ifTrue: [ ^ self sumEdgeValueAtVertex: aGolapVertex ].
	aggregation = #average
		ifTrue: [ ^ self averageEdgeValueAtVertex: aGolapVertex ].
	aggregation = #degree
		ifTrue: [ ^ self degreeEdgeValueAtVertex: aGolapVertex ].
	^ self frequencyAtVertex: aGolapVertex
]

{ #category : #'accessing-vertex' }
GolapModel >> vertexAt: anInteger [
	^ self vertices at: anInteger
]

{ #category : #'accessing-vertex' }
GolapModel >> vertexAt: anInteger ifAbsent: errorBlock [
	^ self vertices at: anInteger ifAbsent: errorBlock
]

{ #category : #accessing }
GolapModel >> vertexListWithKeyword: aString [
	| list column |
	list := DataFrame new: 0 @ 3.
	self
		verticesDo: [ :vertex :id | 
			| name |
			name := vertex name.
			(aString isEmpty or: [ (name findString: aString) > 0 ])
				ifTrue: [ list
						addRow:
							(DataSeries
								newFrom:
									{name.
									(self valueAtVertex: vertex).
									id})
						named: id printString ] ].
	column := self aggregation = #frequency
		ifTrue: [ 'Frequency' ]
		ifFalse: [ self aggregation asString , ' ' , self edgeKey ].
	list
		columnNames:
			{'product'.
			column.
			'id'}.
	list sortDescendingBy: column.
	^ list
]

{ #category : #'accessing-vertex' }
GolapModel >> vertices [
	^ vertices ifNil: [ vertices := self createVerticesFromDataframe ]
]

{ #category : #enumerating }
GolapModel >> verticesDo: aBlock [
	self vertices
		keysAndValuesDo: [ :key :vertex | aBlock cull: vertex cull: key ]
]
