Class {
	#name : #GolapVertexAverageEvaluator,
	#superclass : #GolapVertexAggregationEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #accessing }
GolapVertexAverageEvaluator class >> subtag [

	^ 'average'
]

{ #category : #evaluating }
GolapVertexAverageEvaluator >> aggregation [

	^ #average
]

{ #category : #accessing }
GolapVertexAverageEvaluator >> aggregationName [

	^ '平均 '
]
