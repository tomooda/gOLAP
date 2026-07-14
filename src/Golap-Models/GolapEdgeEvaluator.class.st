Class {
	#name : 'GolapEdgeEvaluator',
	#superclass : 'Object',
	#instVars : [
		'min',
		'max',
		'lowerThreshold',
		'upperThreshold'
	],
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'testing' }
GolapEdgeEvaluator class >> isAbstract [

	^ self = GolapEdgeEvaluator
]

{ #category : 'accessing' }
GolapEdgeEvaluator class >> tag [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapEdgeEvaluator >> asSortFunction [

	^ PropertySortFunction property: self
]

{ #category : 'sorting' }
GolapEdgeEvaluator >> ascending [

	^ self asSortFunction
]

{ #category : 'calibrating' }
GolapEdgeEvaluator >> calibrateWithAll: aCollectionOfGolapEdge graph: aGolapModel [

	aCollectionOfGolapEdge
		ifEmpty: [
				min := nil.
				max := nil ]
		ifNotEmpty: [
				min := max := self
					              value: aCollectionOfGolapEdge anyOne
					              graph: aGolapModel.
				aCollectionOfGolapEdge do: [ :edge |
						| value |
						value := self value: edge graph: aGolapModel.
						value < min ifTrue: [ min := value ].
						max < value ifTrue: [ max := value ] ] ]
]

{ #category : 'sorting' }
GolapEdgeEvaluator >> descending [

	^ self asSortFunction reversed
]

{ #category : 'evaluating' }
GolapEdgeEvaluator >> evaluate: aGolapEdge graph: aGolapModel [
	"Returns nil if the value is not between the lower and upper threshold. Otherwise, returns the value"

	| value |
	value := self value: aGolapEdge graph: aGolapModel.
	value ifNil: [ ^ nil ].
	(lowerThreshold notNil and: [ lowerThreshold > value ]) ifTrue: [
		^ nil ].
	(upperThreshold notNil and: [ upperThreshold < value ]) ifTrue: [
		^ nil ].
	^ value
]

{ #category : 'evaluating' }
GolapEdgeEvaluator >> graph: aGolapModel [

	^ [ :edge | self value: edge graph: aGolapModel ]
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> lowerThreshold [

	^ lowerThreshold
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> lowerThreshold: aNumber [

	lowerThreshold := aNumber
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> max [

	^ max
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> min [

	^ min
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> name [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> subtag [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> tag [

	^ self class tag
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> upperThreshold [

	^ upperThreshold
]

{ #category : 'accessing' }
GolapEdgeEvaluator >> upperThreshold: aNumber [

	upperThreshold := aNumber
]

{ #category : 'evaluating' }
GolapEdgeEvaluator >> value: aGolapEdge graph: aGolapModel [

	^ self subclassResponsibility
]
