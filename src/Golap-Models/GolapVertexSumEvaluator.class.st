Class {
	#name : #GolapVertexSumEvaluator,
	#superclass : #GolapVertexAggregationEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #accessing }
GolapVertexSumEvaluator class >> subtag [

	^ 'sum'
]

{ #category : #accessing }
GolapVertexSumEvaluator >> aggregation [

	^ #sum
]

{ #category : #accessing }
GolapVertexSumEvaluator >> aggregationName [

	^ '合計 '
]
