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

{ #category : 'testing' }
GolapClip class >> isAbstract [

	^ self == GolapClip
]

{ #category : 'accessing' }
GolapClip class >> kind [

	^ self subclassResponsibility
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
