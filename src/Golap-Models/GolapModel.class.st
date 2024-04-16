Class {
	#name : #GolapModel,
	#superclass : #Model,
	#instVars : [
		'vertexEvaluator',
		'edgeEvaluator',
		'dataframe',
		'vertices',
		'treeEdges',
		'friendsEdges',
		'friendsRank',
		'graphEdges',
		'positivePolishEdges',
		'negativePolishEdges',
		'mergedVertices',
		'vertexAggregationMap',
		'edgeAggregationMap'
	],
	#category : #'Golap-Models-Graph'
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
GolapModel >> - aGolapModel [

	| dataframe2 diff rowNames diffDataframe frequencies1 frequencies2 diffFrequencies |
	dataframe2 := aGolapModel dataframe.
	diff := Dictionary new:
		        dataframe numberOfRows + dataframe2 numberOfRows.
	frequencies1 := Dictionary new.
	dataframe do: [ :row |
		frequencies1
			at: (row at: 'node1')
			ifAbsentPut: (row at: 'frequency1').
		frequencies1
			at: (row at: 'node2')
			ifAbsentPut: (row at: 'frequency2') ].
	frequencies2 := Dictionary new.
	dataframe2 do: [ :row |
		frequencies2
			at: (row at: 'node1')
			ifAbsentPut: (row at: 'frequency1').
		frequencies2
			at: (row at: 'node2')
			ifAbsentPut: (row at: 'frequency2') ].
	diffFrequencies := frequencies1.
	frequencies2 keysAndValuesDo: [ :node :freq |
		diffFrequencies
			at: node
			put: (diffFrequencies at: node ifAbsent: [ 0 ]) - freq ].
	frequencies1 := nil.
	frequencies2 := nil.
	1 to: dataframe numberOfRows do: [ :index |
		| dataseries |
		dataseries := DataSeries newFrom: (dataframe rowAt: index).
		dataseries name: {
				(dataseries at: 'node1').
				(dataseries at: 'node2') }.
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
		node1 := dataseries2 at: 'node1'.
		node2 := dataseries2 at: 'node2'.
		diffDataseries := diff
			                  at: {
					                  node1.
					                  node2 }
			                  ifAbsent: [
				                  | ds |
				                  ds := (DataSeries newFrom: dataseries2)
					                        at: 'frequency' put: 0;
					                        at: 'frequency1'
					                        put: (diffFrequencies at: node1);
					                        at: 'frequency2'
					                        put: (diffFrequencies at: node2);
					                        at: 'total' put: 0;
					                        at: 'support' put: 0.0;
					                        at: 'confidence' put: 0.0;
					                        at: 'lift' put: 0.0;
					                        at: 'jaccard' put: 0.0;
					                        at: 'PMI' put: 0.0;
					                        at: 'effective' put: 0;
					                        name: {
							                        node1.
							                        node2 };
					                        yourself.
				                  diff at: ds name put: ds.
				                  ds ].
		{ 'frequency'. 'total'. 'support'. 'confidence'. 'lift'. 'jaccard'.
		'PMI' } do: [ :key |
			diffDataseries at: key transform: [ :v |
				v
					ifNil: [ (dataseries2 at: key) ifNil: [ 0.0 ] ]
					ifNotNil: [ v - ((dataseries2 at: key) ifNil: [ 0.0 ]) ] ] ].
		diffDataseries
			at: 'effective'
			transform: [ :v | v + (dataseries2 at: 'effective') ].
		diff
			at: {
					node1.
					node2 }
			put: diffDataseries ].
	rowNames := (diff keys asSortedCollection: [ :less :more |
		             less first < more first or: [
			             more second isNil or: [
				             less second notNil and: [ less second <= more second ] ] ] ])
		            asArray.
	diffDataframe := DataFrame
		                 withRows:
		                 (rowNames collect: [ :key | (diff at: key) asArray ])
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
					    (self valueAtEdge: e) ifNotNil: [ :value |
						    stream nextPut: e -> value ] ] ]) asSortedCollection: [
				   :more
				   :less | less value <= more value ]) readStream next: anInteger)
				 collect: #key) ].
	^ Array streamContents: [ :stream |
		  edges doWithOccurrences: [ :e :n |
			  n >= 2 ifTrue: [ stream nextPut: e ] ] ]
]

{ #category : #private }
GolapModel >> createMergedVertexFrom: aCollectionOfGolapVertex named: aString [

	^ aCollectionOfGolapVertex
		  ifNotEmpty: [
			  | oldData newData |
			  oldData := aCollectionOfGolapVertex collect: #data.
			  newData := vertexAggregationMap collect: [ :aggregation |
				             aggregation value: oldData ].
			  newData at: aCollectionOfGolapVertex first nameKey put: aString.
			  GolapMergedVertex
				  on: (DataSeries
						   withKeys: newData keys
						   values: newData values
						   name: aString)
				  nameKey: aCollectionOfGolapVertex first nameKey ]
		  ifEmpty: [ nil ]
]

{ #category : #'accessing-vertex' }
GolapModel >> createVertex: anInteger name: aString frequency: aNumber [

	^ GolapVertex
		  on: (DataSeries
				   withKeys: { 'name'. 'frequency' }
				   values: {
						   aString.
						   aNumber }
				   name: anInteger)
		  nameKey: 'name'
]

{ #category : #'accessing-vertex' }
GolapModel >> createVerticesFromServerDataframe: aDataFrame [

	| newVertices |
	newVertices := Dictionary new.
	aDataFrame do: [ :data |
		| node1 node2 vertex1 vertex2 |
		node1 := data at: 'node1'.
		node2 := data at: 'node2'.
		vertex1 := newVertices at: node1 ifAbsentPut: [
			           self
				           createVertex: node1
				           name: (data at: 'node1n')
				           frequency: (data at: 'frequency1') ].
		node2 ifNotNil: [
			vertex2 := newVertices at: node2 ifAbsentPut: [
				           self
					           createVertex: node2
					           name: (data at: 'node2n')
					           frequency: (data at: 'frequency2') ].
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

	| newVertices |
	aDataFrame columnNames: (aDataFrame columnNames collect: [ :string |
			 (string includes: $%)
				 ifTrue: [ string copyFrom: 1 to: (string indexOf: $%) - 1 ]
				 ifFalse: [ string ] ]).
	dataframe := aDataFrame.
	vertexEvaluator := GolapVertexColumnEvaluator
		                   on: self
		                   column: 'frequency'.
	edgeEvaluator := GolapEdgeColumnEvaluator on: self column: 'jaccard'.
	vertexAggregationMap := { ('frequency'
	                         ->
	                         (GolapSumDataAggregator column: 'frequency')) }
		                        asOrderedDictionary.
	edgeAggregationMap := {
		                      ('frequency'
		                       ->
		                       (GolapSumDataAggregator column: 'frequency')).
		                      ('total'
		                       -> (GolapSumDataAggregator column: 'total')).
		                      ('support'
		                       -> (GolapWeightedAverageDataAggregator
				                        column: 'supoort'
				                        weightColumn: 'frequency')).
		                      ('jaccard'
		                       -> (GolapWeightedAverageDataAggregator
				                        column: 'jaccard'
				                        weightColumn: 'frequency')).
		                      ('lift'
		                       -> (GolapWeightedAverageDataAggregator
				                        column: 'lift'
				                        weightColumn: 'frequency')).
		                      ('PMI' -> (GolapWeightedAverageDataAggregator
			                        column: 'PMI'
			                        weightColumn: 'frequency')) }
		                      asOrderedDictionary.
	newVertices := Dictionary new.
	aDataFrame do: [ :data |
		| node1 node2 vertex1 vertex2 |
		node1 := data at: 'node1'.
		node2 := data at: 'node2'.
		vertex1 := newVertices at: node1 ifAbsentPut: [
			           self
				           createVertex: node1
				           name: (data at: 'node1n')
				           frequency: (data at: 'frequency1') ].
		node2 ifNotNil: [
			vertex2 := newVertices at: node2 ifAbsentPut: [
				           self
					           createVertex: node2
					           name: (data at: 'node2n')
					           frequency: (data at: 'frequency2') ].
			(data at: 'effective' ifAbsent: [ 1 ]) > 0
				ifTrue: [ vertex1 createEdgeTo: vertex2 data: data ]
				ifFalse: [ vertex1 createHiddenEdgeTo: vertex2 data: data ] ] ].
	vertices := newVertices
]

{ #category : #accessing }
GolapModel >> edgeAggregationMap [

	^ edgeAggregationMap
]

{ #category : #accessing }
GolapModel >> edgeAggregationMap: aDictionary [

	edgeAggregationMap := aDictionary
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

{ #category : #accessing }
GolapModel >> edgeEvaluator [

	^ edgeEvaluator
]

{ #category : #accessing }
GolapModel >> edgeEvaluator: aGolapEdgeEvaluator [

	edgeEvaluator := aGolapEdgeEvaluator
]

{ #category : #'visualizing-labels' }
GolapModel >> font [
	^ TextStyle defaultFont
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

{ #category : #initialization }
GolapModel >> initialize [

	super initialize.
	vertexEvaluator := GolapVertexColumnEvaluator
		                   on: self
		                   column: 'frequency'.
	edgeEvaluator := GolapEdgeColumnEvaluator on: self column: 'jaccard'.
	vertexAggregationMap := { ('frequency'
	                         ->
	                         (GolapSumDataAggregator column: 'frequency')) }
		                        asOrderedDictionary.
	edgeAggregationMap := {
		                      ('frequency'
		                       ->
		                       (GolapSumDataAggregator column: 'frequency')).
		                      ('total'
		                       -> (GolapSumDataAggregator column: 'total')).
		                      ('support'
		                       -> (GolapWeightedAverageDataAggregator
				                        column: 'supoort'
				                        weightColumn: 'frequency')).
		                      ('jaccard'
		                       -> (GolapWeightedAverageDataAggregator
				                        column: 'jaccard'
				                        weightColumn: 'frequency')).
		                      ('lift'
		                       -> (GolapWeightedAverageDataAggregator
				                        column: 'lift'
				                        weightColumn: 'frequency')).
		                      ('PMI' -> (GolapWeightedAverageDataAggregator
			                        column: 'PMI'
			                        weightColumn: 'frequency')) }
		                      asOrderedDictionary.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedVertices := IdentityDictionary new
]

{ #category : #operations }
GolapModel >> jaccardMode [
	self setJaccardMode.
	graphEdges := nil.
	treeEdges := nil
]

{ #category : #operations }
GolapModel >> liftMode [
	self setLiftMode.
	graphEdges := nil.
	treeEdges := nil
]

{ #category : #'accessing-vertex' }
GolapModel >> mergeVertices: aCollectionOfGolapVertex named: aString [

	aCollectionOfGolapVertex ifNotEmpty: [
		| newVertex newEdges oldEdges |
		newVertex := self
			             createMergedVertexFrom: aCollectionOfGolapVertex
			             named: aString.
		newEdges := IdentityDictionary new.
		oldEdges := OrderedCollection new:
			            aCollectionOfGolapVertex size
			            * aCollectionOfGolapVertex size.
		aCollectionOfGolapVertex do: [ :vertex |
			(Array streamContents: [ :stream |
				 vertex edgesDo: [ :e | stream nextPut: e ] ]) do: [ :edge |
				| peer |
				peer := edge peerOf: vertex.
				newVertex == peer
					ifTrue: [
						edge remove.
						newEdges removeKey: vertex ]
					ifFalse: [
						(newEdges includesKey: peer)
							ifTrue: [
								| newEdge |
								newEdge := newEdges at: peer.
								newEdge
									at: 'frequency'
									put: (newEdge at: 'frequency') + (edge at: 'frequency').
								#( 'support' 'jaccard' 'lift' 'PMI' ) do: [ :key |
									newEdge
										at: key
										put:
										(newEdge at: key)
										+ ((edge at: key) * (edge at: 'frequency')) ].
								edge remove.
								oldEdges add: edge ]
							ifFalse: [
								| newEdge |
								newEdge := edge copy.
								#( 'support' 'jaccard' 'lift' 'PMI' ) do: [ :key |
									newEdge
										at: key
										put: (newEdge at: key) * (newEdge at: 'frequency') ].
								edge remove.
								newEdge basicReplaceVertex: vertex with: newVertex.
								newVertex addEdge: newEdge.
								peer addEdge: newEdge.
								oldEdges add: edge.
								newEdges at: peer put: newEdge ] ] ].
			self vertices removeKey: vertex id ].
		newEdges do: [ :edge |
			#( 'support' 'jaccard' 'lift' 'PMI' ) do: [ :key |
				edge at: key put: (edge at: key) / (edge at: 'frequency') ] ].
		newVertex
			x: ((aCollectionOfGolapVertex collect: #x thenSelect: #notNil)
					 ifEmpty: [ nil ]
					 ifNotEmpty: #average);
			y: ((aCollectionOfGolapVertex collect: #y thenSelect: #notNil)
					 ifEmpty: [ nil ]
					 ifNotEmpty: #average);
			oldEdges: oldEdges asArray;
			oldVertices:
				(aCollectionOfGolapVertex asArray sorted:
						 vertexEvaluator descending).
		self vertices at: aString put: newVertex.
		treeEdges := nil.
		graphEdges := nil.
		friendsEdges := nil.
		self friendsEdges: self friendsRank.
		^ newVertex ]
]

{ #category : #polishing }
GolapModel >> negativePolishEdgesDo: aBlock [
	negativePolishEdges do: aBlock
]

{ #category : #visualization }
GolapModel >> openSunburst [
	"(GolapHierarchicalClustering on: self)
		rank: 2;
		rank: 4;
		rank: 8;
		rank: 16;
		rank: 32;
		rank: 64;
		rank: 128;
		rank: 256;
		openSunburst"

	(GolapDandelionChartPresenter new
		 golap: self;
		 yourself) open
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
	self verticesDo: [ :v1 |
		| peers |
		peers := hop2peers at: v1 put: IdentityDictionary new.
		v1 edgesAndVerticesDo: [ :e1 :v2 |
			edges add: e1.
			v2 edgesAndVerticesDo: [ :e2 :v3 |
				v1 id < v3 id ifTrue: [
					peers at: v3 put: (peers at: v3 ifAbsent: [ 0 ]) + 1 ] ] ] ].
	hop2peers keysAndValuesDo: [ :v1 :peersAndDups |
		peersAndDups keysAndValuesDo: [ :v2 :dups |
			(v1 hasPeerVertex: v2) ifFalse: [
				| denominator |
				denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
				denominator > anInteger ifTrue: [
					dups asFloat
					/ (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat > aNumber1
						ifTrue: [
							changed := true.
							(self removeNegativePolishEdgeBetween: v1 and: v2) ifNil: [
								| newEdge |
								newEdge := GolapEdge on: nil between: v1 and: v2.
								v1 addPositivePolishEdge: newEdge.
								v2 addPositivePolishEdge: newEdge.
								self addPositivePolishEdge: newEdge ] ] ] ] ] ].
	edges do: [ :edge |
		| v1 v2 peersAndDups |
		edge vertex1 id <= edge vertex2 id
			ifTrue: [
				v1 := edge vertex1.
				v2 := edge vertex2 ]
			ifFalse: [
				v1 := edge vertex2.
				v2 := edge vertex1 ].
		peersAndDups := hop2peers at: v1.
		((peersAndDups includesKey: v2) not or: [
			 | dups denominator |
			 dups := peersAndDups at: v2.
			 denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
			 denominator > anInteger and: [
				 dups asFloat
				 / (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat < aNumber2 ] ])
			ifTrue: [
				changed := true.
				(self removePositivePolishEdgeBetween: v1 and: v2) ifNil: [
					v1 addNegativePolishEdge: edge.
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

	vertices := self createVerticesFromServerDataframe: dataframe.
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

	self edgeEvaluator:
		(GolapEdgeColumnEvaluator on: self column: 'frequency')
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

	self edgeEvaluator:
		(GolapEdgeColumnEvaluator on: self column: 'jaccard')
]

{ #category : #operations }
GolapModel >> setLiftMode [

	self edgeEvaluator:
		(GolapEdgeColumnEvaluator on: self column: 'lift')
]

{ #category : #operations }
GolapModel >> setPMIMode [

	self edgeEvaluator: (GolapEdgeColumnEvaluator on: self column: 'PMI')
]

{ #category : #operations }
GolapModel >> setTreeMode [
	self friendsEdges: nil.
	friendsEdges := nil.
	self treeEdges
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

	aGolapVertex isMergedVertex ifFalse: [ ^ self ].
	aGolapVertex oldVerticesDo: [ :vertex |
		self vertices at: vertex id put: vertex ].
	aGolapVertex oldEdgesDo: [ :edge |
		(edge vertex1 hasEdge: edge) ifFalse: [ edge vertex1 addEdge: edge ].
		(edge vertex2 hasEdge: edge) ifFalse: [ edge vertex2 addEdge: edge ] ].
	aGolapVertex edgesAndVerticesDo: [ :edge :peer |
		peer removeEdge: edge ].
	self vertices removeKey: aGolapVertex id.
	^ aGolapVertex
]

{ #category : #accessing }
GolapModel >> valueAtEdge: aGolapEdge [

	^ edgeEvaluator value: aGolapEdge
]

{ #category : #accessing }
GolapModel >> valueAtVertex: aGolapVertex [

	^ vertexEvaluator value: aGolapVertex
]

{ #category : #accessing }
GolapModel >> vertexAggregationMap [

	^ vertexAggregationMap
]

{ #category : #accessing }
GolapModel >> vertexAggregationMap: aDictionary [

	vertexAggregationMap := aDictionary
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
GolapModel >> vertexEvaluator [

	^ vertexEvaluator
]

{ #category : #accessing }
GolapModel >> vertexEvaluator: aGolapVertexEvaluator [

	vertexEvaluator := aGolapVertexEvaluator
]

{ #category : #accessing }
GolapModel >> vertexListWithKeyword: aString [

	| list column |
	list := DataFrame new: 0 @ 3.
	self verticesDo: [ :vertex :id |
		| name |
		name := vertex name.
		(aString isEmpty or: [ (name findString: aString) > 0 ]) ifTrue: [
			list
				addRow: (DataSeries newFrom: {
							 name.
							 (self valueAtVertex: vertex).
							 id })
				named: id printString ] ].
	column := self vertexEvaluator name.
	list columnNames: {
			'product'.
			column.
			'id' }.
	list sortDescendingBy: column.
	^ list
]

{ #category : #'accessing-vertex' }
GolapModel >> vertices [

	^ vertices ifNil: [
		  vertices := self createVerticesFromServerDataframe: dataframe ]
]

{ #category : #enumerating }
GolapModel >> verticesDo: aBlock [
	self vertices
		keysAndValuesDo: [ :key :vertex | aBlock cull: vertex cull: key ]
]
