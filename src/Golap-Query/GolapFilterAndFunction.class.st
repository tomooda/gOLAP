Class {
	#name : 'GolapFilterAndFunction',
	#superclass : 'GolapFilterNaryBooleanFunction',
	#category : 'Golap-Query-StructuredEditor',
	#package : 'Golap-Query',
	#tag : 'StructuredEditor'
}

{ #category : 'accessing' }
GolapFilterAndFunction class >> functionName [
	^ 'and'
]

{ #category : 'accessing' }
GolapFilterAndFunction >> operatorName [
	^  'and'
]
