Class {
	#name : 'GolapNodeSumEvaluator',
	#superclass : 'GolapNodeAggregationEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'accessing' }
GolapNodeSumEvaluator class >> subtag [

	^ 'sum'
]

{ #category : 'accessing' }
GolapNodeSumEvaluator >> aggregation [

	^ #sum
]

{ #category : 'accessing' }
GolapNodeSumEvaluator >> aggregationName [

	^ '合計 '
]
