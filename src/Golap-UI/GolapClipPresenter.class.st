Class {
	#name : 'GolapClipPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'image',
		'captionText',
		'clip'
	],
	#category : 'Golap-UI-Notepad',
	#package : 'Golap-UI',
	#tag : 'Notepad'
}

{ #category : 'instance creation' }
GolapClipPresenter class >> on: aGolapClip [

	^ self new
		  clip: aGolapClip;
		  yourself
]

{ #category : 'operations' }
GolapClipPresenter >> addToNote [

	GolapProjectPresenter current addClip: clip.
	self window ifNotNil: #close
]

{ #category : 'operations' }
GolapClipPresenter >> appendToNote [

	GolapProjectPresenter current appendClip: clip.
	self window ifNotNil: #close
]

{ #category : 'showing' }
GolapClipPresenter >> asModalWindow [

	| window |
	window := super asModalWindow.
	window buttons first
		label: 'キャンセル';
		action: [ self cancel ].
	window buttons second
		label: '保存する';
		action: [ self addToNote ].
	window addDefaultButton: '保存してノートに追記する' do: [ self appendToNote ].
	^ window
]

{ #category : 'operations' }
GolapClipPresenter >> cancel [

	self window ifNotNil: #close
]

{ #category : 'accessing' }
GolapClipPresenter >> clip: aGolapClip [

	clip := aGolapClip.
	self clipChanged
]

{ #category : 'updating' }
GolapClipPresenter >> clipChanged [

	self
		updateImage;
		updateCaptionText
]

{ #category : 'layout' }
GolapClipPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: image height: 400;
		  add: captionText;
		  yourself
]

{ #category : 'initialization' }
GolapClipPresenter >> initializePresenters [

	super initializePresenters.
	image := self newImage
		         autoScale: true;
		         yourself.
	captionText := self newText
		               help: 'キャプション';
		               placeholder: 'キャプション';
		               whenTextChangedDo: [ clip ifNotNil: [ clip caption: captionText text ] ];
		               yourself
]

{ #category : 'initialization' }
GolapClipPresenter >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter
		title: 'クリップ編集';
		initialExtent: 600 @ 650
]

{ #category : 'updating' }
GolapClipPresenter >> updateCaptionText [

	captionText text: (clip ifNotNil: #caption ifNil: [ '' ])
]

{ #category : 'updating' }
GolapClipPresenter >> updateImage [

	image image: (clip ifNotNil: #image)
]

{ #category : 'updating' }
GolapClipPresenter >> updateText [

	captionText text: (clip ifNotNil: #caption ifNil: [ '' ])
]
