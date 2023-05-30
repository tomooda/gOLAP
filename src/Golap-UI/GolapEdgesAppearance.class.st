Class {
	#name : #GolapEdgesAppearance,
	#superclass : #SpPresenter,
	#instVars : [
		'edgeWidthSlider',
		'edgeScale',
		'visibleEdgeMinPercentile',
		'visibleEdgeMaxPercentile',
		'golap',
		'minimalSpanningTreeButton',
		'fullGraphButton',
		'friendsField',
		'frequencyButton',
		'liftButton',
		'jaccardButton',
		'pmiButton',
		'maxButton',
		'sumButton',
		'averageButton',
		'degreeButton',
		'positivePolishField',
		'positivePolishSlider',
		'negativePolishField',
		'negativePolishSlider',
		'polishMinDenominatorField',
		'polishIterationCheckbox'
	],
	#classVars : [
		'NamedColors'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #colors }
GolapEdgesAppearance class >> colorAt: aSymbol [
	^ self colorMap at: aSymbol ifAbsent: [ nil ]
]

{ #category : #accessing }
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

{ #category : #colors }
GolapEdgesAppearance class >> colorNames [
	^ self colorMap keys
]

{ #category : #layout }
GolapEdgesAppearance class >> defaultLayout [
	<spec>
	^ SpBoxLayout newVertical
		add: #edgeWidthSlider height: self buttonHeight;
		add: #visibleEdgeMinPercentile height: self buttonHeight * 3 // 4;
		add: #visibleEdgeMaxPercentile height: self buttonHeight * 3 // 4;
		add:
			(SpBoxLayout newHorizontal
				add: #polishIterationCheckbox;
				add: #polishMinDenominatorField)
			height: self buttonHeight;
		add:
			(SpBoxLayout newHorizontal
				add:
					(SpBoxLayout newVertical
						add: #negativePolishSlider
						height: self buttonHeight * 3 // 4);
				add: #negativePolishField width: 50)
			height: self buttonHeight;
		add:
			(SpBoxLayout newHorizontal
				add:
					(SpBoxLayout newVertical
						add: #positivePolishSlider
						height: self buttonHeight * 3 // 4);
				add: #positivePolishField width: 50)
			height: self buttonHeight;
		add:
			(SpBoxLayout newHorizontal
				add: #fullGraphButton;
				add: #minimalSpanningTreeButton;
				add: #friendsField)
			height: self buttonHeight;
		add:
			(SpBoxLayout newHorizontal
				add: #frequencyButton;
				add: #jaccardButton;
				add: #liftButton;
				add: #pmiButton)
			height: self buttonHeight;
		add:
			(SpBoxLayout newHorizontal
				add: #maxButton;
				add: #sumButton;
				add: #averageButton;
				add: #degreeButton)
			height: self buttonHeight;
		yourself
]

{ #category : #'instance creation' }
GolapEdgesAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : #operations }
GolapEdgesAppearance >> averageMode [

	golap model ifNotNil: [ 
		self updateGlobalImageAfter: [ 
			self setModelToAverageMode.
			maxButton state: false.
			sumButton state: false.
			averageButton state: true.
			degreeButton state: false.
			golap updateQuery ] ]
]

{ #category : #operations }
GolapEdgesAppearance >> degreeMode [

	golap model ifNotNil: [ 
		self updateGlobalImageAfter: [ 
			self setModelToDegreeMode.
			maxButton state: false.
			sumButton state: false.
			averageButton state: false.
			degreeButton state: true.
			golap updateQuery ] ]
]

{ #category : #accessing }
GolapEdgesAppearance >> edgeScale [
	^ edgeScale ifNil: [ edgeScale := 1.0 ]
]

{ #category : #accessing }
GolapEdgesAppearance >> edgeScale: aNumber [

	self updateGlobalImageAfter: [ edgeScale := aNumber ]
]

{ #category : #operations }
GolapEdgesAppearance >> freqMode [

	golap model ifNotNil: [ 
		self updateGlobalImageAfter: [ 
			self setModelToFreqMode.
			maxButton state: false.
			sumButton state: false.
			averageButton state: false.
			degreeButton state: false.
			golap updateQuery ] ]
]

{ #category : #operations }
GolapEdgesAppearance >> frequencyMode [

	golap model ifNotNil: [ :model | 
		self updateGlobalImageAfter: [ 
			self setModelToFrequencyMode.
			frequencyButton state: true.
			jaccardButton state: false.
			liftButton state: false.
			pmiButton state: false.
			model friendsEdges: nil.
			self resetVisibleEdgeThresholds.
			golap updateQuery ] ]
]

{ #category : #accessing }
GolapEdgesAppearance >> friendsEdges [
	^ golap model
		ifNotNil: [ :model | model friendsEdges: self numFriends ]
		ifNil: [ Array new ]
]

{ #category : #operations }
GolapEdgesAppearance >> friendsGraph [

	self updateGlobalImageAfter: [
		fullGraphButton state: false.
		minimalSpanningTreeButton state: false ]
]

{ #category : #operations }
GolapEdgesAppearance >> fullGraph [

	self updateGlobalImageAfter: [
		fullGraphButton state: true.
		minimalSpanningTreeButton state: false.
		golap model ifNotNil: [ :model | model setFullGraphMode ] ]
]

{ #category : #accessing }
GolapEdgesAppearance >> graphEdges [
	^ golap model ifNotNil: #graphEdges ifNil: [ Array new ]
]

{ #category : #accessing }
GolapEdgesAppearance >> iconExtent [
	^ 30 @ 14
]

{ #category : #accessing }
GolapEdgesAppearance >> iconFor: aSymbol [
	^ self
		iconForColor:
			(golap
				ifNotNil: [ aSymbol isSymbol
						ifTrue: [ golap perform: aSymbol ]
						ifFalse: [ golap vertexColorWithPattern: aSymbol ] ])
]

{ #category : #accessing }
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

{ #category : #initialization }
GolapEdgesAppearance >> initialExtent [
	^ 500@280
]

{ #category : #initialization }
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
		                        min: 0.8;
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
	minimalSpanningTreeButton := self newButton.
	minimalSpanningTreeButton
		state: false;
		label: 'minimum spanning tree';
		action: [ self minimalSpanningTree ].
	fullGraphButton := self newButton.
	fullGraphButton
		state: false;
		label: 'full graph';
		action: [ self fullGraph ].
	friendsField := self newNumberInput
		                beInteger;
		                placeholder: 'friend rank';
		                minimum: 1;
		                number: 5;
		                autoAccept: true;
		                whenSubmitDo: [ :txt | 
			                self updateGlobalImageAfter: [ self friendsGraph ] ].
	frequencyButton := self newButton
		                   state: false;
		                   label: 'freq';
		                   action: [ self frequencyMode ];
		                   yourself.
	liftButton := self newButton
		              state: false;
		              label: 'lift';
		              action: [ self liftMode ];
		              yourself.
	jaccardButton := self newButton
		                 state: true;
		                 label: 'jaccard';
		                 action: [ self jaccardMode ];
		                 yourself.
	pmiButton := self newButton
		             state: false;
		             label: 'PMI';
		             action: [ self pmiMode ];
		             yourself.
	maxButton := self newButton
		             state: false;
		             label: 'max';
		             action: [ self toggleMaxMode ];
		             yourself.
	sumButton := self newButton
		             state: false;
		             label: 'sum';
		             action: [ self toggleSumMode ];
		             yourself.
	averageButton := self newButton
		                 state: false;
		                 label: 'average';
		                 action: [ self toggleAverageMode ];
		                 yourself.
	degreeButton := self newButton
		                state: false;
		                label: 'degree';
		                action: [ self toggleDegreeMode ];
		                yourself.
	self whenBuiltDo: [ :w | 
		| f |
		f := TextStyle defaultFont.
		w widget allMorphsDo: [ :m | 
			(m respondsTo: #font:) ifTrue: [ m font: f ] ] ]
]

{ #category : #initialization }
GolapEdgesAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Edges'
]

{ #category : #operations }
GolapEdgesAppearance >> jaccardMode [

	golap model ifNotNil: [ :model |
		self updateGlobalImageAfter: [
			self setModelToJaccardMode.
			frequencyButton state: false.
			jaccardButton state: true.
			liftButton state: false.
			pmiButton state: false.
			model friendsEdges: nil.
			self resetVisibleEdgeThresholds.
			golap updateQuery ] ]
]

{ #category : #operations }
GolapEdgesAppearance >> liftMode [

	golap model ifNotNil: [ :model |
		self updateGlobalImageAfter: [
			self setModelToLiftMode.
			frequencyButton state: false.
			jaccardButton state: false.
			liftButton state: true.
			pmiButton state: false.
			model friendsEdges: nil.
			self resetVisibleEdgeThresholds.
			golap updateQuery ] ]
]

{ #category : #operations }
GolapEdgesAppearance >> maxMode [

	golap model ifNotNil: [ :model | 
		self updateGlobalImageAfter: [ 
			self setModelToMaxMode.
			maxButton state: true.
			sumButton state: false.
			averageButton state: false.
			degreeButton state: false.
			golap updateQuery ] ]
]

{ #category : #operations }
GolapEdgesAppearance >> minimalSpanningTree [

	self updateGlobalImageAfter: [
		fullGraphButton state: false.
		minimalSpanningTreeButton state: true.
		golap model ifNotNil: [ :model | model setTreeMode ] ]
]

{ #category : #accessing }
GolapEdgesAppearance >> negativePolishFactor [
	^ negativePolishField text asString asNumber ifNil: [ 0.0 ]
]

{ #category : #accessing }
GolapEdgesAppearance >> numFriends [

	^ friendsField number
]

{ #category : #accessing }
GolapEdgesAppearance >> numFriends: anInteger [

	friendsField number: anInteger
]

{ #category : #operations }
GolapEdgesAppearance >> pmiMode [

	golap model ifNotNil: [ :model |
		self updateGlobalImageAfter: [
			self setModelToPmiMode.
			frequencyButton state: false.
			jaccardButton state: false.
			liftButton state: false.
			pmiButton state: true.
			model friendsEdges: nil.
			self resetVisibleEdgeThresholds.
			golap updateQuery ] ]
]

{ #category : #operations }
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

{ #category : #accessing }
GolapEdgesAppearance >> positivePolishFactor [
	^ positivePolishField text asString asNumber ifNil: [ 1.0 ]
]

{ #category : #accessing }
GolapEdgesAppearance >> positivePolishFactor: aNumber [
	positivePolishField text: aNumber asString
]

{ #category : #private }
GolapEdgesAppearance >> resetVisibleEdgeThresholds [
	visibleEdgeMinPercentile value: 0.0.
	visibleEdgeMaxPercentile value: 1.0
]

{ #category : #snapshot }
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
			at: 'tree' ifPresent: [ :string | 
				string = 'tree' ifTrue: [ self minimalSpanningTree ].
				string = 'graph' ifTrue: [ self fullGraph ].
				string isNumber ifTrue: [ 
						friendsField number: string.
						self friendsGraph ] ];
			at: 'measure' ifPresent: [ :string | 
				string = 'freq' ifTrue: [ self frequencyMode ].
				string = 'lift' ifTrue: [ self liftMode ].
				string = 'jaccard' ifTrue: [ self jaccardMode ].
				string = 'pmi' ifTrue: [ self pmiMode ] ];
			at: 'aggregation' ifPresent: [ :string | 
				string = 'freq' ifTrue: [ self freqMode ].
				string = 'max' ifTrue: [ self maxMode ].
				string = 'sum' ifTrue: [ self sumMode ].
				string = 'average' ifTrue: [ self averageMode ].
				string = 'degree' ifTrue: [ self degreeMode ] ] ]
]

{ #category : #private }
GolapEdgesAppearance >> setGolap: aGolap [
	golap := aGolap.

]

{ #category : #operations }
GolapEdgesAppearance >> setModelToAverageMode [
	golap model ifNotNil: [ :model | model aggregation: #average ].
	golap dimensionsDo: [ :m | m aggregation: #average ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToDegreeMode [
	golap model ifNotNil: [ :model | model aggregation: #degree ].
	golap dimensionsDo: [ :m | m aggregation: #degree ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToFreqMode [
	golap model ifNotNil: [ :model | model aggregation: #frequency ].
	golap dimensionsDo: [ :m | m aggregation: #frequency ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToFrequencyMode [
	golap model ifNotNil: [ :model | model frequencyMode ].
	golap dimensionsDo: [ :m | m frequencyMode ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToJaccardMode [
	golap model ifNotNil: [ :model | model jaccardMode ].
	golap dimensionsDo: [ :m | m jaccardMode ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToLiftMode [
	golap model ifNotNil: [ :model | model liftMode ].
	golap dimensionsDo: [ :m | m liftMode ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToMaxMode [
	golap model ifNotNil: [ :model | model aggregation: #max ].
	golap dimensionsDo: [ :m | m aggregation: #max ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToPmiMode [
	golap model ifNotNil: [ :model | model pmiMode ].
	golap dimensionsDo: [ :m | m pmiMode ]
]

{ #category : #operations }
GolapEdgesAppearance >> setModelToSumMode [
	golap model ifNotNil: [ :model | model aggregation: #sum ].
	golap dimensionsDo: [ :m | m aggregation: #sum ]
]

{ #category : #snapshot }
GolapEdgesAppearance >> snapshot [

	golap snapshotEdgesAppearance: [ :stream | self snapshotInto: stream ]
]

{ #category : #snapshot }
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
		at: 'tree' put: (minimalSpanningTreeButton state
				 ifTrue: [ 'tree' ]
				 ifFalse: [ 
					 fullGraphButton state
						 ifTrue: [ 'graph' ]
						 ifFalse: [ friendsField number ] ]).
	frequencyButton state ifTrue: [ json at: 'measure' put: 'freq' ].
	liftButton state ifTrue: [ json at: 'measure' put: 'lift' ].
	jaccardButton state ifTrue: [ json at: 'measure' put: 'jaccard' ].
	pmiButton state ifTrue: [ json at: 'measure' put: 'pmi' ].
	json at: 'aggregation' put: 'freq'.
	maxButton state ifTrue: [ json at: 'aggregation' put: 'max' ].
	sumButton state ifTrue: [ json at: 'aggregation' put: 'sum' ].
	averageButton state ifTrue: [ json at: 'aggregation' put: 'average' ].
	degreeButton state ifTrue: [ json at: 'aggregation' put: 'degree' ].
	(NeoJSONWriter on: aStream) nextPut: json
]

{ #category : #operations }
GolapEdgesAppearance >> sumMode [

	golap model ifNotNil: [ :model | 
		self updateGlobalImageAfter: [ 
			model aggregation: #sum.
			maxButton state: false.
			sumButton state: true.
			averageButton state: false.
			degreeButton state: false.
			golap updateQuery ] ]
]

{ #category : #operations }
GolapEdgesAppearance >> toggleAverageMode [
	averageButton state
		ifTrue: [ self freqMode ]
		ifFalse: [ self averageMode ]
]

{ #category : #operations }
GolapEdgesAppearance >> toggleDegreeMode [
	degreeButton state
		ifTrue: [ self freqMode ]
		ifFalse: [ self degreeMode ]
]

{ #category : #operations }
GolapEdgesAppearance >> toggleMaxMode [
	maxButton state
		ifTrue: [ self freqMode ]
		ifFalse: [ self maxMode ]
]

{ #category : #operations }
GolapEdgesAppearance >> toggleSumMode [
	sumButton state
		ifTrue: [ self freqMode ]
		ifFalse: [ self sumMode ]
]

{ #category : #accessing }
GolapEdgesAppearance >> treeEdges [
	^ golap model ifNotNil: #treeEdges ifNil: [ Array new ]
]

{ #category : #drawing }
GolapEdgesAppearance >> updateGlobalImageAfter: aBlock [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock ]
]

{ #category : #drawing }
GolapEdgesAppearance >> updateGlobalImageAfter: aBlock layout: aBoolean [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock layout: aBoolean ]
]

{ #category : #private }
GolapEdgesAppearance >> updateModel: aGolapModel [
	frequencyButton state
		ifTrue: [ self frequencyMode ].
	jaccardButton state
		ifTrue: [ self jaccardMode ].
	liftButton state
		ifTrue: [self liftMode].
	pmiButton state
		ifTrue: [self pmiMode].
	aGolapModel aggregation: #frequency.
	maxButton state
		ifTrue: [self maxMode].
	sumButton state
		ifTrue: [self sumMode].
	averageButton state
		ifTrue: [self averageMode].
	degreeButton state
		ifTrue: [self degreeMode]
]

{ #category : #accessing }
GolapEdgesAppearance >> visibleEdgeMaxPercentile [
	^ visibleEdgeMaxPercentile
]

{ #category : #accessing }
GolapEdgesAppearance >> visibleEdgeMinPercentile [
	^ visibleEdgeMinPercentile
]

{ #category : #accessing }
GolapEdgesAppearance >> visibleEdges [
	fullGraphButton state = true
		ifTrue: [ ^ self graphEdges ].
	minimalSpanningTreeButton state = true
		ifTrue: [ ^ self treeEdges ].
	^ self friendsEdges
]
