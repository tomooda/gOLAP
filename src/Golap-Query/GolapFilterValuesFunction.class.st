Class {
	#name : #GolapFilterValuesFunction,
	#superclass : #GolapFunctionNode,
	#instVars : [
		'values'
	],
	#category : #'Golap-Query-StructuredEditor'
}

{ #category : #'instance creation' }
GolapFilterValuesFunction class >> values: anArray [
	^ self new
		values: anArray;
		yourself
]

{ #category : #accessing }
GolapFilterValuesFunction >> functionName [
	^ self subclassResponsibility
]

{ #category : #accessing }
GolapFilterValuesFunction >> golapQueryChildren [
	^ values
]

{ #category : #testing }
GolapFilterValuesFunction >> isValidGolapQuery [
	^ values notNil and: [ values notEmpty ]
]

{ #category : #printing }
GolapFilterValuesFunction >> printGolapQueryOn: aStream [
	aStream
		nextPutAll: self functionName;
		nextPut: $(.
	values
		ifNotNil: [ values
				do: [ :value | value printGolapQueryOn: aStream ]
				separatedBy: [ aStream nextPut: $, ] ].
	aStream nextPut: $)
]
