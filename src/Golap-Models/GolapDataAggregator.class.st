Class {
	#name : #GolapDataAggregator,
	#superclass : #Object,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #testing }
GolapDataAggregator class >> isAbstract [

	^ self = GolapDataAggregator
]

{ #category : #evaluating }
GolapDataAggregator >> value: aCollectionOfDataSeries [

	^ self subclassResponsibility
]
