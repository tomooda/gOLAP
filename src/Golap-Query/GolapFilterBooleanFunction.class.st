Class {
	#name : 'GolapFilterBooleanFunction',
	#superclass : 'GolapFunctionNode',
	#category : 'Golap-Query-StructuredEditor',
	#package : 'Golap-Query',
	#tag : 'StructuredEditor'
}

{ #category : 'accessing' }
GolapFilterBooleanFunction >> operatorName [
	^ self subclassResponsibility
]
