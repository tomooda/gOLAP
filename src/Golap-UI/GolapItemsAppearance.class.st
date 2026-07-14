Class {
	#name : 'GolapItemsAppearance',
	#superclass : 'SpPresenter',
	#instVars : [
		'fontButton',
		'golap',
		'photoimageRetrievers',
		'photoimageRetrievalProgressBar',
		'startPhotoimageRetrievalButton',
		'showPhotoImagesCheckbox'
	],
	#classVars : [
		'NameEndOfLineDelimiter'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'instance creation' }
GolapItemsAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : 'testing' }
GolapItemsAppearance >> basicShowsPhotoimages: aBoolean [

	showPhotoImagesCheckbox setState: aBoolean = true
]

{ #category : 'layouts' }
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

{ #category : 'layouts' }
GolapItemsAppearance >> defaultLayout [

	<spec>
	^ SpBoxLayout newHorizontal add: (SpBoxLayout newVertical
			   add: fontButton expand: false;
			   add: '商品画像取得' expand: false;
			   add: photoimageRetrievers expand: true;
			   add: (SpBoxLayout newHorizontal
					    add: photoimageRetrievalProgressBar;
					    add: startPhotoimageRetrievalButton width: self buttonHeight)
			   expand: false;
			   add: showPhotoImagesCheckbox expand: false;
			   yourself)
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
		                                  yourself.
	showPhotoImagesCheckbox := self newCheckBox
		                           label: '商品画像を表示する';
		                           state: true;
		                           whenChangedDo: [
			                           self showsPhotoimagesChanged ];
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

{ #category : 'private' }
GolapItemsAppearance >> setGolap: aGolap [

	golap := aGolap.
	photoimageRetrievers golap: aGolap.
	self updatePhotoimageRetrievers
]

{ #category : 'testing' }
GolapItemsAppearance >> showsPhotoimages [

	^ showPhotoImagesCheckbox state
]

{ #category : 'testing' }
GolapItemsAppearance >> showsPhotoimages: aBoolean [

	showPhotoImagesCheckbox state: aBoolean = true
]

{ #category : 'updating' }
GolapItemsAppearance >> showsPhotoimagesChanged [

	golap ifNotNil: #showsPhotoimagesChanged
]

{ #category : 'updating' }
GolapItemsAppearance >> updatePhotoimageRetrievers [

	photoimageRetrievers itemInfoRetriever: golap itemInfoRetriever
]
