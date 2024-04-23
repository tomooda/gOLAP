Class {
	#name : #GolapVertexAggregationEvaluator,
	#superclass : #GolapVertexEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #'instance creation' }
GolapVertexAggregationEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :subtag |
			  subtag = self subtag
				  ifTrue: [ self new ]
				  ifFalse: [ nil ] ]
		  ifAbsent: [ nil ]
]

{ #category : #testing }
GolapVertexAggregationEvaluator class >> isAbstract [

	^ self = GolapVertexAggregationEvaluator
]

{ #category : #accessing }
GolapVertexAggregationEvaluator class >> subtag [

	^ self subclassResponsibility
]

{ #category : #accessing }
GolapVertexAggregationEvaluator class >> tag [

	^ 'aggregation'
]

{ #category : #accessing }
GolapVertexAggregationEvaluator >> aggregation [

	^ self subclassResponsibility
]

{ #category : #accessing }
GolapVertexAggregationEvaluator >> aggregationName [

	^ self subclassResponsibility
]

{ #category : #accessing }
GolapVertexAggregationEvaluator >> name [

	^ self aggregationName
	  ,
	  (golapModel ifNotNil: [ :m | m edgeEvaluator name ] ifNil: [ '' ])
]

{ #category : #accessing }
GolapVertexAggregationEvaluator >> subtag [

	^ self class subtag
]

{ #category : #evaluating }
GolapVertexAggregationEvaluator >> value: aGolapVertex [

	^ (self valuesAtEdgesOfVertex: aGolapVertex)
		  ifNotEmpty: self aggregation
		  ifEmpty: [ 0 ]
]
