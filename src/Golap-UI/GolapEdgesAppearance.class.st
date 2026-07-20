Class {
	#name : 'GolapEdgesAppearance',
	#superclass : 'SpPresenter',
	#instVars : [
		'golap',
		'edgeEvaluatorList',
		'nodeEvaluatorList',
		'friendNumberField'
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
		  add: '関連指標' asPresenter expand: false;
		  add: edgeEvaluatorList expand: true;
		  add: '商品指標' asPresenter expand: false;
		  add: nodeEvaluatorList expand: true;
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   hAlignEnd;
				   add: 'フレンド  ' asPresenter expand: false;
				   add: friendNumberField width: 50)
		  expand: false;
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
							golap updateQuery.
							golap updateModel ] ] ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluators [

	^ edgeEvaluatorList items
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluators: aCollectionOfGolapEdgeEvaluator [

	edgeEvaluatorList items: aCollectionOfGolapEdgeEvaluator.
	self golapModelDo: [ :golapModel |
		golapModel edgeEvaluators: aCollectionOfGolapEdgeEvaluator ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> friend [

	^ friendNumberField number
]

{ #category : 'updating' }
GolapEdgesAppearance >> friendNumberFieldChanged [

	self golapModelDo: [ :golapModel |
			golapModel friend: friendNumberField number.
			golap updateModel ]
]

{ #category : 'operations' }
GolapEdgesAppearance >> friendsGraph [

	self updateGlobalImageAfter: [ golap announceGolapModelUpdated ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> golapModelDo: aBlock [

	(golap ifNotNil: #model) ifNotNil: aBlock
]

{ #category : 'accessing' }
GolapEdgesAppearance >> iconExtent [
	^ 30 @ 14
]

{ #category : 'initialization' }
GolapEdgesAppearance >> initialExtent [
	^ 500@280
]

{ #category : 'initialization' }
GolapEdgesAppearance >> initializePresenters [

	edgeEvaluatorList := self newTable
		                     addColumn:
			                     ((SpStringTableColumn
				                       title: '指標'
				                       evaluated: [ :item | item name ]) width:
					                      100);
		                     addColumn: (SpStringTableColumn
				                      title: '最小'
				                      evaluated: [ :item |
					                      item min ifNotNil: #asString ifNil: [ '' ] ]);
		                     addColumn: ((SpStringTableColumn
				                       title: '下限'
				                       evaluated: [ :item |
					                       item lowerThreshold
						                       ifNotNil: #asString
						                       ifNil: [ '' ] ])
				                      beEditable;
				                      onAcceptEdition: [ :item :text |
						                      | number |
						                      number := [ text asNumber ]
							                                on: Exception
							                                do: [ :ex | nil ].
						                      item lowerThreshold: number.
						                      edgeEvaluatorList refresh.
						                      self golapModelDo: [ :golapModel |
									                      golapModel updateNodesAndEdges.
									                      golap updateModel ] ]);
		                     addColumn: ((SpStringTableColumn
				                       title: '上限'
				                       evaluated: [ :item |
					                       item upperThreshold
						                       ifNotNil: #asString
						                       ifNil: [ '' ] ])
				                      beEditable;
				                      onAcceptEdition: [ :item :text |
						                      | number |
						                      number := [ text asNumber ]
							                                on: Exception
							                                do: [ :ex | nil ].
						                      item upperThreshold: number.
						                      edgeEvaluatorList refresh.
						                      self golapModelDo: [ :golapModel |
									                      golapModel updateNodesAndEdges.
									                      golap updateModel ] ]);
		                     addColumn: (SpStringTableColumn
				                      title: '最大'
				                      evaluated: [ :item |
				                      item max ifNotNil: #asString ifNil: [ '' ] ]);
		                     items:
			                     (#( 'frequency' 'jaccard' 'lift' 'PMI' )
				                      collect: [ :column |
				                      GolapEdgeColumnEvaluator column: column ]);
		                     selectFirst;
		                     whenSelectedItemChangedDo: [ :edgeEvaluator |
		                     self edgeEvaluator: edgeEvaluator ];
		                     yourself.
	nodeEvaluatorList := self newTable
		                     addColumn:
			                     ((SpStringTableColumn
				                       title: '指標'
				                       evaluated: [ :item | item name ]) width:
					                      100);
		                     addColumn: (SpStringTableColumn
				                      title: '最小'
				                      evaluated: [ :item |
					                      item min ifNotNil: #asString ifNil: [ '' ] ]);
		                     addColumn: ((SpStringTableColumn
				                       title: '下限'
				                       evaluated: [ :item |
					                       item lowerThreshold
						                       ifNotNil: #asString
						                       ifNil: [ '' ] ])
				                      beEditable;
				                      onAcceptEdition: [ :item :text |
						                      | number |
						                      number := [ text asNumber ]
							                                on: Exception
							                                do: [ :ex | nil ].
						                      item lowerThreshold: number.
						                      nodeEvaluatorList refresh.
						                      self golapModelDo: [ :golapModel |
									                      golapModel updateNodesAndEdges.
									                      golap updateModel ] ]);
		                     addColumn: ((SpStringTableColumn
				                       title: '上限'
				                       evaluated: [ :item |
					                       item upperThreshold
						                       ifNotNil: #asString
						                       ifNil: [ '' ] ])
				                      beEditable;
				                      onAcceptEdition: [ :item :text |
						                      | number |
						                      number := [ text asNumber ]
							                                on: Exception
							                                do: [ :ex | nil ].
						                      item upperThreshold: number.
						                      nodeEvaluatorList refresh.
						                      self golapModelDo: [ :golapModel |
									                      golapModel updateNodesAndEdges.
									                      golap updateModel ] ]);
		                     addColumn: (SpStringTableColumn
				                      title: '最大'
				                      evaluated: [ :item |
				                      item max ifNotNil: #asString ifNil: [ '' ] ]);
		                     items: {
				                     (GolapNodeColumnEvaluator column: 'frequency').
				                     GolapNodeMaxEvaluator new.
				                     GolapNodeSumEvaluator new.
				                     GolapNodeAverageEvaluator new.
				                     GolapNodeNumEdgesEvaluator new };
		                     selectFirst;
		                     whenSelectedItemChangedDo: [ :nodeEvaluator |
		                     self nodeEvaluator: nodeEvaluator ];
		                     yourself.
	friendNumberField := self newNumberInput
		                     beInteger;
		                     climbRate: 1;
		                     minimum: 1;
		                     whenSubmitDo: [ self friendNumberFieldChanged ];
		                     whenNumberChangedDo: [ :num |
			                     self friendNumberFieldChanged ];
		                     disable;
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
							golap updateModel ] ] ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluators [

	^ nodeEvaluatorList items
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluators: aCollectionOfGolapNodeEvaluator [

	nodeEvaluatorList items: aCollectionOfGolapNodeEvaluator.
	self golapModelDo: [ :golapModel |
		golapModel nodeEvaluators: aCollectionOfGolapNodeEvaluator ]
]

{ #category : 'updating' }
GolapEdgesAppearance >> refreshEvaluatorList [

	edgeEvaluatorList refresh.
	nodeEvaluatorList refresh
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
