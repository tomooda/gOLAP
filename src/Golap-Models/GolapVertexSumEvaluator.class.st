Class {
	#name : 'GolapVertexSumEvaluator',
	#superclass : 'GolapVertexAggregationEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'accessing' }
GolapVertexSumEvaluator class >> subtag [

	^ 'sum'
]

{ #category : 'accessing' }
GolapVertexSumEvaluator >> aggregation [

	^ #sum
]

{ #category : 'accessing' }
GolapVertexSumEvaluator >> aggregationName [

	^ '合計 '
]
