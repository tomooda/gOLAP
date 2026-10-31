Class {
	#name : 'GolapClip',
	#superclass : 'Object',
	#instVars : [
		'id'
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

{ #category : 'converting' }
GolapClip >> asHtml [

	^ String streamContents: [ :stream | self printHtmlOn: stream ]
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
GolapClip >> fromJSON: aDictionary [

	aDictionary at: 'id' ifPresent: [ :string | self id: string ]
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

{ #category : 'converting' }
GolapClip >> toJSON: aDictionary [

	aDictionary
		at: 'kind' put: self kind;
		at: 'id' put: id
]
