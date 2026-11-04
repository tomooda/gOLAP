Class {
	#name : 'GolapClip',
	#superclass : 'Object',
	#instVars : [
		'id',
		'caption',
		'timestamp'
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

	GolapProject current note addClip: self
]

{ #category : 'operations' }
GolapClip >> appendToNote [

	GolapProject current note appendClip: self
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

	aDictionary at: 'id' ifPresent: [ :string | self id: string ].
	aDictionary at: 'caption' ifPresent: [ :string | self caption: string ].
	aDictionary at: 'timestamp' ifPresent: [ :string | self timestamp: (DateAndTime fromString: string) ]
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

{ #category : 'initialization' }
GolapClip >> initialize [

	super initialize.
	timestamp := DateAndTime now.
	caption := String new
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

	^ self subclassResponsibility
]

{ #category : 'printing' }
GolapClip >> printMarkDownOn: aStream [

	^ self subclassResponsibility
]

{ #category : 'printing' }
GolapClip >> printMicrodownOn: aStream [

	^ self subclassResponsibility
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
		at: 'timestamp' put: self timestamp printString
]
