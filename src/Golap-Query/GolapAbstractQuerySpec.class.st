Class {
	#name : 'GolapAbstractQuerySpec',
	#superclass : 'Object',
	#category : 'Golap-Query-AST',
	#package : 'Golap-Query',
	#tag : 'AST'
}

{ #category : 'instance creation' }
GolapAbstractQuerySpec class >> fromJSON: aJSONObject [
	^ self subclassResponsibility
]

{ #category : 'instance creation' }
GolapAbstractQuerySpec class >> fromString: aString [
	^ self fromString: aString ifError: [ nil ]
]

{ #category : 'instance creation' }
GolapAbstractQuerySpec class >> fromString: aString ifError: errorBlock [
	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapAbstractQuerySpec >> asJSON [
	^ self subclassResponsibility
]

{ #category : 'operations' }
GolapAbstractQuerySpec >> clearWarningsAndErrors [
	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapAbstractQuerySpec >> guardedPredicatesDo: aBlock [
	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapAbstractQuerySpec >> isClauseSpec [
	^ false
]

{ #category : 'testing' }
GolapAbstractQuerySpec >> isFilterSpec [
	^ false
]

{ #category : 'testing' }
GolapAbstractQuerySpec >> isPredicateSpec [
	^ false
]

{ #category : 'printing' }
GolapAbstractQuerySpec >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPutAll: '( '.
	self printSpecOn: aStream.
	aStream nextPutAll: ' )'
]

{ #category : 'printing' }
GolapAbstractQuerySpec >> printQueryOn: aStream [
	^ self subclassResponsibility
]

{ #category : 'printing' }
GolapAbstractQuerySpec >> printSpec [
	^ String streamContents: [ :stream | self printSpecOn: stream ]
]

{ #category : 'printing' }
GolapAbstractQuerySpec >> printSpecOn: aStream [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapAbstractQuerySpec >> query [
	^ String streamContents: [ :stream | self printQueryOn: stream ]
]
