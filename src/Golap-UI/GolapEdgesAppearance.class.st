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

{ #category : 'updating' }
GolapEdgesAppearance >> golapChanged [

	self updateEvaluators
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
		                     addColumn: ((SpStringTableColumn title: '指標' evaluated: [ :item | item name ]) width: 100);
		                     addColumn:
			                     (SpStringTableColumn title: '最小' evaluated: [ :item | item min ifNotNil: #asString ifNil: [ '' ] ]);
		                     addColumn:
			                     ((SpStringTableColumn
				                       title: '下限'
				                       evaluated: [ :item | item lowerThreshold ifNotNil: #asString ifNil: [ '' ] ])
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
		                     addColumn:
			                     ((SpStringTableColumn
				                       title: '上限'
				                       evaluated: [ :item | item upperThreshold ifNotNil: #asString ifNil: [ '' ] ])
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
		                     addColumn:
		                     (SpStringTableColumn title: '最大' evaluated: [ :item | item max ifNotNil: #asString ifNil: [ '' ] ]);
		                     items: #();
		                     whenSelectedItemChangedDo: [ self selectedEdgeEvaluatorChanged ];
		                     yourself.
	nodeEvaluatorList := self newTable
		                     addColumn: ((SpStringTableColumn title: '指標' evaluated: [ :item | item name ]) width: 100);
		                     addColumn:
			                     (SpStringTableColumn title: '最小' evaluated: [ :item | item min ifNotNil: #asString ifNil: [ '' ] ]);
		                     addColumn:
			                     ((SpStringTableColumn
				                       title: '下限'
				                       evaluated: [ :item | item lowerThreshold ifNotNil: #asString ifNil: [ '' ] ])
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
		                     addColumn:
			                     ((SpStringTableColumn
				                       title: '上限'
				                       evaluated: [ :item | item upperThreshold ifNotNil: #asString ifNil: [ '' ] ])
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
		                     addColumn:
		                     (SpStringTableColumn title: '最大' evaluated: [ :item | item max ifNotNil: #asString ifNil: [ '' ] ]);
		                     items: #();
		                     whenSelectedItemChangedDo: [ :nodeEvaluator | self selectedNodeEvaluatorChanged ];
		                     yourself.
	friendNumberField := self newNumberInput
		                     beInteger;
		                     climbRate: 1;
		                     minimum: 1;
		                     whenSubmitDo: [ :txt | self friendNumberFieldChanged ];
		                     whenNumberChangedDo: [ :num | self friendNumberFieldChanged ];
		                     disable;
		                     yourself.
	self whenBuiltDo: [ :w |
			| f |
			f := TextStyle defaultFont.
			w widget allMorphsDo: [ :m | (m respondsTo: #font:) ifTrue: [ m font: f ] ] ]
]

{ #category : 'initialization' }
GolapEdgesAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Edges'
]

{ #category : 'updating' }
GolapEdgesAppearance >> refreshEvaluatorList [

	edgeEvaluatorList refresh.
	nodeEvaluatorList refresh
]

{ #category : 'accessing' }
GolapEdgesAppearance >> selectNodeEvaluator: aGolapNodeEvaluator [

	nodeEvaluatorList selectItem: aGolapNodeEvaluator
]

{ #category : 'updating' }
GolapEdgesAppearance >> selectedEdgeEvaluatorChanged [

	edgeEvaluatorList selectedItem ifNotNil: [ :edgeEvaluator | golap ifNotNil: [ golap edgeEvaluator: edgeEvaluator ] ]
]

{ #category : 'updating' }
GolapEdgesAppearance >> selectedNodeEvaluatorChanged [

	nodeEvaluatorList selectedItem ifNotNil: [ :nodeEvaluator | golap ifNotNil: [ golap nodeEvaluator: nodeEvaluator ] ]
]

{ #category : 'private' }
GolapEdgesAppearance >> setGolap: aGolap [
	golap := aGolap.
	self golapChanged
]

{ #category : 'updating' }
GolapEdgesAppearance >> updateEdgeEvaluators [

	self golapModelDo: [ :golapModel |
			golapModel edgeEvaluators ifNotNil: [ :evaluators |
				edgeEvaluatorList items ~= evaluators ifTrue: [ edgeEvaluatorList items: golapModel edgeEvaluators ] ].
			golapModel edgeEvaluator ifNotNil: [ :evaluator |
				edgeEvaluatorList selectedItem ~= evaluator ifTrue: [ edgeEvaluatorList selectItem: golapModel edgeEvaluator ] ] ]
]

{ #category : 'updating' }
GolapEdgesAppearance >> updateEvaluators [

	self
		updateEdgeEvaluators;
		updateNodeEvaluators
]

{ #category : 'drawing' }
GolapEdgesAppearance >> updateGlobalImageAfter: aBlock [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock ]
]

{ #category : 'drawing' }
GolapEdgesAppearance >> updateGlobalImageAfter: aBlock layout: aBoolean [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock layout: aBoolean ]
]

{ #category : 'updating' }
GolapEdgesAppearance >> updateNodeEvaluators [

	self golapModelDo: [ :golapModel |
			golapModel nodeEvaluators ifNotNil: [ :evaluators |
				nodeEvaluatorList items ~= evaluators ifTrue: [ nodeEvaluatorList items: golapModel nodeEvaluators ] ].
			golapModel nodeEvaluator ifNotNil: [ :evaluator |
				nodeEvaluatorList selectedItem ~= evaluator ifTrue: [ nodeEvaluatorList selectItem: golapModel nodeEvaluator ] ] ]
]
