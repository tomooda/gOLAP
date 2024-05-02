Class {
	#name : 'GolapVertexMaxEvaluator',
	#superclass : 'GolapVertexAggregationEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'accessing' }
GolapVertexMaxEvaluator class >> subtag [

	^ 'max'
]

{ #category : 'evaluating' }
GolapVertexMaxEvaluator >> aggregation [

	^ #max
]

{ #category : 'accessing' }
GolapVertexMaxEvaluator >> aggregationName [

	^ '最大 '
]
