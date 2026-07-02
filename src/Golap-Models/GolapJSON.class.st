Class {
	#name : 'GolapJSON',
	#superclass : 'Object',
	#category : 'Golap-Models-JSON',
	#package : 'Golap-Models',
	#tag : 'JSON'
}

{ #category : 'operations' }
GolapJSON class >> fromStream: aReadStream [

	^ (self reader on: aReadStream) next
]

{ #category : 'operations' }
GolapJSON class >> fromString: aString [

	^ self fromStream: aString readStream
]

{ #category : 'operations' }
GolapJSON class >> put: anObject onStream: aWriteStream [

	(self writer on: aWriteStream) nextPut: anObject
]

{ #category : 'operations' }
GolapJSON class >> put: anObject onStreamPretty: aWriteStream [

	(self writer on: aWriteStream)
		prettyPrint: true;
		nextPut: anObject
]

{ #category : 'accessing' }
GolapJSON class >> reader [

	^ GolapJSONReader new
]

{ #category : 'operations' }
GolapJSON class >> toString: anObject [

	^ String streamContents: [ :stream |
		  self put: anObject onStream: stream ]
]

{ #category : 'operations' }
GolapJSON class >> toStringPretty: anObject [

	^ String streamContents: [ :stream |
		  self put: anObject onStreamPretty: stream ]
]

{ #category : 'accessing' }
GolapJSON class >> writer [

	^ GolapJSONWriter new
]
