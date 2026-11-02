Class {
	#name : 'GolapGraphClip',
	#superclass : 'GolapClip',
	#instVars : [
		'image',
		'golap'
	],
	#category : 'Golap-Notepad-Clip',
	#package : 'Golap-Notepad',
	#tag : 'Clip'
}

{ #category : 'accessing' }
GolapGraphClip class >> kind [

	^ 'graph'
]

{ #category : 'converting' }
GolapGraphClip >> asPresenter [

	^ GolapGraphClipPresenter on: self
]

{ #category : 'accessing' }
GolapGraphClip >> base64image [

	^ image ifNotNil: [ (ByteArray streamContents: [ :stream | PNGReadWriter putForm: image onStream: stream ]) base64Encoded ]
]

{ #category : 'accessing' }
GolapGraphClip >> base64image: aString [

	image := aString ifNotNil: [ PNGReadWriter formFromStream: aString base64Decoded readStream ]
]

{ #category : 'converting' }
GolapGraphClip >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'golap' ifPresent: [ :dict | golap := dict ];
		at: 'image' ifPresent: [ :string | self base64image: string ]
]

{ #category : 'accessing' }
GolapGraphClip >> golap [

	^ golap
]

{ #category : 'accessing' }
GolapGraphClip >> golap: aDictionary [

	golap := aDictionary
]

{ #category : 'accessing' }
GolapGraphClip >> image [

	^ image
]

{ #category : 'accessing' }
GolapGraphClip >> image: aForm [

	image := aForm
]

{ #category : 'operations' }
GolapGraphClip >> open [

	^ Golap fromJSON: golap
]

{ #category : 'printing' }
GolapGraphClip >> printHtmlOn: aStream [

	aStream
		nextPutAll: '<div><img alt="';
		nextPutAll: id;
		nextPutAll: '" src="';
		nextPutAll: id;
		nextPutAll: '.png"></div>';
		cr;
		nextPutAll: '<pre>';
		cr;
		nextPutAll: caption;
		nextPutAll: '</pre>';
		cr
]

{ #category : 'printing' }
GolapGraphClip >> printMarkDownOn: aStream [

	aStream
		cr;
		nextPutAll: '![';
		nextPutAll: id;
		nextPutAll: '](';
		nextPutAll: id;
		nextPutAll: '.png)';
		cr;
		nextPutAll: (caption ifNil: [ '' ]);
		cr
]

{ #category : 'printing' }
GolapGraphClip >> printMicrodownOn: aStream [

	aStream
		cr;
		nextPutAll: '```gOLAP';
		cr;
		nextPutAll: id;
		cr;
		nextPutAll: '```';
		cr;
		nextPutAll: (caption ifNil: [ '' ]);
		cr
]

{ #category : 'converting' }
GolapGraphClip >> toJSON: aDictionary [

	super toJSON: aDictionary.
	aDictionary
		at: 'golap' put: golap;
		at: 'image' put: self base64image
]
