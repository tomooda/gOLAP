Class {
	#name : 'GolapItemsAppearance',
	#superclass : 'SpPresenter',
	#instVars : [
		'fontButton',
		'golap',
		'photoimageRetrievers',
		'photoimageRetrievalProgressBar',
		'startPhotoimageRetrievalButton',
		'showPhotoImagesCheckbox',
		'showsPhotoimageRetrievalLogCheckbox',
		'clearItemInfoCache'
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

{ #category : 'operations' }
GolapItemsAppearance >> clearItemInfoCache [

	(golap ifNotNil: #itemInfoRetriever) ifNotNil: #flushProductDataCache
]

{ #category : 'layouts' }
GolapItemsAppearance >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
		  add: '商品情報取得' asPresenter expand: false;
		  add: clearItemInfoCache expand: false;
		  add: '商品画像取得' asPresenter expand: false;
		  add: photoimageRetrievers expand: true;
		  add: (SpBoxLayout newHorizontal
				   add: photoimageRetrievalProgressBar;
				   add: startPhotoimageRetrievalButton width: self buttonHeight)
		  expand: false;
		  add: showPhotoImagesCheckbox expand: false;
		  add: showsPhotoimageRetrievalLogCheckbox expand: false;
		  yourself
]

{ #category : 'initialization' }
GolapItemsAppearance >> initializePresenters [

	clearItemInfoCache := self newButton
		                      icon: (self iconNamed: #refreshCircling);
		                      label: '商品情報をクリア';
		                      action: [ self clearItemInfoCache ];
		                      yourself.
	photoimageRetrievers := self instantiate: GolapPhotoImageRetrieversPresenter.
	photoimageRetrievalProgressBar := self newProgressBar
		                                  color: Color red;
		                                  value: 0 message: ''.
	startPhotoimageRetrievalButton := self newButton
		                                  icon: (self iconNamed: #restart);
		                                  action: [ golap ifNotNil: #startPhotoimageRetrievingProcess ];
		                                  yourself.
	showPhotoImagesCheckbox := self newCheckBox
		                           label: '商品画像を表示する';
		                           state: true;
		                           whenChangedDo: [ self showsPhotoimagesChanged ];
		                           yourself.
	showsPhotoimageRetrievalLogCheckbox := self newCheckBox
		                                       label: '画像取得後にログを開く';
		                                       state: false;
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
GolapItemsAppearance >> showsPhotoimageRetrievalLog [

	^ showsPhotoimageRetrievalLogCheckbox state = true
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

	photoimageRetrievers itemInfoRetriever: golap itemInfoRetriever.
	clearItemInfoCache enabled: (golap itemInfoRetriever notNil and: [ golap itemInfoRetriever canFlushProductDataCache ])
]
