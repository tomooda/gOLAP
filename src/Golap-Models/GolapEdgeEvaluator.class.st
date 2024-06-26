Class {
	#name : 'GolapEdgeEvaluator',
	#superclass : 'Object',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapEdgeEvaluator class >> fromJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		subclass isAbstract not ifTrue: [
			(subclass fromJSON: aDictionary) ifNotNil: [ :evaluator |
				^ evaluator ] ] ].
	^ nil
]

{ #category : 'testing' }
GolapEdgeEvaluator class >> isAbstract [

	^ self = GolapEdgeEvaluator
]

{ #category : 'accessing' }
GolapEdgeEvaluator class >> tag [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapEdgeEvaluator >> asJSON [

	^ { (self tag -> self subtag) } asOrderedDictionary
]

{ #category : 'converting' }
GolapEdgeEvaluator >> asSortFunction [

	^ PropertySortFunction property: self
]

{ #category : 'sorting' }
GolapEdgeEvaluator >> ascending [

	^ self asSortFunction
]

{ #category : 'sorting' }
GolapEdgeEvaluator >> descending [

	^ self asSortFunction reversed
]

{ #category : 'evaluating' }
GolapEdgeEvaluator >> graph: aGolapModel [

	^ [ :edge | self value: edge graph: aGolapModel ]
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

{ #category : 'evaluating' }
GolapEdgeEvaluator >> value: aGolapEdge graph: aGolapModel [

	^ self subclassResponsibility
]
