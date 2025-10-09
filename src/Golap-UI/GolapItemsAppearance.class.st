Class {
	#name : 'GolapItemsAppearance',
	#superclass : 'SpPresenter',
	#instVars : [
		'minFreqSlider',
		'minFreqField',
		'numLabelsSlider',
		'fontButton',
		'golap',
		'showConnectedNodesCheckBox',
		'showHiddenConnectionNodesCheckBox',
		'showIsolatedNodesCheckBox',
		'photoimageRetrievers'
	],
	#classVars : [
		'NameEndOfLineDelimiter'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'layout' }
GolapItemsAppearance class >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
"		  add: (SpBoxLayout newHorizontal
				   add: #minFreqSlider;
				   add: '  ' expand: false;
				   add: #minFreqField width: 50)
		  height: self inputTextHeight;
		  add: #numLabelsSlider height: self inputTextHeight;
"		  add: #fontButton height: self buttonHeight;
		  add: (SpBoxLayout newHorizontal
				   add: #showConnectedNodesCheckBox;
				   add: #showHiddenConnectionNodesCheckBox;
				   add: #showIsolatedNodesCheckBox)
		  height: self inputTextHeight;
		  add: #photoimageRetrievers;
		  yourself
]

{ #category : 'instance creation' }
GolapItemsAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : 'private' }
GolapItemsAppearance >> chooseFont [

	golap ifNotNil: [
			FontChooser
				openModalWithTitle: 'Font for Golap'
				initialFont: Golap defaultFont
				onAcceptDo: [ :font | Golap defaultFont: font ] ]
]

{ #category : 'initialization' }
GolapItemsAppearance >> initialExtent [
	^ 500@200
]

{ #category : 'initialization' }
GolapItemsAppearance >> initializePresenters [

	minFreqSlider := self newSlider
		                 label: '最小頻度';
		                 min: 0;
		                 max: 100;
		                 quantum: 1;
		                 value: 0;
		                 whenValueChangedDo: [ :value |
			                 self minFrequency: value rounded ];
		                 yourself.
	minFreqField := self newNumberInput
		                beInteger;
		                minimum: 0;
		                maximum: 100;
		                number: 0;
		                whenNumberChangedDo: [ :value |
			                self minFrequency: value ];
		                yourself.

	showIsolatedNodesCheckBox := self newCheckBox
		                             label: '孤立アイテム';
		                             state: false;
		                             whenChangedDo: [ :value |
			                             golap updateGlobalImageAfter: [  ] ];
		                             yourself.
	showHiddenConnectionNodesCheckBox := self newCheckBox
		                                     label: '隠れアイテム';
		                                     state: false;
		                                     whenChangedDo: [ :value |
			                                     golap updateGlobalImageAfter: [
					                                      ] ];
		                                     yourself.
	showConnectedNodesCheckBox := self newCheckBox
		                              label: '接続アイテム';
		                              state: true;
		                              whenChangedDo: [ :value |
			                              golap updateGlobalImageAfter: [  ] ];
		                              yourself.
	numLabelsSlider := self newSlider
		                   label: 'ラベル表示数';
		                   min: 0.0;
		                   max: 2.0;
		                   quantum: 0.1;
		                   value: 1.0;
		                   whenValueChangedDo: [ :value |
			                   golap updateGlobalImageAfter: [
					                   numLabelsSlider label:
							                   (50.0 ** value) truncated printString , ' 個' ] ];
		                   yourself.
	fontButton := self newButton
		              label: 'フォント';
		              action: [ self chooseFont ];
		              yourself.
	photoimageRetrievers := self instantiate:
		                        GolapPhotoImageRetrieversPresenter
]

{ #category : 'initialization' }
GolapItemsAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Items'
]

{ #category : 'accessing' }
GolapItemsAppearance >> minFrequency [

	^ minFreqField number
]

{ #category : 'accessing' }
GolapItemsAppearance >> minFrequency: anInteger [

	minFreqSlider value rounded = anInteger ifFalse: [
		minFreqSlider value: anInteger ].
	minFreqField number = anInteger ifFalse: [
		minFreqField number: anInteger ].
	golap updateGlobalImageAfter: [  ]
]

{ #category : 'accessing' }
GolapItemsAppearance >> numLabels [
	^ numLabelsSlider value
]

{ #category : 'snapshot' }
GolapItemsAppearance >> restore: aStream [

	(NeoJSONReader on: aStream) next
		at: 'minimum-frequency'
		ifPresent: [ :int | minFreqField number: int ];
		at: 'show-isolatex-nodes'
		ifPresent: [ :bool | showIsolatedNodesCheckBox state: bool ];
		at: 'show-hidden-connection-nodes'
		ifPresent: [ :bool | showHiddenConnectionNodesCheckBox state: bool ];
		at: 'show-connected-nodes'
		ifPresent: [ :bool | showConnectedNodesCheckBox state: bool ];
		at: 'max-display-labels'
		ifPresent: [ :float | numLabelsSlider value: float ]
]

{ #category : 'private' }
GolapItemsAppearance >> setGolap: aGolap [

	golap := aGolap.
	photoimageRetrievers golap: aGolap.
	self
		updateMinMaxFrequency;
		updatePhotoimageRetrievers
]

{ #category : 'accessing' }
GolapItemsAppearance >> showsConnectedNodes [
	^ showConnectedNodesCheckBox state
]

{ #category : 'accessing' }
GolapItemsAppearance >> showsHiddenConnectionNodes [
	^ showHiddenConnectionNodesCheckBox state
]

{ #category : 'accessing' }
GolapItemsAppearance >> showsIsolatedNodes [
	^ showIsolatedNodesCheckBox state
]

{ #category : 'snapshot' }
GolapItemsAppearance >> snapshot [

	golap snapshotItemsAppearance: [ :stream | self snapshotInto: stream ]
]

{ #category : 'snapshot' }
GolapItemsAppearance >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: {
			('minimum-frequency' -> minFreqField number).
			('show-isolatex-nodes' -> showIsolatedNodesCheckBox state).
			('show-hidden-connection-nodes'
			 -> showHiddenConnectionNodesCheckBox state).
			('show-connected-nodes' -> showConnectedNodesCheckBox state).
			('max-display-labels' -> numLabelsSlider value) }
			asOrderedDictionary
]

{ #category : 'updating' }
GolapItemsAppearance >> updateMinMaxFrequency [

	| min max |
	min := 0.0.
	max := 1.0.
	golap ifNotNil: [
			golap model ifNotNil: [ :model |
					(golap nodes collect: golap model nodeEvaluator) ifNotEmpty: [
							:freqs |
							min := freqs min rounded.
							max := freqs max rounded ] ] ].
	minFreqSlider
		min: min;
		max: max.
	minFreqField number: (minFreqField number min: max max: min).
	golap updateGlobalImageAfter: [ ]
]

{ #category : 'updating' }
GolapItemsAppearance >> updatePhotoimageRetrievers [

	photoimageRetrievers itemInfoRetriever: golap productInfoRetriever
]
