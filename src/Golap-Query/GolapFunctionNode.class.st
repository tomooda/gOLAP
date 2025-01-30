Class {
	#name : 'GolapFunctionNode',
	#superclass : 'Object',
	#instVars : [
		'parent'
	],
	#category : 'Golap-Query-StructuredEditor',
	#package : 'Golap-Query',
	#tag : 'StructuredEditor'
}

{ #category : 'accessing' }
GolapFunctionNode class >> functionName [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapFunctionNode >> golapQueryChildren [
	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapFunctionNode >> isValidGolapQuery [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapFunctionNode >> parent [
	^ parent
]

{ #category : 'accessing' }
GolapFunctionNode >> parent: aGolapFilterNode [
	parent := aGolapFilterNode
]

{ #category : 'printing' }
GolapFunctionNode >> printGolapQueryOn: aStream [
	^ self subclassResponsibility
]
