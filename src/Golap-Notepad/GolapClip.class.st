Class {
	#name : 'GolapClip',
	#superclass : 'Object',
	#instVars : [
		'id',
		'caption',
		'timestamp',
		'image',
		'json'
	],
	#category : 'Golap-Notepad-Clip',
	#package : 'Golap-Notepad',
	#tag : 'Clip'
}

{ #category : 'instance creation' }
GolapClip class >> fromJSON: aDictionary [

	aDictionary at: 'kind' ifPresent: [ :kind |
			self allSubclassesDo: [ :subclass |
				(subclass isAbstract not and: [ subclass kind = kind ]) ifTrue: [ ^ subclass new fromJSON: aDictionary ] ] ].
	^ nil
]

{ #category : 'testing' }
GolapClip class >> isAbstract [

	^ self == GolapClip
]

{ #category : 'accessing' }
GolapClip class >> kind [

	^ self subclassResponsibility
]

{ #category : 'operations' }
GolapClip >> addToNote [

	self asPresenter openModal
]

{ #category : 'converting' }
GolapClip >> asHtml [

	^ String streamContents: [ :stream | self printHtmlOn: stream ]
]

{ #category : 'converting' }
GolapClip >> asJSON [

	| json |
	json := Dictionary new.
	self toJSON: json.
	^ json
]

{ #category : 'converting' }
GolapClip >> asMarkDown [

	^ String streamContents: [ :stream | self printMarkDownOn: stream ]
]

{ #category : 'converting' }
GolapClip >> asMicrodown [

	^ String streamContents: [ :stream | self printMicrodownOn: stream ]
]

{ #category : 'converting' }
GolapClip >> asPresenter [

	^ GolapClipPresenter on: self
]

{ #category : 'accessing' }
GolapClip >> base64image [

	^ image ifNotNil: [ (ByteArray streamContents: [ :stream | PNGReadWriter putForm: image onStream: stream ]) base64Encoded ]
]

{ #category : 'accessing' }
GolapClip >> base64image: aString [

	image := aString ifNotNil: [ PNGReadWriter formFromStream: aString base64Decoded readStream ]
]

{ #category : 'accessing' }
GolapClip >> caption [

	^ caption
]

{ #category : 'accessing' }
GolapClip >> caption: aString [

	caption := aString
]

{ #category : 'operations' }
GolapClip >> copyMicrodownToClipboard [

	(GolapProject current note addClip: self) ifNotNil: [ :clip | Clipboard clipboardText: clip asMicrodown ]
]

{ #category : 'converting' }
GolapClip >> fromJSON: aDictionary [

	aDictionary
		at: 'id' ifPresent: [ :string | self id: string ];
		at: 'caption' ifPresent: [ :string | self caption: string ];
		at: 'timestamp' ifPresent: [ :string | self timestamp: (DateAndTime fromString: string) ];
		at: 'json' ifPresent: [ :dict | json := dict ];
		at: 'golap' ifPresent: [ :dict | json := dict ];
		at: 'image' ifPresent: [ :string | self base64image: string ]
]

{ #category : 'comparing' }
GolapClip >> hash [

	^ id hash
]

{ #category : 'accessing' }
GolapClip >> id [

	^ id
]

{ #category : 'accessing' }
GolapClip >> id: aString [

	id := aString
]

{ #category : 'accessing' }
GolapClip >> image [

	^ image
]

{ #category : 'accessing' }
GolapClip >> image: aForm [

	image := aForm ifNotNil: [ aForm scaledToSize: 400 @ 400 ]
]

{ #category : 'initialization' }
GolapClip >> initialize [

	super initialize.
	timestamp := DateAndTime now.
	caption := String new
]

{ #category : 'accessing' }
GolapClip >> json [

	^ json
]

{ #category : 'accessing' }
GolapClip >> json: aDictionary [

	json := aDictionary
]

{ #category : 'accessing' }
GolapClip >> kind [

	^ self class kind
]

{ #category : 'operations' }
GolapClip >> open [

	^ self subclassResponsibility
]

{ #category : 'printing' }
GolapClip >> printHtmlOn: aStream [

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
GolapClip >> printMarkDownOn: aStream [

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
GolapClip >> printMicrodownOn: aStream [

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

{ #category : 'accessing' }
GolapClip >> timestamp [

	^ timestamp ifNil: [ timestamp := DateAndTime now ]
]

{ #category : 'accessing' }
GolapClip >> timestamp: aDateAndTime [

	timestamp := aDateAndTime
]

{ #category : 'converting' }
GolapClip >> toJSON: aDictionary [

	aDictionary
		at: 'kind' put: self kind;
		at: 'id' put: id;
		at: 'caption' put: caption;
		at: 'timestamp' put: self timestamp printString;
		at: 'json' put: json;
		at: 'image' put: self base64image
]
