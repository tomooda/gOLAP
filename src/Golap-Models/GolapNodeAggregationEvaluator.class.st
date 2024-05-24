Class {
	#name : 'GolapNodeAggregationEvaluator',
	#superclass : 'GolapNodeEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapNodeAggregationEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :subtag |
			  subtag = self subtag
				  ifTrue: [ self new ]
				  ifFalse: [ nil ] ]
		  ifAbsent: [ nil ]
]

{ #category : 'testing' }
GolapNodeAggregationEvaluator class >> isAbstract [

	^ self = GolapNodeAggregationEvaluator
]

{ #category : 'accessing' }
GolapNodeAggregationEvaluator class >> subtag [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapNodeAggregationEvaluator class >> tag [

	^ 'aggregation'
]

{ #category : 'accessing' }
GolapNodeAggregationEvaluator >> aggregation [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapNodeAggregationEvaluator >> aggregationName [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapNodeAggregationEvaluator >> name [

	^ self aggregationName
]

{ #category : 'accessing' }
GolapNodeAggregationEvaluator >> subtag [

	^ self class subtag
]

{ #category : 'evaluating' }
GolapNodeAggregationEvaluator >> value: aGolapNode graph: aGolapModel [

	^ (self valuesAtEdgesOfNode: aGolapNode graph: aGolapModel)
		  ifNotEmpty: self aggregation
		  ifEmpty: [ 0 ]
]

{ #category : 'private' }
GolapNodeAggregationEvaluator >> valuesAtEdgesOfNode: aGolapNode graph: aGolapModel [

	^ Array streamContents: [ :stream |
		  aGolapNode edgesDo: [ :edge |
			  stream nextPut: (aGolapModel valueAtEdge: edge) ] ]
]
