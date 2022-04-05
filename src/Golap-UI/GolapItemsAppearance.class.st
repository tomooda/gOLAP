Class {
	#name : #GolapItemsAppearance,
	#superclass : #SpPresenter,
	#instVars : [
		'showIsolatedVerticesCheckBox',
		'showHiddenConnectionVerticesCheckBox',
		'showConnectedVerticesCheckBox',
		'numLabelsSlider',
		'fontButton',
		'golap',
		'snapshotProcess'
	],
	#classVars : [
		'NameEndOfLineDelimiter'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #specs }
GolapItemsAppearance class >> defaultSpec [
	<spec>
	^ SpPanedLayout newHorizontal
		add:
			(SpBoxLayout newVertical
				add: #showConnectedVerticesCheckBox height: self inputTextHeight;
				add: #showHiddenConnectionVerticesCheckBox
					height: self inputTextHeight;
				add: #showIsolatedVerticesCheckBox height: self inputTextHeight);
		add:
			(SpBoxLayout newVertical
				add: #numLabelsSlider height: self inputTextHeight;
				add: #fontButton height: self buttonHeight)
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

	showIsolatedVerticesCheckBox := self newCheckBox
		                                label: 'isolated';
		                                state: false;
		                                whenChangedDo: [ :value | 
			                                golap updateGlobalImageAfter: [  ].
			                                self snapshot ];
		                                yourself.
	showHiddenConnectionVerticesCheckBox := self newCheckBox
		                                        label: 'hidden';
		                                        state: false;
		                                        whenChangedDo: [ :value | 
			                                        golap 
				                                        updateGlobalImageAfter: [ 
					                                         ].
			                                        self snapshot ];
		                                        yourself.
	showConnectedVerticesCheckBox := self newCheckBox
		                                 label: 'connected';
		                                 state: true;
		                                 whenChangedDo: [ :value | 
			                                 golap updateGlobalImageAfter: [  ].
			                                 self snapshot ];
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
							                   , ' labels' ].
			                   self snapshotLazy ];
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
GolapItemsAppearance >> numLabels [
	^ numLabelsSlider value
]

{ #category : #snapshot }
GolapItemsAppearance >> restore: aStream [

	(NeoJSONReader on: aStream) next
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
	golap := aGolap
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

	snapshotProcess ifNotNil: [ 
		snapshotProcess terminate.
		snapshotProcess := nil ].
	golap snapshotItemsAppearance: [ :stream | self snapshotInto: stream ]
]

{ #category : #snapshot }
GolapItemsAppearance >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: { 
			('show-isolatex-vertices' -> showIsolatedVerticesCheckBox state).
			('show-hidden-connection-vertices'
			 -> showHiddenConnectionVerticesCheckBox state).
			('show-connected-vertices' -> showConnectedVerticesCheckBox state).
			('max-display-labels' -> numLabelsSlider value) }
			asOrderedDictionary
]

{ #category : #snapshot }
GolapItemsAppearance >> snapshotLazy [

	snapshotProcess ifNotNil: [ 
		snapshotProcess terminate.
		snapshotProcess := nil ].
	snapshotProcess := [ 
	                   1 seconds wait.
	                   snapshotProcess := nil.
	                   golap snapshotItemsAppearance: [ :stream | 
		                   self snapshotInto: stream ] ] forkAt:
		                   Processor userBackgroundPriority
]
