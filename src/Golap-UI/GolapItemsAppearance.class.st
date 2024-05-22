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
		'showIsolatedNodesCheckBox'
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
		  add: (SpBoxLayout newHorizontal
				   add: #minFreqSlider;
				   add: '  ' expand: false;
				   add: #minFreqField width: 50)
		  height: self inputTextHeight;
		  add: #numLabelsSlider height: self inputTextHeight;
		  add: #fontButton height: self buttonHeight;
		  add: #showConnectedNodesCheckBox height: self inputTextHeight;
		  add: #showHiddenConnectionNodesCheckBox
		  height: self inputTextHeight;
		  add: #showIsolatedNodesCheckBox height: self inputTextHeight;
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
	golap
		ifNotNil: [ StandardFonts
				chooseFontWithTitle: 'Font for gOLAP'
				for: golap
				setSelector: #font:
				getSelector: #font ]
]

{ #category : 'initialization' }
GolapItemsAppearance >> initialExtent [
	^ 500@200
]

{ #category : 'initialization' }
GolapItemsAppearance >> initializePresenters [

	minFreqSlider := self newSlider
		                 label: 'min freq';
		                 min: 1;
		                 max: 100;
		                 quantum: 1;
		                 value: 1;
		                 whenValueChangedDo: [ :value |
			                 self minFrequency: value rounded ];
		                 yourself.
	minFreqField := self newNumberInput
		                beInteger;
		                minimum: 1;
		                maximum: 100;
		                number: 1;
		                whenNumberChangedDo: [ :value |
			                self minFrequency: value ];
		                yourself.

	showIsolatedNodesCheckBox := self newCheckBox
		                                label: 'isolated';
		                                state: false;
		                                whenChangedDo: [ :value |
			                                golap updateGlobalImageAfter: [  ] ];
		                                yourself.
	showHiddenConnectionNodesCheckBox := self newCheckBox
		                                        label: 'hidden';
		                                        state: false;
		                                        whenChangedDo: [ :value |
			                                        golap
				                                        updateGlobalImageAfter: [
					                                         ] ];
		                                        yourself.
	showConnectedNodesCheckBox := self newCheckBox
		                                 label: 'connected';
		                                 state: true;
		                                 whenChangedDo: [ :value |
			                                 golap updateGlobalImageAfter: [  ] ];
		                                 yourself.
	numLabelsSlider := self newSlider
		                   label: 'labels';
		                   min: 0.0;
		                   max: 2.0;
		                   quantum: 0.1;
		                   value: 1.0;
		                   whenValueChangedDo: [ :value |
			                   golap updateGlobalImageAfter: [
					                   numLabelsSlider label:
							                   (50.0 ** value) truncated printString
							                   , ' labels' ] ];
		                   yourself.
	fontButton := self newButton
		              label: 'font';
		              action: [ self chooseFont ];
		              yourself
]

{ #category : 'initialization' }
GolapItemsAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Items'
]

{ #category : 'accessing' }
GolapItemsAppearance >> maxFrequency: anInteger [

	minFreqSlider max: anInteger.
	minFreqField maximum: anInteger
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
	self updateMinMaxFrequency
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

	golap ifNotNil: [
		golap model ifNotNil: [ :model |
			(golap nodes collect: golap model nodeEvaluator)
				ifEmpty: [
					self
						minFrequency: 0;
						maxFrequency: 1 ]
				ifNotEmpty: [ :freqs |
					self minFrequency: freqs min.
					self maxFrequency: freqs max ] ] ]
]
