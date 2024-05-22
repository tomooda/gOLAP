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
	  ,
	  (golapModel ifNotNil: [ :m | m edgeEvaluator name ] ifNil: [ '' ])
]

{ #category : 'accessing' }
GolapNodeAggregationEvaluator >> subtag [

	^ self class subtag
]

{ #category : 'evaluating' }
GolapNodeAggregationEvaluator >> value: aGolapNode [

	^ (self valuesAtEdgesOfNode: aGolapNode)
		  ifNotEmpty: self aggregation
		  ifEmpty: [ 0 ]
]
