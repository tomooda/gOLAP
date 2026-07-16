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

	^ [ :collection | collection average asFloat ]
]

{ #category : 'accessing' }
GolapNodeAverageEvaluator >> aggregationName [

	^ '平均 '
]
