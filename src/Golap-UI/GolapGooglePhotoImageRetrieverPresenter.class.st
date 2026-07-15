Class {
	#name : 'GolapGooglePhotoImageRetrieverPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'retriever',
		'cseidField',
		'apikeyField',
		'enabledCheckbox'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapGooglePhotoImageRetrieverPresenter class >> on: aGolapGooglePhotoImageRetriever [

	^ self new
		  retriever: aGolapGooglePhotoImageRetriever;
		  yourself
]

{ #category : 'layout' }
GolapGooglePhotoImageRetrieverPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: 'CSE ID' width: 100;
				   add: cseidField;
				   yourself)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: 'API Key' width: 100;
				   add: apikeyField;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'initialization' }
GolapGooglePhotoImageRetrieverPresenter >> initializePresenters [

	cseidField := self newTextInput
		              whenTextChangedDo: [ :text |
			              retriever ifNotNil: [
					              retriever cseid: (text trim ifEmpty: [ nil ]) ] ];
		              yourself.
	apikeyField := self newTextInput
		               whenTextChangedDo: [ :text |
			               retriever ifNotNil: [
					               retriever apikey: (text trim ifEmpty: [ nil ]) ] ];
		               yourself
]

{ #category : 'initialization' }
GolapGooglePhotoImageRetrieverPresenter >> initializeWindow: aSpWindow [

	super initializeWindow: aSpWindow.
	aSpWindow initialExtent: 300 @ 150
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetrieverPresenter >> retriever [

	^ retriever
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetrieverPresenter >> retriever: aGolapPhotoImageRetriever [

	retriever := aGolapPhotoImageRetriever.
	cseidField text: (retriever cseid ifNil: [ '' ]).
	apikeyField text: (retriever apikey ifNil: [ '' ])
]

{ #category : 'accessing' }
GolapGooglePhotoImageRetrieverPresenter >> windowTitle [

	^ 'Google検索API設定'
]
