Class {
	#name : #GolapFilterOrFunction,
	#superclass : #GolapFilterNaryBooleanFunction,
	#category : #'Golap-Query-StructuredEditor'
}

{ #category : #accessing }
GolapFilterOrFunction class >> functionName [
	^ 'or'
]

{ #category : #accessing }
GolapFilterOrFunction >> operatorName [
	^ 'or'
]
