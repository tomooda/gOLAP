Class {
	#name : 'GolapFilterFieldValuesFunction',
	#superclass : 'GolapFunctionNode',
	#instVars : [
		'values',
		'field'
	],
	#category : 'Golap-Query-StructuredEditor',
	#package : 'Golap-Query',
	#tag : 'StructuredEditor'
}

{ #category : 'instance creation' }
GolapFilterFieldValuesFunction class >> field: aString values: anArray [
	^ self new
		field: aString;
		values: anArray;
		yourself
]

{ #category : 'instance creation' }
GolapFilterFieldValuesFunction class >> fromUserOn: aGolapNetworkClientPresenter [
	GolapQueryFunctionFieldValuesPresenter
		on: aGolapNetworkClientPresenter
		functionName: self functionName
		openDialogIfAccepted: [ :queryFunctionPresenter | 
			^ self
				field: queryFunctionPresenter field
				values: queryFunctionPresenter selectedValues ].
	^ nil
]

{ #category : 'accessing' }
GolapFilterFieldValuesFunction >> field [
	^ field
]

{ #category : 'accessing' }
GolapFilterFieldValuesFunction >> field: aString [
	field := aString
]

{ #category : 'accessing' }
GolapFilterFieldValuesFunction >> functionName [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapFilterFieldValuesFunction >> golapQueryChildren [
	^ values
]

{ #category : 'testing' }
GolapFilterFieldValuesFunction >> isValidGolapQuery [
	^ field notNil and: [ values notNil and: [ values notEmpty ] ]
]

{ #category : 'printing' }
GolapFilterFieldValuesFunction >> printGolapQueryOn: aStream [
	aStream
		nextPutAll: self functionName;
		nextPut: $(.
	field printOn: aStream.
	values
		ifNotNil: [ values
				do: [ :value | 
					aStream nextPut: $,.
					value printGolapQueryOn: aStream ] ].
	aStream nextPut: $)
]

{ #category : 'accessing' }
GolapFilterFieldValuesFunction >> values [
	^ values
]

{ #category : 'accessing' }
GolapFilterFieldValuesFunction >> values: anArray [
	values := anArray
]
