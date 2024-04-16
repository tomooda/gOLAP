Class {
	#name : #GolapItemsAppearance,
	#superclass : #SpPresenter,
	#instVars : [
		'minFreqSlider',
		'minFreqField',
		'showIsolatedVerticesCheckBox',
		'showHiddenConnectionVerticesCheckBox',
		'showConnectedVerticesCheckBox',
		'numLabelsSlider',
		'fontButton',
		'golap'
	],
	#classVars : [
		'NameEndOfLineDelimiter'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #layout }
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
		  add: #showConnectedVerticesCheckBox height: self inputTextHeight;
		  add: #showHiddenConnectionVerticesCheckBox
		  height: self inputTextHeight;
		  add: #showIsolatedVerticesCheckBox height: self inputTextHeight;
		  yourself
]

{ #category : #'instance creation' }
GolapItemsAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : #private }
GolapItemsAppearance >> chooseFont [
	golap
		ifNotNil: [ StandardFonts
				chooseFontWithTitle: 'Font for gOLAP'
				for: golap
				setSelector: #font:
				getSelector: #font ]
]

{ #category : #initialization }
GolapItemsAppearance >> initialExtent [
	^ 500@200
]

{ #category : #initialization }
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

	showIsolatedVerticesCheckBox := self newCheckBox
		                                label: 'isolated';
		                                state: false;
		                                whenChangedDo: [ :value |
			                                golap updateGlobalImageAfter: [  ] ];
		                                yourself.
	showHiddenConnectionVerticesCheckBox := self newCheckBox
		                                        label: 'hidden';
		                                        state: false;
		                                        whenChangedDo: [ :value |
			                                        golap
				                                        updateGlobalImageAfter: [
					                                         ] ];
		                                        yourself.
	showConnectedVerticesCheckBox := self newCheckBox
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

{ #category : #initialization }
GolapItemsAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Items'
]

{ #category : #accessing }
GolapItemsAppearance >> maxFrequency: anInteger [

	minFreqSlider max: anInteger.
	minFreqField maximum: anInteger
]

{ #category : #accessing }
GolapItemsAppearance >> minFrequency [

	^ minFreqField number
]

{ #category : #accessing }
GolapItemsAppearance >> minFrequency: anInteger [

	minFreqSlider value rounded = anInteger ifFalse: [
		minFreqSlider value: anInteger ].
	minFreqField number = anInteger ifFalse: [
		minFreqField number: anInteger ].
	golap updateGlobalImageAfter: [  ]
]

{ #category : #accessing }
GolapItemsAppearance >> numLabels [
	^ numLabelsSlider value
]

{ #category : #snapshot }
GolapItemsAppearance >> restore: aStream [

	(NeoJSONReader on: aStream) next
		at: 'minimum-frequency'
		ifPresent: [ :int | minFreqField number: int ];
		at: 'show-isolatex-vertices'
		ifPresent: [ :bool | showIsolatedVerticesCheckBox state: bool ];
		at: 'show-hidden-connection-vertices'
		ifPresent: [ :bool |
			showHiddenConnectionVerticesCheckBox state: bool ];
		at: 'show-connected-vertices'
		ifPresent: [ :bool | showConnectedVerticesCheckBox state: bool ];
		at: 'max-display-labels'
		ifPresent: [ :float | numLabelsSlider value: float ]
]

{ #category : #private }
GolapItemsAppearance >> setGolap: aGolap [

	golap := aGolap.
	self updateMinMaxFrequency
]

{ #category : #accessing }
GolapItemsAppearance >> showsConnectedVertices [
	^ showConnectedVerticesCheckBox state
]

{ #category : #accessing }
GolapItemsAppearance >> showsHiddenConnectionVertices [
	^ showHiddenConnectionVerticesCheckBox state
]

{ #category : #accessing }
GolapItemsAppearance >> showsIsolatedVertices [
	^ showIsolatedVerticesCheckBox state
]

{ #category : #snapshot }
GolapItemsAppearance >> snapshot [

	golap snapshotItemsAppearance: [ :stream | self snapshotInto: stream ]
]

{ #category : #snapshot }
GolapItemsAppearance >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: {
			('minimum-frequency' -> minFreqField number).
			('show-isolatex-vertices' -> showIsolatedVerticesCheckBox state).
			('show-hidden-connection-vertices'
			 -> showHiddenConnectionVerticesCheckBox state).
			('show-connected-vertices' -> showConnectedVerticesCheckBox state).
			('max-display-labels' -> numLabelsSlider value) }
			asOrderedDictionary
]

{ #category : #updating }
GolapItemsAppearance >> updateMinMaxFrequency [

	golap ifNotNil: [
		golap model ifNotNil: [ :model |
			(golap vertices collect: golap model vertexEvaluator)
				ifEmpty: [
					self
						minFrequency: 0;
						maxFrequency: 1 ]
				ifNotEmpty: [ :freqs |
					self minFrequency: freqs min.
					self maxFrequency: freqs max ] ] ]
]
