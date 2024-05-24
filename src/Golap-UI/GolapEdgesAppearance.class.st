Class {
	#name : 'GolapEdgesAppearance',
	#superclass : 'SpPresenter',
	#instVars : [
		'edgeWidthSlider',
		'edgeScale',
		'visibleEdgeMinPercentile',
		'visibleEdgeMaxPercentile',
		'golap',
		'friendsField',
		'positivePolishField',
		'positivePolishSlider',
		'negativePolishField',
		'negativePolishSlider',
		'polishMinDenominatorField',
		'polishIterationCheckbox',
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

{ #category : 'layout' }
GolapEdgesAppearance class >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
		  add: #edgeWidthSlider height: self buttonHeight;
		  add: #visibleEdgeMinPercentile height: self buttonHeight * 3 // 4;
		  add: #visibleEdgeMaxPercentile height: self buttonHeight * 3 // 4;
		  add: (SpBoxLayout newHorizontal
				   add: #polishIterationCheckbox;
				   add: #polishMinDenominatorField)
		  height: self buttonHeight;
		  add: (SpBoxLayout newHorizontal
				   add: (SpBoxLayout newVertical
						    add: #negativePolishSlider
						    height: self buttonHeight * 3 // 4);
				   add: #negativePolishField width: 50)
		  height: self buttonHeight;
		  add: (SpBoxLayout newHorizontal
				   add: (SpBoxLayout newVertical
						    add: #positivePolishSlider
						    height: self buttonHeight * 3 // 4);
				   add: #positivePolishField width: 50)
		  height: self buttonHeight;
		  add: (SpBoxLayout newHorizontal
				   add: 'フレンドランク' asPresenter expand: true;
				   add: #friendsField width: 150)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: '関連指標' asPresenter expand: true;
				   add: #edgeEvaluatorList width: 150)
		  height: self buttonHeight;
		  add: (SpBoxLayout newHorizontal
				   add: '商品指標' asPresenter expand: true;
				   add: #nodeEvaluatorList width: 150)
		  height: self buttonHeight;
		  yourself
]

{ #category : 'instance creation' }
GolapEdgesAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluator: aGolapEdgeEvaluator [

	aGolapEdgeEvaluator ifNotNil: [
		golap model ifNotNil: [ :model |
			self updateGlobalImageAfter: [
				model edgeEvaluator: aGolapEdgeEvaluator.
				model friendsEdges: nil.
				self resetVisibleEdgeThresholds.
				golap updateQuery.
				nodeEvaluatorList withAdapterDo: [ :a |
					a widgetDo: [ :w | w updateContents ] ] ] ] ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeEvaluators: aCollectionOfGolapEdgeEvaluator [

	edgeEvaluatorList items: aCollectionOfGolapEdgeEvaluator
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeScale [
	^ edgeScale ifNil: [ edgeScale := 1.0 ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> edgeScale: aNumber [

	self updateGlobalImageAfter: [ edgeScale := aNumber ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> friendsEdges [
	^ golap model
		ifNotNil: [ :model | model friendsEdges: self numFriends ]
		ifNil: [ Array new ]
]

{ #category : 'operations' }
GolapEdgesAppearance >> friendsGraph [

	self updateGlobalImageAfter: [  ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> graphEdges [
	^ golap model ifNotNil: #graphEdges ifNil: [ Array new ]
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

	edgeWidthSlider := self newSlider
		                   label: 'edge width';
		                   quantum: 0.1;
		                   min: 0.0;
		                   max: 2.0;
		                   value: 1.0;
		                   whenValueChangedDo: [ :value |
			                   self edgeScale: 2.0 ** value - 1.0 * 3.0 ];
		                   yourself.
	visibleEdgeMinPercentile := self newSlider
		                            label: 'min';
		                            min: 0.0;
		                            max: 1.0;
		                            value: 0.0;
		                            quantum: 0.05;
		                            whenValueChangedDo: [
			                            self updateGlobalImageAfter: [  ] ];
		                            borderWidth: 0;
		                            yourself.
	visibleEdgeMaxPercentile := self newSlider
		                            label: 'max';
		                            min: 0.0;
		                            max: 1.0;
		                            value: 1.0;
		                            quantum: 0.05;
		                            whenValueChangedDo: [
			                            self updateGlobalImageAfter: [  ] ];
		                            borderWidth: 0;
		                            yourself.
	polishIterationCheckbox := self newCheckBox
		                           label: '繰り返し';
		                           state: false;
		                           whenChangedDo: [ self polish ];
		                           yourself.
	positivePolishSlider := self newSlider
		                        label: '+研磨';
		                        min: 0.0;
		                        max: 1.0;
		                        value: 1.0;
		                        quantum: 0.01;
		                        whenValueChangedDo: [
			                        positivePolishField number:
					                        positivePolishSlider value.
			                        self polish ];
		                        borderWidth: 0;
		                        yourself.
	positivePolishField := self newNumberInput
		                       beFloat;
		                       placeholder: '+研磨';
		                       minimum: 0.8;
		                       maximum: 1.0;
		                       number: 1.0;
		                       whenSubmitDo: [ :txt |
			                       positivePolishSlider value:
					                       positivePolishField number.
			                       self polish ].
	negativePolishSlider := self newSlider
		                        label: '-研磨';
		                        min: 0.0;
		                        max: 0.2;
		                        value: 0.0;
		                        quantum: 0.01;
		                        whenValueChangedDo: [
			                        negativePolishField number:
					                        negativePolishSlider value.
			                        self polish ];
		                        borderWidth: 0;
		                        yourself.
	negativePolishField := self newNumberInput
		                       beFloat;
		                       placeholder: '-研磨';
		                       minimum: 0.0;
		                       maximum: 0.2;
		                       number: 0.0;
		                       whenSubmitDo: [ :txt |
			                       negativePolishSlider value:
					                       negativePolishField number.
			                       self polish ].
	polishMinDenominatorField := self newNumberInput
		                             beInteger;
		                             placeholder: 'min edges';
		                             minimum: 1;
		                             number: 3;
		                             whenSubmitDo: [ :txt | self polish ].
	friendsField := self newNumberInput
		                beInteger;
		                placeholder: 'friend rank';
		                minimum: 1;
		                number: 5;
		                autoAccept: true;
		                whenSubmitDo: [ :txt | self friendsGraph ].
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
				                       (GolapNodeColumnEvaluator column:
						                        'frequency').
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
GolapEdgesAppearance >> negativePolishFactor [
	^ negativePolishField text asString asNumber ifNil: [ 0.0 ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluator: aGolapNodeEvaluator [

	aGolapNodeEvaluator ifNotNil: [
		golap model ifNotNil: [ :model |
			self updateGlobalImageAfter: [
				model nodeEvaluator: aGolapNodeEvaluator.
				golap updateQuery ] ] ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> nodeEvaluators: aCollectionOfGolapNodeEvaluator [

	nodeEvaluatorList items: aCollectionOfGolapNodeEvaluator
]

{ #category : 'accessing' }
GolapEdgesAppearance >> numFriends [

	^ friendsField number
]

{ #category : 'accessing' }
GolapEdgesAppearance >> numFriends: anInteger [

	friendsField number: anInteger
]

{ #category : 'operations' }
GolapEdgesAppearance >> polish [
	self
		updateGlobalImageAfter: [ golap model
				repeat:
					(polishIterationCheckbox state
						ifTrue: [ 100 ]
						ifFalse: [ 1 ])
				polishAddAbove: self positivePolishFactor
				removeBelow: self negativePolishFactor
				minDenominator: polishMinDenominatorField text asString asInteger ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> positivePolishFactor [
	^ positivePolishField text asString asNumber ifNil: [ 1.0 ]
]

{ #category : 'accessing' }
GolapEdgesAppearance >> positivePolishFactor: aNumber [
	positivePolishField text: aNumber asString
]

{ #category : 'private' }
GolapEdgesAppearance >> resetVisibleEdgeThresholds [
	visibleEdgeMinPercentile value: 0.0.
	visibleEdgeMaxPercentile value: 1.0
]

{ #category : 'snapshot' }
GolapEdgesAppearance >> restore: aStream [

	(NeoJSONReader on: aStream) next ifNotNil: [ :json |
		json
			at: 'edge-width'
			ifPresent: [ :float | edgeWidthSlider value: float ];
			at: 'visible-edge-min'
			ifPresent: [ :float | visibleEdgeMinPercentile value: float ];
			at: 'visible-edige-max'
			ifPresent: [ :float | visibleEdgeMaxPercentile value: float ];
			at: 'polish-iteration'
			ifPresent: [ :bool | polishIterationCheckbox state: bool ];
			at: 'polish-positive'
			ifPresent: [ :float | positivePolishField number: float ];
			at: 'polish-negative'
			ifPresent: [ :float | negativePolishField number: float ];
			at: 'polish-min-edges'
			ifPresent: [ :int | polishMinDenominatorField number: int ];
			at: 'rank' ifPresent: [ :number |
				number isNumber ifTrue: [
						friendsField number: number.
						self friendsGraph ] ];
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
	json
		at: 'edge-width' put: edgeWidthSlider value;
		at: 'visible-edge-min' put: visibleEdgeMinPercentile value;
		at: 'visible-edge-max' put: visibleEdgeMaxPercentile value;
		at: 'polish-iteration' put: polishIterationCheckbox state;
		at: 'polish-positive' put: positivePolishField number;
		at: 'polish-negative' put: negativePolishField number;
		at: 'polish-min-edges' put: polishMinDenominatorField number;
		at: 'rank' put: friendsField number.
	edgeEvaluatorList selectedItem ifNotNil: [ :edgeEvaluator |
		json at: 'edge-evaluator' put: edgeEvaluator asJSON ].
	nodeEvaluatorList selectedItem ifNotNil: [ :nodeEvaluator |
		json at: 'node-evaluator' put: nodeEvaluator asJSON ].
	(NeoJSONWriter on: aStream) nextPut: json
]

{ #category : 'accessing' }
GolapEdgesAppearance >> treeEdges [
	^ golap model ifNotNil: #treeEdges ifNil: [ Array new ]
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

{ #category : 'accessing' }
GolapEdgesAppearance >> visibleEdgeMaxPercentile [
	^ visibleEdgeMaxPercentile
]

{ #category : 'accessing' }
GolapEdgesAppearance >> visibleEdgeMinPercentile [
	^ visibleEdgeMinPercentile
]

{ #category : 'accessing' }
GolapEdgesAppearance >> visibleEdges [

	^ self friendsEdges
]
