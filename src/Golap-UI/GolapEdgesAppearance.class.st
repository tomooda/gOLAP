Class {
	#name : 'GolapEdgesAppearance',
	#superclass : 'SpPresenter',
	#instVars : [
		'golap',
		'edgeEvaluatorList',
		'nodeEvaluatorList'
	],
	#classVars : [
		'NamedColors'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'colors' }
GolapEdgesAppearance class >> colorAt: aSymbol [
	^ self colorMap at: aSymbol ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GolapEdgesAppearance class >> colorMap [
	^ NamedColors
		ifNil: [ NamedColors := OrderedDictionary new
				at: nil put: nil;
				at: #gray put: Color gray;
				at: #black put: Color black;
				at: #red put: Color red;
				at: #darkRed put: Color red muchDarker;
				at: #blue put: Color blue;
				at: #darkBlue put: Color blue muchDarker;
				at: #green put: Color green;
				at: #darkGreen put: Color green muchDarker;
				at: #magenta put: Color magenta;
				at: #darkMagenta put: Color magenta muchDarker;
				at: #cyan put: Color cyan;
				at: #darkCyan put: Color cyan muchDarker;
				at: #yellow put: Color yellow;
				at: #darkYellow put: Color yellow muchDarker;
				yourself ]
]

{ #category : 'colors' }
GolapEdgesAppearance class >> colorNames [
	^ self colorMap keys
]

{ #category : 'instance creation' }
GolapEdgesAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : 'layout' }
GolapEdgesAppearance >> buttonHeight [

	^ self class buttonHeight
]

{ #category : 'layout' }
GolapEdgesAppearance >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: '関連指標' asPresenter expand: true;
				   add: edgeEvaluatorList width: 150)
		  height: self buttonHeight;
		  add: (SpBoxLayout newHorizontal
				   add: 'アイテム指標' asPresenter expand: true;
				   add: nodeEvaluatorList width: 150)
		  height: self buttonHeight;
		  yourself
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluator [

	^ edgeEvaluatorList selectedItem
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluator: aGolapEdgeEvaluator [

	aGolapEdgeEvaluator ifNotNil: [
			golap model ifNotNil: [ :model |
					self updateGlobalImageAfter: [
							model edgeEvaluator: aGolapEdgeEvaluator.
							model flushFriendsEdges.
							golap updateQuery.
							nodeEvaluatorList withAdapterDo: [ :a |
								a widgetDo: [ :w | w updateContents ] ].
							golap announceGolapModelUpdated ] ] ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluators [

	^ edgeEvaluatorList items
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluators: aCollectionOfGolapEdgeEvaluator [

	edgeEvaluatorList items: aCollectionOfGolapEdgeEvaluator
]

{ #category : 'operations' }
GolapEdgesAppearance >> friendsGraph [

	self updateGlobalImageAfter: [ golap announceGolapModelUpdated ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> iconExtent [
	^ 30 @ 14
]

{ #category : 'accessing' }
GolapEdgesAppearance >> iconFor: aSymbol [

	^ self iconForColor: (golap ifNotNil: [ golap perform: aSymbol ])
]

{ #category : 'accessing' }
GolapEdgesAppearance >> iconForColor: aColor [
	^ aColor
		ifNotNil: [ | icon |
			icon := Form extent: self iconExtent depth: 32.
			icon getCanvas
				fillColor: aColor;
				frameRectangle: (0 @ 0 extent: icon extent - (1 @ 1))
					width: 2
					color: Color black.
			icon ]
		ifNil: [ self nilIcon ]
]

{ #category : 'initialization' }
GolapEdgesAppearance >> initialExtent [
	^ 500@280
]

{ #category : 'initialization' }
GolapEdgesAppearance >> initializePresenters [

	edgeEvaluatorList := self newDropList
		                     items:
			                     (#( 'frequency' 'jaccard' 'lift' 'PMI' )
				                      collect: [ :column |
					                      GolapEdgeColumnEvaluator column: column ]);
		                     display: [ :item | item name ];
		                     startWithSelection;
		                     whenSelectedItemChangedDo: [ :edgeEvaluator |
			                     self edgeEvaluator: edgeEvaluator ];
		                     yourself.
	nodeEvaluatorList := self newDropList
		                     items: {
				                     (GolapNodeColumnEvaluator column: 'frequency').
				                     GolapNodeMaxEvaluator new.
				                     GolapNodeSumEvaluator new.
				                     GolapNodeAverageEvaluator new.
				                     GolapNodeNumEdgesEvaluator new };
		                     display: [ :item | item name ];
		                     startWithSelection;
		                     whenSelectedItemChangedDo: [ :nodeEvaluator |
			                     self nodeEvaluator: nodeEvaluator ];
		                     yourself.
	self whenBuiltDo: [ :w |
			| f |
			f := TextStyle defaultFont.
			w widget allMorphsDo: [ :m |
				(m respondsTo: #font:) ifTrue: [ m font: f ] ] ]
]

{ #category : 'initialization' }
GolapEdgesAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Edges'
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluator [

	^ nodeEvaluatorList selectedItem
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluator: aGolapNodeEvaluator [

	aGolapNodeEvaluator ifNotNil: [
		golap model ifNotNil: [ :model |
			self updateGlobalImageAfter: [
				model nodeEvaluator: aGolapNodeEvaluator.
				golap updateQuery.
				golap announceGolapModelUpdated ] ] ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluators [

	^ nodeEvaluatorList items
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluators: aCollectionOfGolapNodeEvaluator [

	nodeEvaluatorList items: aCollectionOfGolapNodeEvaluator
]

{ #category : 'snapshot' }
GolapEdgesAppearance >> restore: aStream [

	(NeoJSONReader on: aStream) next ifNotNil: [ :json |
			json
				at: 'edge-evaluator'
				ifPresent: [ :dict |
					self edgeEvaluator: (GolapEdgeEvaluator fromJSON: dict) ];
				at: 'node-evaluator'
				ifPresent: [ :dict |
					self nodeEvaluator: (GolapNodeEvaluator fromJSON: dict) ] ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> selectEdgeEvaluator: aGolapEdgeEvaluator [

	edgeEvaluatorList selectItem: aGolapEdgeEvaluator
]

{ #category : 'accessing' }
GolapEdgesAppearance >> selectNodeEvaluator: aGolapNodeEvaluator [

	nodeEvaluatorList selectItem: aGolapNodeEvaluator
]

{ #category : 'updating' }
GolapEdgesAppearance >> selectedEdgeEvaluatorChanged [

	edgeEvaluatorList selectedItem ifNotNil: [ :edgeEvaluator |
		self edgeEvaluator: edgeEvaluator ]
]

{ #category : 'updating' }
GolapEdgesAppearance >> selectedNodeEvaluatorChanged [

	nodeEvaluatorList selectedItem ifNotNil: [ :nodeEvaluator |
		self nodeEvaluator: nodeEvaluator ]
]

{ #category : 'private' }
GolapEdgesAppearance >> setGolap: aGolap [
	golap := aGolap.

]

{ #category : 'operations' }
GolapEdgesAppearance >> setModelToAverageMode [

	golap model ifNotNil: [ :model |
		model nodeEvaluator: (GolapNodeAverageEvaluator on: model) ].
	golap dimensionsDo: [ :m |
		m nodeEvaluator: (GolapNodeAverageEvaluator on: m) ]
]

{ #category : 'operations' }
GolapEdgesAppearance >> setModelToDegreeMode [

	golap model ifNotNil: [ :model |
		model nodeEvaluator: (GolapNodeNumEdgesEvaluator on: model) ].
	golap dimensionsDo: [ :m |
		m nodeEvaluator: (GolapNodeNumEdgesEvaluator on: m) ]
]

{ #category : 'operations' }
GolapEdgesAppearance >> setModelToFreqMode [

	golap model ifNotNil: [ :model |
		model nodeEvaluator: (GolapNodeColumnEvaluator on: model column: 'frequency') ].
	golap dimensionsDo: [ :m |
		m nodeEvaluator: (GolapNodeColumnEvaluator on: m column: 'frequency') ]
]

{ #category : 'operations' }
GolapEdgesAppearance >> setModelToMaxMode [

	golap model ifNotNil: [ :model |
		model nodeEvaluator: (GolapNodeMaxEvaluator on: model) ].
	golap dimensionsDo: [ :m |
		m nodeEvaluator: (GolapNodeMaxEvaluator on: m) ]
]

{ #category : 'operations' }
GolapEdgesAppearance >> setModelToSumMode [

	golap model ifNotNil: [ :model |
		model nodeEvaluator: (GolapNodeSumEvaluator on: model) ].
	golap dimensionsDo: [ :m |
		m nodeEvaluator: (GolapNodeSumEvaluator on: m) ]
]

{ #category : 'snapshot' }
GolapEdgesAppearance >> snapshot [

	golap snapshotEdgesAppearance: [ :stream | self snapshotInto: stream ]
]

{ #category : 'snapshot' }
GolapEdgesAppearance >> snapshotInto: aStream [

	| json |
	json := OrderedDictionary new.
	edgeEvaluatorList selectedItem ifNotNil: [ :edgeEvaluator |
		json at: 'edge-evaluator' put: edgeEvaluator asJSON ].
	nodeEvaluatorList selectedItem ifNotNil: [ :nodeEvaluator |
		json at: 'node-evaluator' put: nodeEvaluator asJSON ].
	(NeoJSONWriter on: aStream) nextPut: json
]

{ #category : 'drawing' }
GolapEdgesAppearance >> updateGlobalImageAfter: aBlock [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock ]
]

{ #category : 'drawing' }
GolapEdgesAppearance >> updateGlobalImageAfter: aBlock layout: aBoolean [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock layout: aBoolean ]
]

{ #category : 'private' }
GolapEdgesAppearance >> updateModel: aGolapModel [

	
]
