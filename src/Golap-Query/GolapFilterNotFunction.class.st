Class {
	#name : 'GolapFilterNotFunction',
	#superclass : 'GolapFilterBooleanFunction',
	#instVars : [
		'node'
	],
	#category : 'Golap-Query-StructuredEditor',
	#package : 'Golap-Query',
	#tag : 'StructuredEditor'
}

{ #category : 'accessing' }
GolapFilterNotFunction class >> functionName [
	^ 'not'
]

{ #category : 'instance creation' }
GolapFilterNotFunction class >> with: aGolapFilterNode [
	^ self new
		node: aGolapFilterNode;
		yourself
]

{ #category : 'accessing' }
GolapFilterNotFunction >> golapQueryChildren [
	^ Array with: node
]

{ #category : 'testing' }
GolapFilterNotFunction >> isValidGolapQuery [
	^ node notNil and: [ node isValidGolapQuery ]
]

{ #category : 'accessing' }
GolapFilterNotFunction >> operatorName [
	^ 'not'
]

{ #category : 'printing' }
GolapFilterNotFunction >> printGolapQueryOn: aStream [
	aStream nextPutAll: 'not('.
	node printGolapQueryOn: aStream.
	aStream nextPut: $)
]
