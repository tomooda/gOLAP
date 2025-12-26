Class {
	#name : 'GolapItemsAppearance',
	#superclass : 'SpPresenter',
	#instVars : [
		'fontButton',
		'golap',
		'photoimageRetrievers',
		'photoimageRetrievalProgressBar',
		'startPhotoimageRetrievalButton'
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
		  add: #fontButton height: self buttonHeight;
		  add: (SpBoxLayout newHorizontal
				   add: #showConnectedNodesCheckBox;
				   add: #showHiddenConnectionNodesCheckBox;
				   add: #showIsolatedNodesCheckBox)
		  height: self inputTextHeight;
		  add: #photoimageRetrievers;
		  add: (SpBoxLayout newHorizontal
				   add: #photoimageRetrievalProgressBar;
				   add: #startPhotoimageRetrievalButton width: self buttonHeight)
		  expand: false;
		  yourself
]

{ #category : 'instance creation' }
GolapItemsAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : 'layout' }
GolapItemsAppearance >> buttonHeight [

	^ self class buttonHeight
]

{ #category : 'private' }
GolapItemsAppearance >> chooseFont [

	golap ifNotNil: [
			FontChooser
				openModalWithTitle: 'Font for Golap'
				initialFont: Golap defaultFont
				onAcceptDo: [ :font | Golap defaultFont: font ] ]
]

{ #category : 'layout' }
GolapItemsAppearance >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
		  add: fontButton height: self buttonHeight;
		  add: photoimageRetrievers;
		  add: (SpBoxLayout newHorizontal
				   add: photoimageRetrievalProgressBar;
				   add: startPhotoimageRetrievalButton width: self buttonHeight)
		  expand: false;
		  yourself
]

{ #category : 'initialization' }
GolapItemsAppearance >> initializePresenters [

	fontButton := self newButton
		              label: 'フォント';
		              action: [ self chooseFont ];
		              yourself.
	photoimageRetrievers := self instantiate:
		                        GolapPhotoImageRetrieversPresenter.
	photoimageRetrievalProgressBar := self newProgressBar
		                                  color: Color red;
		                                  value: 0 message: ''.
	startPhotoimageRetrievalButton := self newButton
		                                  icon: (self iconNamed: #restart);
		                                  action: [
			                                  golap ifNotNil:
					                                  #startPhotoimageRetrievingProcess ];
		                                  yourself
]

{ #category : 'initialization' }
GolapItemsAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Items'
]

{ #category : 'accessing' }
GolapItemsAppearance >> photoimageRetrievalProgressBar [

	^ photoimageRetrievalProgressBar
]

{ #category : 'snapshot' }
GolapItemsAppearance >> restore: aStream [


]

{ #category : 'private' }
GolapItemsAppearance >> setGolap: aGolap [

	golap := aGolap.
	photoimageRetrievers golap: aGolap.
	self updatePhotoimageRetrievers
]

{ #category : 'snapshot' }
GolapItemsAppearance >> snapshot [

	golap snapshotItemsAppearance: [ :stream | self snapshotInto: stream ]
]

{ #category : 'snapshot' }
GolapItemsAppearance >> snapshotInto: aStream [


]

{ #category : 'updating' }
GolapItemsAppearance >> updatePhotoimageRetrievers [

	photoimageRetrievers itemInfoRetriever: golap itemInfoRetriever
]
