Class {
	#name : 'GolapServerPhotoImageRetrieverPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'golapServerUrlField',
		'imageServerUrlField',
		'retriever'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'layout' }
GolapServerPhotoImageRetrieverPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: 'gOLAPサーバURL' width: 100;
				   add: #golapServerUrlField)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: '画像サーバURL' width: 100;
				   add: #imageServerUrlField)
		  expand: false;
		  yourself
]

{ #category : 'instance creation' }
GolapServerPhotoImageRetrieverPresenter class >> on: aGolapServerPhotoImageRetriever [

	^ self new
		  retriever: aGolapServerPhotoImageRetriever;
		  yourself
]

{ #category : 'updating' }
GolapServerPhotoImageRetrieverPresenter >> golapServerUrlChanged [

	retriever golapServerUrl: golapServerUrlField text
]

{ #category : 'updating' }
GolapServerPhotoImageRetrieverPresenter >> imageServerUrlChanged [

	retriever imageServerUrl: imageServerUrlField text
]

{ #category : 'initialization' }
GolapServerPhotoImageRetrieverPresenter >> initializePresenters [

	golapServerUrlField := self newTextInput
		                       whenTextChangedDo: [
			                       self golapServerUrlChanged ];
		                       yourself.
	imageServerUrlField := self newTextInput
		                       whenTextChangedDo: [
			                       self imageServerUrlChanged ];
		                       yourself
]

{ #category : 'initialization' }
GolapServerPhotoImageRetrieverPresenter >> initializeWindow: aSpWindowPresenter [

	aSpWindowPresenter
		initialExtent: 600 @ 150;
		title: 'gOLAPサーバ画像設定'
]

{ #category : 'accessing' }
GolapServerPhotoImageRetrieverPresenter >> retriever: aGolapServerPhotoImageRetriever [

	retriever := aGolapServerPhotoImageRetriever.
	golapServerUrlField text:
		aGolapServerPhotoImageRetriever golapServerUrl asString.
	imageServerUrlField text:
		aGolapServerPhotoImageRetriever imageServerUrl asString.
	self updateButtons
]

{ #category : 'accessing' }
GolapServerPhotoImageRetrieverPresenter >> title [

	^ 'gOLAPサーバ画像設定'
]

{ #category : 'updating' }
GolapServerPhotoImageRetrieverPresenter >> updateButtons [

	self window ifNotNil: [ :window |
		window isDialog ifTrue: [
			window buttons first enabled:
				(golapServerUrlField text notEmpty and: [
					 imageServerUrlField text notEmpty ]) ] ]
]
