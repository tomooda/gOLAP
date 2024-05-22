Class {
	#name : 'GolapNodeAverageEvaluator',
	#superclass : 'GolapNodeAggregationEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'accessing' }
GolapNodeAverageEvaluator class >> subtag [

	^ 'average'
]

{ #category : 'evaluating' }
GolapNodeAverageEvaluator >> aggregation [

	^ #average
]

{ #category : 'accessing' }
GolapNodeAverageEvaluator >> aggregationName [

	^ '平均 '
]
