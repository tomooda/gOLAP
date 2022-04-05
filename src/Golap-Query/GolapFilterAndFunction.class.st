Class {
	#name : #GolapFilterAndFunction,
	#superclass : #GolapFilterNaryBooleanFunction,
	#category : #'Golap-Query-StructuredEditor'
}

{ #category : #accessing }
GolapFilterAndFunction class >> functionName [
	^ 'and'
]

{ #category : #accessing }
GolapFilterAndFunction >> operatorName [
	^  'and'
]
