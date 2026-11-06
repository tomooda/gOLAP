Class {
	#name : 'GolapGraphClipPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'graphClip',
		'image',
		'captionText'
	],
	#category : 'Golap-UI-Notepad',
	#package : 'Golap-UI',
	#tag : 'Notepad'
}

{ #category : 'instance creation' }
GolapGraphClipPresenter class >> on: aGolapGraphClip [

	^ self new
		  graphClip: aGolapGraphClip;
		  yourself
]

{ #category : 'layout' }
GolapGraphClipPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: image height: 400;
		  add: captionText;
		  yourself
]

{ #category : 'accessing' }
GolapGraphClipPresenter >> graphClip [

	^ graphClip
]

{ #category : 'accessing' }
GolapGraphClipPresenter >> graphClip: aGolapGraphClip [

	graphClip := aGolapGraphClip.
	self graphClipChanged
]

{ #category : 'updating' }
GolapGraphClipPresenter >> graphClipChanged [

	self
		updateImage;
		updateCaptionText
]

{ #category : 'initialization' }
GolapGraphClipPresenter >> initializePresenters [

	super initializePresenters.
	image := self newImage
		         autoScale: true;
		         yourself.
	captionText := self newText
		               help: 'キャプション';
		               placeholder: 'キャプション';
		               whenTextChangedDo: [ graphClip ifNotNil: [ graphClip caption: captionText text ] ];
		               yourself
]

{ #category : 'initialization' }
GolapGraphClipPresenter >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter
		title: 'グラフクリップ編集';
		initialExtent: 600 @ 650
]

{ #category : 'updating' }
GolapGraphClipPresenter >> updateCaptionText [

	captionText text: (graphClip ifNotNil: #caption ifNil: [ '' ])
]

{ #category : 'updating' }
GolapGraphClipPresenter >> updateImage [

	image image: (graphClip ifNotNil: #image)
]

{ #category : 'updating' }
GolapGraphClipPresenter >> updateText [

	captionText text: (graphClip ifNotNil: #caption ifNil: [ '' ])
]
