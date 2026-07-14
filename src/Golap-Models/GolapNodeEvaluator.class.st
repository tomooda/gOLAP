Class {
	#name : 'GolapNodeEvaluator',
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
GolapNodeEvaluator class >> isAbstract [

	^ self = GolapNodeEvaluator
]

{ #category : 'accessing' }
GolapNodeEvaluator class >> tag [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapNodeEvaluator >> asSortFunction [

	^ PropertySortFunction property: self
]

{ #category : 'sorting' }
GolapNodeEvaluator >> ascending [

	^ self asSortFunction
]

{ #category : 'calibrating' }
GolapNodeEvaluator >> calibrateWithAll: aCollectionOfGolapNode graph: aGolapModel [

	aCollectionOfGolapNode
		ifEmpty: [
				min := nil.
				max := nil ]
		ifNotEmpty: [
				min := max := self
					              value: aCollectionOfGolapNode anyOne
					              graph: aGolapModel.
				aCollectionOfGolapNode do: [ :edge |
						| value |
						value := self value: edge graph: aGolapModel.
						value < min ifTrue: [ min := value ].
						max < value ifTrue: [ max := value ] ] ]
]

{ #category : 'sorting' }
GolapNodeEvaluator >> descending [

	^ self asSortFunction reversed
]

{ #category : 'evaluating' }
GolapNodeEvaluator >> evaluate: aGolapEdge graph: aGolapModel [
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
GolapNodeEvaluator >> graph: aGolapModel [

	^ [ :node | self value: node graph: aGolapModel ]
]

{ #category : 'accessing' }
GolapNodeEvaluator >> lowerThreshold [

	^ lowerThreshold
]

{ #category : 'accessing' }
GolapNodeEvaluator >> lowerThreshold: aNumber [

	lowerThreshold := aNumber
]

{ #category : 'accessing' }
GolapNodeEvaluator >> max [

	^ max
]

{ #category : 'accessing' }
GolapNodeEvaluator >> min [

	^ min
]

{ #category : 'accessing' }
GolapNodeEvaluator >> name [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapNodeEvaluator >> subtag [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapNodeEvaluator >> tag [

	^ self class tag
]

{ #category : 'accessing' }
GolapNodeEvaluator >> upperThreshold [

	^ upperThreshold
]

{ #category : 'accessing' }
GolapNodeEvaluator >> upperThreshold: aNumber [

	upperThreshold := aNumber
]

{ #category : 'evaluating' }
GolapNodeEvaluator >> value: aGolapNode graph: aGolapModel [

	^ self subclassResponsibility
]
