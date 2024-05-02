Class {
	#name : 'GolapVertexAverageEvaluator',
	#superclass : 'GolapVertexAggregationEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'accessing' }
GolapVertexAverageEvaluator class >> subtag [

	^ 'average'
]

{ #category : 'evaluating' }
GolapVertexAverageEvaluator >> aggregation [

	^ #average
]

{ #category : 'accessing' }
GolapVertexAverageEvaluator >> aggregationName [

	^ '平均 '
]
