Class {
	#name : 'GolapDataAggregator',
	#superclass : 'Object',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'testing' }
GolapDataAggregator class >> isAbstract [

	^ self = GolapDataAggregator
]

{ #category : 'evaluating' }
GolapDataAggregator >> value: aCollectionOfDataSeries [

	^ self subclassResponsibility
]
